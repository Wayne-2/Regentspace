import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';

/// VTPass credentials — shared across all generated apps.
/// Firestore path: apps/regentspace-builder/config/vtpass
/// Keys from https://vtpass.com/account (live) or https://sandbox.vtpass.com/account (sandbox).
class VtpassConfig {
  VtpassConfig._();

  static Map<String, dynamic>? _firestoreCache;

  static DocumentReference get _configDoc =>
      AppTenant.current.sharedConfig.doc('vtpass');

  /// Live: https://vtpass.com/api  Sandbox: https://sandbox.vtpass.com/api
  static String get baseUrl {
    final fs = _firestoreCache?['baseUrl'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('VTPASS_BASE_URL');
    if (env.isNotEmpty) return env;
    return 'https://sandbox.vtpass.com/api';
  }

  /// Static API key from VTPass dashboard
  static String get apiKey {
    final fs = _firestoreCache?['apiKey'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('VTPASS_API_KEY');
    if (env.isNotEmpty) return env;
    return '';
  }

  /// Secret key (for POST requests) — starts with SK_
  static String get secretKey {
    final fs = _firestoreCache?['secretKey'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('VTPASS_SECRET_KEY');
    if (env.isNotEmpty) return env;
    return '';
  }

  /// Public key (for GET requests) — starts with PK_
  static String get publicKey {
    final fs = _firestoreCache?['publicKey'] as String?;
    if (fs != null && fs.isNotEmpty) return fs;
    const env = String.fromEnvironment('VTPASS_PUBLIC_KEY');
    if (env.isNotEmpty) return env;
    return '';
  }

  static bool get isConfigured => apiKey.isNotEmpty && secretKey.isNotEmpty;

  static Future<void> loadFromFirestore() async {
    try {
      final path = 'apps/${AppTenant.platformAppId}/config/vtpass';
      if (kDebugMode) print('[VtpassConfig] Loading from Firestore: $path');
      final snap = await _configDoc.get();
      if (snap.exists && snap.data() != null) {
        _firestoreCache = snap.data() as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[VtpassConfig] LOADED from $path');
        }
      } else {
        if (kDebugMode) debugPrint('[VtpassConfig] DOC NOT FOUND at $path');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[VtpassConfig] Firestore load failed: $e');
    }
  }

  static Future<void> ensureConfigured() async {
    if (isConfigured) return;
    await loadFromFirestore();
  }

  static void assertConfigured() {
    if (!isConfigured) {
      debugPrint('[VtpassConfig] NOT CONFIGURED — set Firestore apps/${AppTenant.platformAppId}/config/vtpass or use --dart-define');
    }
  }
}
