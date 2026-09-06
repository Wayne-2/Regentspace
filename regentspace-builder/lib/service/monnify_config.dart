import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';

/// Monnify credentials — shared across all generated apps.
/// Firestore path: apps/regentspace-builder/config/monnify
/// Recommended priority:
/// 1) Firestore apps/regentspace-builder/config/monnify (lets you rotate without app update)
/// 2) --dart-define MONNIFY_* (CI/sandbox)
/// 3) Fallback constants (sandbox placeholders — replace before prod).
///
/// Get these from https://app.monnify.com → Settings → API Keys & Contract Code.
/// Sandbox: https://sandbox.monnify.com  Live: https://api.monnify.com
class MonnifyConfig {
  MonnifyConfig._();

  static Map<String, dynamic>? _firestoreCache;

  static DocumentReference get _configDoc =>
      AppTenant.current.sharedConfig.doc('monnify');

  static String get baseUrl {
    final fs = _firestoreCache?['baseUrl'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('MONNIFY_BASE_URL');
    if (env.isNotEmpty) return env;
    return 'https://sandbox.monnify.com';
  }

  static String get apiKey {
    final fs = _firestoreCache?['apiKey'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('MONNIFY_API_KEY');
    if (env.isNotEmpty) return env;
    return '';
  }

  static String get secretKey {
    final fs = _firestoreCache?['secretKey'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('MONNIFY_SECRET_KEY');
    if (env.isNotEmpty) return env;
    return '';
  }

  static String get contractCode {
    final fs = _firestoreCache?['contractCode'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('MONNIFY_CONTRACT_CODE');
    if (env.isNotEmpty) return env;
    return '';
  }

  static bool get useDirect {
    final fs = _firestoreCache?['useDirect'];
    if (fs is bool) return fs;
    if (fs is String) return fs.toLowerCase() == 'true';
    const env = String.fromEnvironment('MONNIFY_USE_DIRECT');
    if (env.isNotEmpty) return env.toLowerCase() == 'true';
    return true;
  }

  static const String fnCreateReservedAccount = 'monnifyCreateReservedAccount';
  static const String fnDisburse = 'monnifyDisburse';
  static const String fnWebhook = 'monnifyWebhook';

  static Future<void> loadFromFirestore() async {
    try {
      final path = 'apps/${AppTenant.platformAppId}/config/monnify';
      print('[MonnifyConfig] Loading from Firestore path: $path');
      final snap = await _configDoc.get();
      if (snap.exists && snap.data() != null) {
        _firestoreCache = snap.data() as Map<String, dynamic>;
        print('[MonnifyConfig] LOADED OK — baseUrl=$baseUrl, apiKey=${apiKey.substring(0, apiKey.length > 8 ? 8 : apiKey.length)}..., contractCode=${contractCode.substring(0, contractCode.length > 4 ? 4 : contractCode.length)}..., useDirect=$useDirect');
      } else {
        print('[MonnifyConfig] DOC NOT FOUND at $path — create it in Firebase Console with fields: baseUrl, apiKey, secretKey, contractCode, useDirect');
      }
    } catch (e) {
      print('[MonnifyConfig] LOAD FAILED: $e');
    }
  }

  static Future<void> ensureConfigured() async {
    if (isConfigured) return;
    await loadFromFirestore();
  }

  static bool get isConfigured =>
      apiKey.isNotEmpty && secretKey.isNotEmpty && contractCode.isNotEmpty && baseUrl.isNotEmpty;

  static String get debugStatus => 'MonnifyConfig[isConfigured=$isConfigured, baseUrl=$baseUrl, apiKey=${apiKey.isEmpty ? "EMPTY" : "${apiKey.substring(0, apiKey.length > 8 ? 8 : apiKey.length)}..."}, secretKey=${secretKey.isEmpty ? "EMPTY" : "SET"}, contractCode=${contractCode.isEmpty ? "EMPTY" : contractCode}]';

  static void assertConfigured() {
    if (!isConfigured) {
      print('[MonnifyConfig] NOT CONFIGURED — $debugStatus');
    }
  }
}
