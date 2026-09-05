import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_tenant.dart';
import 'monnify_config.dart';
import 'user_repository.dart';

/// Monnify + Firebase — single place for virtual accounts & disbursements.
/// All Firestore writes scoped via AppTenant for multi-tenant isolation.
class MonnifyService {
  MonnifyService._();
  static final MonnifyService instance = MonnifyService._();

  String? _cachedToken;
  DateTime? _tokenExpiry;

  AppTenant get _tenant => AppTenant.current;

  Future<String> _getAccessToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }
    MonnifyConfig.assertConfigured();
    if (!MonnifyConfig.isConfigured) {
      throw Exception('Monnify NOT configured');
    }
    final basic = base64Encode(utf8.encode('${MonnifyConfig.apiKey}:${MonnifyConfig.secretKey}'));
    final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v1/auth/login');
    final res = await http.post(uri, headers: {'Authorization': 'Basic $basic'});
    if (res.statusCode != 200) throw Exception('Monnify auth failed ${res.statusCode}: ${res.body}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = (body['responseBody']?['accessToken'] ?? body['accessToken']) as String?;
    if (token == null || token.isEmpty) throw Exception('No accessToken');
    _cachedToken = token;
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));
    return token;
  }

  Map<String, String> _bearerHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> createReservedAccount({
    String? accountReference,
    String? accountName,
    String? customerEmail,
    String? customerName,
    String? bvn,
    String? nin,
    String currencyCode = 'NGN',
    String? contractCode,
    bool getAllAvailableBanks = true,
    List<String> preferredBanks = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final uid = user.uid;

    if (!MonnifyConfig.isConfigured && (contractCode == null || contractCode.isEmpty)) {
      await MonnifyConfig.ensureConfigured();
    }

    final profileSnap = await UserRepository.instance.getUser(uid);
    final profile = profileSnap.data() ?? {};
    final email = (customerEmail ?? profile['email'] ?? user.email ?? '').trim();
    final name = (customerName ?? profile['username'] ?? profile['displayName'] ?? user.displayName ?? email.split('@').first).trim();
    final resolvedAccountName = (accountName ?? name).trim();
    if (email.isEmpty || resolvedAccountName.isEmpty) throw Exception('Missing email/name');

    final ref = (accountReference ?? 'REGENT_${uid}_${DateTime.now().millisecondsSinceEpoch}').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final cc = (contractCode ?? MonnifyConfig.contractCode).trim();
    if (cc.isEmpty) throw Exception('Monnify contractCode missing');

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

    Map<String, dynamic> monnifyRes;
    if (MonnifyConfig.useDirect) {
      final token = await _getAccessToken();
      final uri = Uri.parse('${MonnifyConfig.baseUrl}/api/v2/bank-transfer/reserved-accounts');
      final res = await http.post(uri, headers: _bearerHeaders(token), body: jsonEncode(payload));
      if (res.statusCode == 400 && res.body.toLowerCase().contains('accountreference') && res.body.toLowerCase().contains('exist')) {
        final existing = await _tenant.monnifyAccounts(uid).limit(1).get();
        if (existing.docs.isNotEmpty) return existing.docs.first.data()!;
        final retryRef = 'REGENT_${uid}_${DateTime.now().millisecondsSinceEpoch}_R';
        final retryPayload = {...payload, 'accountReference': retryRef};
        final retryRes = await http.post(uri, headers: _bearerHeaders(token), body: jsonEncode(retryPayload));
        if (retryRes.statusCode >= 200 && retryRes.statusCode < 300) {
          final retryDecoded = jsonDecode(retryRes.body) as Map<String, dynamic>;
          monnifyRes = (retryDecoded['responseBody'] as Map?)?.cast<String, dynamic>() ?? retryDecoded;
          return _saveAccount(monnifyRes, uid, ref: retryRef, email: email, name: name, resolvedAccountName: resolvedAccountName, currencyCode: currencyCode, cc: cc, bvn: bvn);
        }
      }
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Monnify create failed ${res.statusCode}: ${res.body}');
      monnifyRes = (decoded['responseBody'] as Map?)?.cast<String, dynamic>() ?? decoded;
      if (monnifyRes['accountReference'] == null && decoded['requestSuccessful'] == false) throw Exception(decoded['responseMessage'] ?? 'Monnify error');
    } else {
      final fn = FirebaseFunctions.instance.httpsCallable(MonnifyConfig.fnCreateReservedAccount);
      final result = await fn.call(payload);
      monnifyRes = (result.data as Map).cast<String, dynamic>();
    }

    return _saveAccount(monnifyRes, uid, ref: ref, email: email, name: name, resolvedAccountName: resolvedAccountName, currencyCode: currencyCode, cc: cc, bvn: bvn);
  }

  Map<String, dynamic> _saveAccount(
    Map<String, dynamic> monnifyRes,
    String uid, {
    required String ref,
    required String email,
    required String name,
    required String resolvedAccountName,
    required String currencyCode,
    required String cc,
    String? bvn,
  }) {
    final accounts = (monnifyRes['accounts'] as List?) ?? [];
    final primary = accounts.isNotEmpty ? (accounts.first as Map).cast<String, dynamic>() : <String, dynamic>{};

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
      'accounts': accounts,
      'primaryAccountNumber': primary['accountNumber'] ?? '',
      'primaryBankCode': primary['bankCode'] ?? '',
      'primaryBankName': primary['bankName'] ?? '',
      'bvn': bvn ?? '',
      'uid': uid,
      'provider': 'monnify',
      'raw': monnifyRes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _tenant.db.batch();
    final accountRef = doc['accountReference'] as String;
    batch.set(_tenant.monnifyAccounts(uid).doc(accountRef), doc, SetOptions(merge: true));
    batch.set(_tenant.monnifyReservedAccounts.doc(accountRef), doc, SetOptions(merge: true));
    batch.set(_tenant.userDoc(uid), {
      'hasVirtualAccount': true,
      'primaryVirtualAccount': {
        'accountNumber': doc['primaryAccountNumber'],
        'bankName': doc['primaryBankName'],
        'bankCode': doc['primaryBankCode'],
        'accountReference': accountRef,
        'accountName': doc['accountName'],
      },
      'virtualAccountCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.commit();

    if (kDebugMode) debugPrint('[Monnify] saved $accountRef for $uid');
    return doc;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserAccounts(String uid) =>
      _tenant.monnifyAccounts(uid).orderBy('createdAt', descending: true).snapshots();

  Future<QuerySnapshot<Map<String, dynamic>>> getUserAccountsOnce(String uid) =>
      _tenant.monnifyAccounts(uid).orderBy('createdAt', descending: true).get();

  Future<double> getReservedAccountBalance(String accountReference) async {
    try {
      final snap = await _tenant.monnifyReservedAccounts.doc(accountReference).get();
      final data = snap.data();
      return (data?['totalReceived'] as num?)?.toDouble() ?? 0.0;
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
      final snap = await _tenant.monnifyTransactions.where('accountReference', isEqualTo: accountReference).orderBy('paidOn', descending: true).limit(size).get();
      return snap.docs.map((d) => d.data()).toList();
    }
  }

  Future<Map<String, dynamic>> singleTransfer({
    required double amount,
    required String destinationBankCode,
    required String destinationAccountNumber,
    required String destinationAccountName,
    String currency = 'NGN',
    String? narration,
    String? reference,
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
      'sourceAccountNumber': '',
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

  static Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    try {
      final tenant = AppTenant.current;
      final data = event['eventData'] as Map<String, dynamic>? ?? event;
      final ref = (data['accountReference'] ?? data['destinationAccountInformation']?['accountReference'] ?? '') as String;
      final txRef = (data['transactionReference'] ?? data['paymentReference'] ?? DateTime.now().millisecondsSinceEpoch.toString()) as String;
      await tenant.monnifyTransactions.doc(txRef).set({
        'accountReference': ref,
        'transactionReference': txRef,
        'amountPaid': data['amountPaid'],
        'totalPayable': data['totalPayable'],
        'paidOn': data['paidOn'] ?? FieldValue.serverTimestamp(),
        'paymentStatus': data['paymentStatus'] ?? 'PAID',
        'raw': event,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (ref.isNotEmpty) {
        final amt = (data['amountPaid'] as num?)?.toDouble() ?? 0;
        await tenant.monnifyReservedAccounts.doc(ref).set({
          'totalReceived': FieldValue.increment(amt),
          'lastPaymentAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Monnify webhook] save failed: $e');
    }
  }
}
