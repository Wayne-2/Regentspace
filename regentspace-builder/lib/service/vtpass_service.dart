import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'app_tenant.dart';
import 'vtpass_config.dart';

/// VTPass service — airtime, data, TV, electricity, etc.
/// All Firestore writes scoped via AppTenant for multi-tenant isolation.
///
/// VTPass API auth: api-key + secret-key headers for POST, api-key + public-key for GET.
/// Sandbox: https://sandbox.vtpass.com/api  Live: https://vtpass.com/api
class VtpassService {
  VtpassService._();
  static final VtpassService instance = VtpassService._();

  AppTenant get _tenant => AppTenant.current;

  String _generateRequestId() {
    final now = DateTime.now();
    final lagos = now.toUtc().add(const Duration(hours: 1));
    final datePart = DateFormat('yyyyMMddHHmm').format(lagos);
    final suffix = DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 8);
    return '$datePart$suffix';
  }

  Map<String, String> _postHeaders() => {
        'api-key': VtpassConfig.apiKey,
        'secret-key': VtpassConfig.secretKey,
        'Content-Type': 'application/json',
      };

  Map<String, String> _getHeaders() => {
        'api-key': VtpassConfig.apiKey,
        'public-key': VtpassConfig.publicKey,
      };

  /// Safe JSON decode — returns null if response is not valid JSON Map
  Map<String, dynamic>? _safeDecode(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      // If it's a string or other type, wrap it
      return {'raw_response': res.body};
    } catch (e) {
      return {'raw_response': res.body, 'error': e.toString()};
    }
  }

  /// Get user's default phone number from Firestore profile
  Future<String> getDefaultPhone() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return '';
      final doc = await _tenant.userDoc(uid).get();
      return (doc.data()?['phone'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  // ─── Airtime ───

  Future<Map<String, dynamic>> buyAirtime({
    required String serviceID,
    required double amount,
    required String phone,
    String? email,
  }) async {
    VtpassConfig.assertConfigured();
    final requestId = _generateRequestId();
    final payload = {
      'serviceID': serviceID,
      'amount': amount,
      'phone': phone,
      'requestID': requestId,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final uri = Uri.parse('${VtpassConfig.baseUrl}/pay');
    final res = await http.post(uri, headers: _postHeaders(), body: jsonEncode(payload));
    if (kDebugMode) debugPrint('[Vtpass] buyAirtime $serviceID → ${res.statusCode}');

    final body = _safeDecode(res);
    if (body == null) throw Exception('VTPass airtime failed: Invalid response');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('VTPass airtime failed: ${body['response_description'] ?? res.body}');
    }

    await _saveTransaction(requestId, 'airtime', body, serviceID: serviceID, phone: phone, amount: amount);
    return body;
  }

  // ─── Data ───

  Future<Map<String, dynamic>> buyData({
    required String serviceID,
    required String variationCode,
    required String phone,
    String? email,
  }) async {
    VtpassConfig.assertConfigured();
    final requestId = _generateRequestId();
    final payload = {
      'serviceID': serviceID,
      'variation_code': variationCode,
      'billersCode': phone,
      'phone': phone,
      'requestID': requestId,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final uri = Uri.parse('${VtpassConfig.baseUrl}/pay');
    final res = await http.post(uri, headers: _postHeaders(), body: jsonEncode(payload));
    if (kDebugMode) debugPrint('[Vtpass] buyData $serviceID → ${res.statusCode}');

    final body = _safeDecode(res);
    if (body == null) throw Exception('VTPass data failed: Invalid response');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('VTPass data failed: ${body['response_description'] ?? res.body}');
    }

    await _saveTransaction(requestId, 'data', body, serviceID: serviceID, phone: phone);
    return body;
  }

  // ─── TV Subscription ───

  Future<Map<String, dynamic>> buyTvSubscription({
    required String serviceID,
    required String variationCode,
    required String smartCardNumber,
    String? email,
    double? amount,
  }) async {
    VtpassConfig.assertConfigured();
    final requestId = _generateRequestId();
    final payload = {
      'serviceID': serviceID,
      'variation_code': variationCode,
      'billersCode': smartCardNumber,
      'requestID': requestId,
      if (email != null && email.isNotEmpty) 'email': email,
      if (amount != null) 'amount': amount,
    };

    final uri = Uri.parse('${VtpassConfig.baseUrl}/pay');
    final res = await http.post(uri, headers: _postHeaders(), body: jsonEncode(payload));
    if (kDebugMode) debugPrint('[Vtpass] buyTv $serviceID → ${res.statusCode}');

    final body = _safeDecode(res);
    if (body == null) throw Exception('VTPass TV failed: Invalid response');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('VTPass TV failed: ${body['response_description'] ?? res.body}');
    }

    await _saveTransaction(requestId, 'tv', body, serviceID: serviceID, smartCardNumber: smartCardNumber);
    return body;
  }

  // ─── Electricity ───

  Future<Map<String, dynamic>> buyElectricity({
    required String serviceID,
    required String variationCode,
    required String meterNumber,
    required double amount,
    String? email,
  }) async {
    VtpassConfig.assertConfigured();
    final requestId = _generateRequestId();
    final payload = {
      'serviceID': serviceID,
      'variation_code': variationCode,
      'billersCode': meterNumber,
      'amount': amount,
      'requestID': requestId,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final uri = Uri.parse('${VtpassConfig.baseUrl}/pay');
    final res = await http.post(uri, headers: _postHeaders(), body: jsonEncode(payload));
    if (kDebugMode) debugPrint('[Vtpass] buyElectricity $serviceID → ${res.statusCode}');

    final body = _safeDecode(res);
    if (body == null) throw Exception('VTPass electricity failed: Invalid response');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('VTPass electricity failed: ${body['response_description'] ?? res.body}');
    }

    await _saveTransaction(requestId, 'electricity', body, serviceID: serviceID, meterNumber: meterNumber, amount: amount);
    return body;
  }

  // ─── General Purchase ───

  Future<Map<String, dynamic>> purchase({
    required String serviceID,
    required String variationCode,
    required Map<String, dynamic> extras,
  }) async {
    VtpassConfig.assertConfigured();
    final requestId = _generateRequestId();
    final payload = {
      'serviceID': serviceID,
      'variation_code': variationCode,
      'requestID': requestId,
      ...extras,
    };

    final uri = Uri.parse('${VtpassConfig.baseUrl}/pay');
    final res = await http.post(uri, headers: _postHeaders(), body: jsonEncode(payload));
    if (kDebugMode) debugPrint('[Vtpass] purchase $serviceID → ${res.statusCode}');

    final body = _safeDecode(res);
    if (body == null) throw Exception('VTPass purchase failed: Invalid response');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('VTPass purchase failed: ${body['response_description'] ?? res.body}');
    }

    await _saveTransaction(requestId, serviceID, body);
    return body;
  }

  // ─── Requery / Status ───

  Future<Map<String, dynamic>> requeryTransaction({
    required String requestId,
  }) async {
    VtpassConfig.assertConfigured();
    final uri = Uri.parse('${VtpassConfig.baseUrl}/requery');
    final res = await http.post(
      uri,
      headers: _postHeaders(),
      body: jsonEncode({'request_id': requestId}),
    );
    if (kDebugMode) debugPrint('[Vtpass] requery $requestId → ${res.statusCode}');
    return _safeDecode(res) ?? {};
  }

  // ─── Balance ───

  Future<double> getBalance() async {
    VtpassConfig.assertConfigured();
    final uri = Uri.parse('${VtpassConfig.baseUrl}/balance');
    final res = await http.get(uri, headers: _getHeaders());
    if (res.statusCode != 200) throw Exception('VTPass balance failed: ${res.body}');
    final body = _safeDecode(res);
    return (body?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
  }

  // ─── List Services ───

  Future<List<Map<String, dynamic>>> getServices() async {
    VtpassConfig.assertConfigured();
    final uri = Uri.parse('${VtpassConfig.baseUrl}/services');
    final res = await http.get(uri, headers: _getHeaders());
    if (res.statusCode != 200) throw Exception('VTPass services failed: ${res.body}');
    final body = _safeDecode(res);
    final content = body?['content'];
    if (content is List) return content.cast<Map<String, dynamic>>();
    return [];
  }

  // ─── Variation Codes ───

  Future<List<Map<String, dynamic>>> getVariationCodes(String serviceID) async {
    VtpassConfig.assertConfigured();
    final uri = Uri.parse('${VtpassConfig.baseUrl}/service-variations?serviceID=$serviceID');
    final res = await http.get(uri, headers: _getHeaders());
    if (res.statusCode != 200) throw Exception('VTPass variations failed: ${res.body}');
    final body = _safeDecode(res);
    final content = body?['content'];
    if (content is Map<String, dynamic>) {
      final variations = content['variations'];
      if (variations is List) return variations.cast<Map<String, dynamic>>();
    }
    if (content is List) return content.cast<Map<String, dynamic>>();
    return [];
  }

  // ─── Firestore Persistence ───

  Future<void> _saveTransaction(
    String requestId,
    String type,
    Map<String, dynamic> response, {
    String? serviceID,
    String? phone,
    double? amount,
    String? smartCardNumber,
    String? meterNumber,
  }) async {
    try {
      final content = response['content'];
      final transactions = (content is Map<String, dynamic>)
          ? (content['transactions'] as Map<String, dynamic>? ?? {})
          : <String, dynamic>{};
      await _tenant.vtpassTransactions.doc(requestId).set({
        'requestId': requestId,
        'type': type,
        'serviceID': serviceID,
        'phone': phone,
        'amount': amount ?? transactions['amount'],
        'smartCardNumber': smartCardNumber,
        'meterNumber': meterNumber,
        'status': transactions['status'] ?? 'pending',
        'productName': transactions['product_name'],
        'transactionId': transactions['transactionId'],
        'channel': transactions['channel'],
        'responseDescription': response['response_description'],
        'responseCode': response['code'],
        'raw': response,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (kDebugMode) debugPrint('[Vtpass] saved transaction $requestId');
    } catch (e) {
      if (kDebugMode) debugPrint('[Vtpass] save transaction failed: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions({int limit = 50}) {
    return _tenant.vtpassTransactions
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  static Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    try {
      final tenant = AppTenant.current;
      final data = event['data'] as Map<String, dynamic>? ?? {};
      final requestId = (data['requestId'] ?? '') as String;
      if (requestId.isEmpty) return;

      final content = data['content'];
      final transactions = (content is Map<String, dynamic>)
          ? (content['transactions'] as Map<String, dynamic>? ?? {})
          : <String, dynamic>{};
      final status = (transactions['status'] ?? data['code'] ?? '') as String;

      await tenant.vtpassTransactions.doc(requestId).set({
        'status': status,
        'responseDescription': data['response_description'],
        'responseCode': data['code'],
        'transactionId': transactions['transactionId'],
        'productName': transactions['product_name'],
        'channel': transactions['channel'],
        'amount': transactions['amount'] ?? data['amount'],
        'webhookAt': FieldValue.serverTimestamp(),
        'raw': event,
      }, SetOptions(merge: true));

      if (kDebugMode) debugPrint('[Vtpass webhook] updated $requestId → $status');
    } catch (e) {
      if (kDebugMode) debugPrint('[Vtpass webhook] save failed: $e');
    }
  }
}
