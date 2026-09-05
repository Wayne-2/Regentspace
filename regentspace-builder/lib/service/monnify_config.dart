import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';

/// Monnify credentials — scoped per app-id via AppTenant.
/// Recommended priority:
/// 1) Firestore apps/{appId}/config/monnify (lets you rotate without app update)
/// 2) --dart-define MONNIFY_* (CI/sandbox)
/// 3) Fallback constants (sandbox placeholders — replace before prod).
///
/// Get these from https://app.monnify.com → Settings → API Keys & Contract Code.
/// Sandbox: https://sandbox.monnify.com  Live: https://api.monnify.com
class MonnifyConfig {
  MonnifyConfig._();

  static Map<String, dynamic>? _firestoreCache;

  static DocumentReference get _configDoc =>
      AppTenant.current.config.doc('monnify');

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
      final snap = await _configDoc.get();
      if (snap.exists && snap.data() != null) {
        _firestoreCache = snap.data() as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[MonnifyConfig] loaded from Firestore apps/${AppTenant.current.appId}/config/monnify');
        }
      } else {
        if (kDebugMode) debugPrint('[MonnifyConfig] Firestore config not found — using fallback');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[MonnifyConfig] Firestore load failed: $e — will retry after auth');
    }
  }

  static Future<void> ensureConfigured() async {
    if (isConfigured) return;
    await loadFromFirestore();
  }

  static bool get isConfigured =>
      apiKey.isNotEmpty && secretKey.isNotEmpty && contractCode.isNotEmpty && baseUrl.isNotEmpty;

  static void assertConfigured() {
    if (!isConfigured) {
      debugPrint('[MonnifyConfig] NOT CONFIGURED — set Firestore apps/${AppTenant.current.appId}/config/monnify or use --dart-define');
    }
  }
}
