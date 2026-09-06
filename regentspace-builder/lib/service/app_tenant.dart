import 'package:cloud_firestore/cloud_firestore.dart';

/// Multi-tenant service.
/// Every generated app has a unique [appId] that scopes all Firestore access.
///
/// Firestore structure (all under apps/regentspace-builder/):
///   apps/regentspace-builder/config/monnify  — shared Monnify credentials
///   apps/regentspace-builder/config/vtpass   — shared VTPass credentials
///   apps/regentspace-builder/{appId}/                 — per-app document
///   apps/regentspace-builder/{appId}/users/{uid}      — per-app user profiles
///   apps/regentspace-builder/{appId}/monnify_reserved_accounts/ — per-app Monnify accounts
///   apps/regentspace-builder/{appId}/vtpass_transactions/       — per-app VTPass transactions
class AppTenant {
  static const String platformAppId = 'regentspace-builder';

  final String appId;
  final FirebaseFirestore db;

  AppTenant({required this.appId, FirebaseFirestore? db})
      : db = db ?? FirebaseFirestore.instance;

  // ─── Platform root document ───

  /// Platform root: apps/regentspace-builder
  DocumentReference<Map<String, dynamic>> get platformDoc =>
      db.collection('apps').doc(platformAppId);

  // ─── Shared platform config (read-only for generated apps) ───

  /// Shared config collection: apps/regentspace-builder/config
  CollectionReference<Map<String, dynamic>> get sharedConfig =>
      platformDoc.collection('config');

  // ─── Per-app document root ───

  /// The app's own document: apps/regentspace-builder/{appId}
  DocumentReference<Map<String, dynamic>> get appDoc =>
      platformDoc.collection('apps').doc(appId);

  /// Users collection: apps/regentspace-builder/{appId}/users
  CollectionReference<Map<String, dynamic>> get users =>
      appDoc.collection('users');

  /// Single user: apps/regentspace-builder/{appId}/users/{uid}
  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      users.doc(uid);

  /// Monnify accounts for a user: apps/regentspace-builder/{appId}/users/{uid}/monnifyAccounts
  CollectionReference<Map<String, dynamic>> monnifyAccounts(String uid) =>
      userDoc(uid).collection('monnifyAccounts');

  /// Notifications for a user: apps/regentspace-builder/{appId}/users/{uid}/notifications
  CollectionReference<Map<String, dynamic>> notifications(String uid) =>
      userDoc(uid).collection('notifications');

  /// Global Monnify reserved accounts mirror: apps/regentspace-builder/{appId}/monnify_reserved_accounts
  CollectionReference<Map<String, dynamic>> get monnifyReservedAccounts =>
      appDoc.collection('monnify_reserved_accounts');

  /// Monnify transactions: apps/regentspace-builder/{appId}/monnify_transactions
  CollectionReference<Map<String, dynamic>> get monnifyTransactions =>
      appDoc.collection('monnify_transactions');

  /// VTPass transactions: apps/regentspace-builder/{appId}/vtpass_transactions
  CollectionReference<Map<String, dynamic>> get vtpassTransactions =>
      appDoc.collection('vtpass_transactions');

  // ─── Helper: register a new app ───

  Future<void> registerApp({
    required String createdBy,
    required String appName,
    required String packageName,
    Map<String, dynamic>? extra,
  }) async {
    await appDoc.set({
      'appName': appName,
      'packageName': packageName,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      ...?extra,
    });
  }

  // ─── Helper: check if app exists ───

  Future<bool> appExists() async {
    final doc = await appDoc.get();
    return doc.exists;
  }

  // ─── Static factory ───

  static AppTenant? _instance;

  /// Returns the current app ID (must be initialized first).
  static String get currentAppId => current.appId;

  static AppTenant init(String appId, {FirebaseFirestore? db}) {
    _instance = AppTenant(appId: appId, db: db);
    return _instance!;
  }

  static AppTenant get current {
    if (_instance == null) {
      throw StateError(
        'AppTenant not initialized. Call AppTenant.init(appId) first.',
      );
    }
    return _instance!;
  }
}
