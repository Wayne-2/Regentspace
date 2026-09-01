import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Monnify credentials — **never hardcode live keys in app**.
/// Recommended priority:
/// 1) Firestore `config/monnify` (lets you rotate without app update)
/// 2) --dart-define MONNIFY_* (CI/sandbox)
/// 3) Fallback constants (sandbox placeholders — replace before prod).
///
/// Get these from https://app.monnify.com → Settings → API Keys & Contract Code.
/// Sandbox: https://sandbox.monnify.com  Live: https://api.monnify.com
class MonnifyConfig {
  MonnifyConfig._();

  /// Base URL — Firestore takes priority (you asked for Firestore, not dart-define).
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

  /// Contract code from Monnify dashboard (required for reserved accounts).
  static String get contractCode {
    final fs = _firestoreCache?['contractCode'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('MONNIFY_CONTRACT_CODE');
    if (env.isNotEmpty) return env;
    return '';
  }

  /// Set to true to call Monnify directly from app (sandbox only).
  /// For prod, set false and use Firebase Functions proxy (see lib/service/monnify_service.dart).
  static bool get useDirect {
    final fs = _firestoreCache?['useDirect'];
    if (fs is bool) return fs;
    if (fs is String) return fs.toLowerCase() == 'true';
    // Fallback to dart-define only if Firestore not set
    const env = String.fromEnvironment('MONNIFY_USE_DIRECT');
    if (env.isNotEmpty) return env.toLowerCase() == 'true';
    return true; // sandbox default
  }

  /// Cloud Function names when !useDirect
  static const String fnCreateReservedAccount = 'monnifyCreateReservedAccount';
  static const String fnDisburse = 'monnifyDisburse';
  static const String fnWebhook = 'monnifyWebhook';

  static Map<String, dynamic>? _firestoreCache;

  /// Call once on app start (required). Firestore `config/monnify` is now primary source.
  /// Note: at app start user is unauth before login, so read may fail with permission-denied
  /// if rules require auth. We retry after auth in `ensureConfigured()`.
  static Future<void> loadFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance.doc('config/monnify').get();
      if (snap.exists && snap.data() != null) {
        _firestoreCache = snap.data();
        debugPrint('[MonnifyConfig] loaded from Firestore config/monnify: baseUrl=${baseUrl} contract=${contractCode.isEmpty ? "EMPTY" : contractCode.substring(0, contractCode.length.clamp(0, 8))}... useDirect=$useDirect apiKey=${apiKey.isEmpty ? "EMPTY" : "SET"}');
        if (!isConfigured) {
          debugPrint('[MonnifyConfig] Firestore doc exists but missing fields — check apiKey/secretKey/contractCode are non-empty strings');
        }
      } else {
        debugPrint('[MonnifyConfig] Firestore config/monnify not found — using fallback (dart-define empty)');
      }
    } catch (e) {
      // Permission-denied at cold start is expected when rules require auth (see debug log at 13:00:27.991)
      // Will retry after login/signup via ensureConfigured().
      debugPrint('[MonnifyConfig] Firestore load failed: $e — will retry after auth if needed');
    }
  }

  /// Ensure config is loaded — retries Firestore fetch if still empty.
  /// Call before any Monnify API that requires contractCode/apiKey.
  static Future<void> ensureConfigured() async {
    if (isConfigured) return;
    debugPrint('[MonnifyConfig] not configured, retrying Firestore load...');
    await loadFromFirestore();
    if (!isConfigured) {
      debugPrint('[MonnifyConfig] still not configured — Firestore config/monnify missing or permission-denied. Check rules allow read for authenticated user and doc contains {baseUrl, apiKey, secretKey, contractCode}');
    }
  }

  static bool get isConfigured => apiKey.isNotEmpty && secretKey.isNotEmpty && contractCode.isNotEmpty && baseUrl.isNotEmpty;

  static void assertConfigured() {
    if (!isConfigured) {
      debugPrint('''
[MonnifyConfig] ⚠️ NOT CONFIGURED
Set via ONE of:
 - Firestore doc config/monnify {baseUrl, apiKey, secretKey, contractCode, useDirect}
 - --dart-define=MONNIFY_API_KEY=... --dart-define=MONNIFY_SECRET_KEY=... --dart-define=MONNIFY_CONTRACT_CODE=... [--dart-define=MONNIFY_BASE_URL=https://sandbox.monnify.com]
Create test keys at https://sandbox.monnify.com
''');
    }
  }
}
