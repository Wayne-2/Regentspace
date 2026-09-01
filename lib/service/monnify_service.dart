import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'monnify_config.dart';
import 'user_repository.dart';

/// Monnify + Firebase — single place for virtual accounts & disbursements.
/// Pattern: app → (MonnifyConfig.useDirect ? Monnify REST directly : Firebase Functions proxy) → Firestore.
///
/// IMPORTANT: For prod set MONNIFY_USE_DIRECT=false and deploy functions/monnify/*.js
/// so secret keys never ship in the APK/IPA. Sandbox may use direct = true for quick testing.
class MonnifyService {
  MonnifyService._();
  static final MonnifyService instance = MonnifyService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _cachedToken;
  DateTime? _tokenExpiry;

  // ---------------------------------------------------------------------------
  // Auth — POST /api/v1/auth/login  Basic base64(apiKey:secretKey)
  // ---------------------------------------------------------------------------
  Future<String> _getAccessToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }
    MonnifyConfig.assertConfigured();
    if (!MonnifyConfig.isConfigured) {
      throw Exception('Monnify NOT configured — Firestore config/monnify missing or --dart-define MONNIFY_* not set. baseUrl=${MonnifyConfig.baseUrl} apiKey=${MonnifyConfig.apiKey.isEmpty ? "EMPTY" : "SET"} contract=${MonnifyConfig.contractCode.isEmpty ? "EMPTY" : "SET"}');
    }
    final basic = base64Encode(utf8.encode('${MonnifyConfig.apiKey}:${MonnifyConfig.secretKey}'));
    final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v1/auth/login');
    debugPrint('[Monnify] POST $uri basic=${MonnifyConfig.apiKey.substring(0, MonnifyConfig.apiKey.length.clamp(0, 8))}...'); // debug payload
    final res = await http.post(uri, headers: {'Authorization': 'Basic $basic'});
    debugPrint('[Monnify] auth ${res.statusCode}: ${res.body}');
    if (res.statusCode != 200) throw Exception('Monnify auth failed ${res.statusCode}: ${res.body}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = (body['responseBody']?['accessToken'] ?? body['accessToken']) as String?;
    if (token == null || token.isEmpty) throw Exception('No accessToken in ${res.body}');
    _cachedToken = token;
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 50)); // Monnify tokens ~1h
    return token;
  }

  Map<String, String> _bearerHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  // ---------------------------------------------------------------------------
  // Create Reserved Account — POST /api/v2/bank-transfer/reserved-accounts
  // Docs: https://docs.monnify.com/docs/reserved-accounts
  // ---------------------------------------------------------------------------
  /// Creates a Monnify reserved account, then mirrors it to Firestore:
  /// - `users/{uid}/monnifyAccounts/{accountReference}`
  /// - `users/{uid}`.virtualAccounts[] (summary)
  /// - `monnify_reserved_accounts/{accountReference}` (for webhook lookup)
  Future<Map<String, dynamic>> createReservedAccount({
    String? accountReference, // auto = REGENT_{uid}_{ts} if null
    String? accountName, // auto = username from Firestore if null
    String? customerEmail,
    String? customerName,
    String? bvn,
    String? nin,
    String currencyCode = 'NGN',
    String? contractCode, // overrides config
    bool getAllAvailableBanks = true, // Monnify returns all banks when true
    List<String> preferredBanks = const [], // e.g. ["035","232"] wrappers ignore when getAll=true
    bool incomeSplitConfig = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final uid = user.uid;

    // DEBUG FIX: retry config load after auth (cold-start load failed with permission-denied before login)
    // See log 13:00:27.991 [MonnifyConfig] Firestore load failed: permission-denied
    // and 13:02:16.812 Auto virtual account failed: Monnify contractCode missing
    if (!MonnifyConfig.isConfigured && (contractCode == null || contractCode.isEmpty)) {
      await MonnifyConfig.ensureConfigured();
    }

    // Pull profile from Firestore to auto-fill create-account fields extracted from Google/email
    final profileSnap = await UserRepository.instance.getUser(uid);
    final profile = profileSnap.data() ?? {};
    final email = (customerEmail ?? profile['email'] ?? user.email ?? '').trim();
    final name = (customerName ?? profile['username'] ?? profile['displayName'] ?? user.displayName ?? email.split('@').first).trim();
    final resolvedAccountName = (accountName ?? name).trim();
    if (email.isEmpty || resolvedAccountName.isEmpty) throw Exception('Missing email/name for reserved account');

    final ref = (accountReference ?? 'REGENT_${uid}_${DateTime.now().millisecondsSinceEpoch}').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final cc = (contractCode ?? MonnifyConfig.contractCode).trim();
    if (cc.isEmpty) {
      throw Exception('Monnify contractCode missing — doc config/monnify not found or empty. Create Firestore doc config/monnify {baseUrl: "https://sandbox.monnify.com", apiKey: "...", secretKey: "...", contractCode: "...", useDirect: true} and ensure rules allow read for authenticated user. Also check --dart-define MONNIFY_* fallback.');
    }

    final payload = {
      'accountReference': ref,
      'accountName': resolvedAccountName,
      'currencyCode': currencyCode,
      'contractCode': cc,
      'customerEmail': email,
      'customerName': name,
      'getAllAvailableBanks': getAllAvailableBanks,
      if (bvn != null && bvn.isNotEmpty) 'bvn': bvn,
      if (nin != null && nin.isNotEmpty) 'nin': nin,
      if (!getAllAvailableBanks && preferredBanks.isNotEmpty) 'preferredBanks': preferredBanks,
    };

    debugPrint('[Monnify] create payload $payload');
    Map<String, dynamic> monnifyRes;
    if (MonnifyConfig.useDirect) {
      final token = await _getAccessToken();
      final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v2/bank-transfer/reserved-accounts');
      debugPrint('[Monnify] POST $uri payload=${jsonEncode(payload)}');
      final res = await http.post(uri, headers: _bearerHeaders(token), body: jsonEncode(payload));
      debugPrint('[Monnify] create $ref → ${res.statusCode} ${res.body}');
      // Handle duplicate accountReference gracefully — return existing Firestore doc instead of crashing
      if (res.statusCode == 400 && res.body.toLowerCase().contains('accountreference') && res.body.toLowerCase().contains('exist')) {
        debugPrint('[Monnify] duplicate ref $ref — fetching existing from Firestore');
        final existing = await _db.collection('users').doc(uid).collection('monnifyAccounts').limit(1).get();
        if (existing.docs.isNotEmpty) return existing.docs.first.data();
        // Retry once with new timestamped ref
        final retryRef = 'REGENT_${uid}_${DateTime.now().millisecondsSinceEpoch}_R';
        final retryPayload = {...payload, 'accountReference': retryRef};
        debugPrint('[Monnify] retry with $retryRef payload=${jsonEncode(retryPayload)}');
        final retryRes = await http.post(uri, headers: _bearerHeaders(token), body: jsonEncode(retryPayload));
        debugPrint('[Monnify] retry $retryRef → ${retryRes.statusCode} ${retryRes.body}');
        if (retryRes.statusCode >= 200 && retryRes.statusCode < 300) {
          final retryDecoded = jsonDecode(retryRes.body) as Map<String, dynamic>;
          final retryBody = (retryDecoded['responseBody'] as Map?)?.cast<String, dynamic>() ?? retryDecoded;
          monnifyRes = retryBody;
          // fall through to normal save below using retryBody
          final accountsRetry = (monnifyRes['accounts'] as List?) ?? [];
          final primaryRetry = accountsRetry.isNotEmpty ? (accountsRetry.first as Map).cast<String, dynamic>() : <String, dynamic>{};
          final docRetry = {
            'accountReference': monnifyRes['accountReference'] ?? retryRef,
            'accountName': monnifyRes['accountName'] ?? resolvedAccountName,
            'customerEmail': email,
            'customerName': name,
            'currencyCode': currencyCode,
            'contractCode': cc,
            'collectionChannel': monnifyRes['collectionChannel'] ?? 'RESERVED_ACCOUNT',
            'reservationReference': monnifyRes['reservationReference'] ?? '',
            'status': monnifyRes['status'] ?? 'ACTIVE',
            'accounts': accountsRetry,
            'primaryAccountNumber': primaryRetry['accountNumber'] ?? '',
            'primaryBankCode': primaryRetry['bankCode'] ?? '',
            'primaryBankName': primaryRetry['bankName'] ?? '',
            'bvn': bvn ?? '',
            'uid': uid,
            'provider': 'monnify',
            'raw': monnifyRes,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          final batchRetry = _db.batch();
          batchRetry.set(_db.collection('users').doc(uid).collection('monnifyAccounts').doc(docRetry['accountReference'] as String), docRetry, SetOptions(merge: true));
          batchRetry.set(_db.collection('monnify_reserved_accounts').doc(docRetry['accountReference'] as String), docRetry, SetOptions(merge: true));
          batchRetry.set(_db.collection('users').doc(uid), {
            'hasVirtualAccount': true,
            'primaryVirtualAccount': {
              'accountNumber': docRetry['primaryAccountNumber'],
              'bankName': docRetry['primaryBankName'],
              'bankCode': docRetry['primaryBankCode'],
              'accountReference': docRetry['accountReference'],
              'accountName': docRetry['accountName'],
            },
            'virtualAccountCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          await batchRetry.commit();
          return docRetry;
        }
      }
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Enrich 401 / 400 messages with fix hints
        String hint = '';
        if (res.statusCode == 401) hint = ' → FIX: sandbox keys only work with https://sandbox.monnify.com, live keys only with https://api.monnify.com. Check Firestore config/monnify baseUrl matches where you copied apiKey/secretKey. Trim spaces.';
        if (res.statusCode == 400 && res.body.toLowerCase().contains('contract')) hint = ' → FIX: contractCode invalid/empty. Copy exactly from Monnify Dashboard → Settings → Contract Code (e.g. 1234567890), no spaces, must belong to same environment as baseUrl.';
        throw Exception('Monnify create failed ${res.statusCode}: ${res.body}$hint | payload=${jsonEncode(payload)}');
      }
      // Monnify wraps in responseBody
      monnifyRes = (decoded['responseBody'] as Map?)?.cast<String, dynamic>() ?? decoded;
      if (monnifyRes['accountReference'] == null && decoded['requestSuccessful'] == false) throw Exception(decoded['responseMessage'] ?? 'Monnify error');
    } else {
      // Secure path — Cloud Functions holds secrets
      final fn = FirebaseFunctions.instance.httpsCallable(MonnifyConfig.fnCreateReservedAccount);
      final result = await fn.call(payload);
      monnifyRes = (result.data as Map).cast<String, dynamic>();
    }

    // Normalize — Monnify may return accounts: [{bankCode,bankName,accountNumber,...}]
    final accounts = (monnifyRes['accounts'] as List?) ?? [];
    final primaryAccount = accounts.isNotEmpty ? (accounts.first as Map).cast<String, dynamic>() : <String, dynamic>{};

    final doc = {
      'accountReference': monnifyRes['accountReference'] ?? ref,
      'accountName': monnifyRes['accountName'] ?? resolvedAccountName,
      'customerEmail': email,
      'customerName': name,
      'currencyCode': currencyCode,
      'contractCode': cc,
      'collectionChannel': monnifyRes['collectionChannel'] ?? 'RESERVED_ACCOUNT',
      'reservationReference': monnifyRes['reservationReference'] ?? '',
      'status': monnifyRes['status'] ?? 'ACTIVE',
      'accounts': accounts, // all bank options
      'primaryAccountNumber': primaryAccount['accountNumber'] ?? '',
      'primaryBankCode': primaryAccount['bankCode'] ?? '',
      'primaryBankName': primaryAccount['bankName'] ?? '',
      'bvn': bvn ?? '',
      'uid': uid,
      'provider': 'monnify',
      'raw': monnifyRes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Firebase mirrors — available even offline, drives UI & webhook routing
    final batch = _db.batch();
    final userAccountRef = _db.collection('users').doc(uid).collection('monnifyAccounts').doc(doc['accountReference'] as String);
    batch.set(userAccountRef, doc, SetOptions(merge: true));
    batch.set(_db.collection('monnify_reserved_accounts').doc(doc['accountReference'] as String), doc, SetOptions(merge: true));
    // Summary on users/{uid} for quick dashboard header
    batch.set(
      _db.collection('users').doc(uid),
      {
        'hasVirtualAccount': true,
        'primaryVirtualAccount': {
          'accountNumber': doc['primaryAccountNumber'],
          'bankName': doc['primaryBankName'],
          'bankCode': doc['primaryBankCode'],
          'accountReference': doc['accountReference'],
          'accountName': doc['accountName'],
        },
        'virtualAccountCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();

    if (kDebugMode) debugPrint('[Monnify] saved $ref for $uid → ${doc['primaryAccountNumber']}');
    return doc;
  }

  /// List user's reserved accounts from Firestore (fast, offline). Falls back to Monnify if empty and uid known.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserAccounts(String uid) =>
      _db.collection('users').doc(uid).collection('monnifyAccounts').orderBy('createdAt', descending: true).snapshots();

  Future<QuerySnapshot<Map<String, dynamic>>> getUserAccountsOnce(String uid) =>
      _db.collection('users').doc(uid).collection('monnifyAccounts').orderBy('createdAt', descending: true).get();

  // ---------------------------------------------------------------------------
  // Other Monnify bindings — keep Firebase as cache
  // ---------------------------------------------------------------------------

  Future<double> getReservedAccountBalance(String accountReference) async {
    // Monnify does not expose live balance on reserved accounts directly;
    // derive from Firestore transactions subcollection or call disbursement balance.
    try {
      final snap = await _db.collection('monnify_reserved_accounts').doc(accountReference).get();
      return (snap.data()?['totalReceived'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getVirtualAccountTransactions(String accountReference, {int page = 0, int size = 10}) async {
    if (MonnifyConfig.useDirect) {
      final token = await _getAccessToken();
      final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v1/bank-transfer/reserved-accounts/transactions?accountReference=$accountReference&page=$page&size=$size');
      final res = await http.get(uri, headers: _bearerHeaders(token));
      if (res.statusCode != 200) throw Exception('Monnify tx ${res.statusCode}: ${res.body}');
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (body['responseBody']?['content'] as List?) ?? [];
      return content.cast<Map<String, dynamic>>();
    } else {
      // From Firestore monnify_transactions/{txRef} written by webhook
      final snap = await _db.collection('monnify_transactions').where('accountReference', isEqualTo: accountReference).orderBy('paidOn', descending: true).limit(size).get();
      return snap.docs.map((d) => d.data()).toList();
    }
  }

  /// Disbursement — POST /api/v2/disbursements/single  (requires Monnify disbursement wallet funding)
  Future<Map<String, dynamic>> singleTransfer({
    required double amount,
    required String destinationBankCode,
    required String destinationAccountNumber,
    required String destinationAccountName,
    String currency = 'NGN',
    String? narration,
    String? reference, // auto if null
  }) async {
    final ref = reference ?? 'REGENT_DISB_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'amount': amount,
      'reference': ref,
      'narration': narration ?? 'Regentspace disbursement',
      'destinationBankCode': destinationBankCode,
      'destinationAccountNumber': destinationAccountNumber,
      'destinationAccountName': destinationAccountName,
      'currency': currency,
      'sourceAccountNumber': '', // uses Monnify wallet configured for contract
    };
    if (MonnifyConfig.useDirect) {
      final token = await _getAccessToken();
      final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v2/disbursements/single');
      final res = await http.post(uri, headers: _bearerHeaders(token), body: jsonEncode(payload));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Disburse failed: ${res.body}');
      return (body['responseBody'] as Map?)?.cast<String, dynamic>() ?? body;
    } else {
      final fn = FirebaseFunctions.instance.httpsCallable(MonnifyConfig.fnDisburse);
      final result = await fn.call(payload);
      return (result.data as Map).cast<String, dynamic>();
    }
  }

  // ---------------------------------------------------------------------------
  // Webhook helper — call from Cloud Function after signature verification.
  // Store in Firestore so UI updates real-time.
  // ---------------------------------------------------------------------------
  static Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    // event from Monnify: {eventType, eventData: {accountReference, amountPaid, ...}}
    try {
      final db = FirebaseFirestore.instance;
      final data = event['eventData'] as Map<String, dynamic>? ?? event;
      final ref = (data['accountReference'] ?? data['destinationAccountInformation']?['accountReference'] ?? '') as String;
      final txRef = (data['transactionReference'] ?? data['paymentReference'] ?? DateTime.now().millisecondsSinceEpoch.toString()) as String;
      await db.collection('monnify_transactions').doc(txRef).set({
        'accountReference': ref,
        'transactionReference': txRef,
        'amountPaid': data['amountPaid'],
        'totalPayable': data['totalPayable'],
        'paidOn': data['paidOn'] ?? FieldValue.serverTimestamp(),
        'paymentStatus': data['paymentStatus'] ?? 'PAID',
        'raw': event,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Increment totals on reserved account doc
      if (ref.isNotEmpty) {
        final amt = (data['amountPaid'] as num?)?.toDouble() ?? 0;
        await db.collection('monnify_reserved_accounts').doc(ref).set({
          'totalReceived': FieldValue.increment(amt),
          'lastPaymentAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Monnify webhook] save failed: $e');
    }
  }
}
