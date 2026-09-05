import 'package:cloud_firestore/cloud_firestore.dart';

/// Multi-tenant service.
/// Every generated app has a unique [appId] that scopes all Firestore access.
/// This class is the single source of truth for the current app's tenant context.
class AppTenant {
  final String appId;
  final FirebaseFirestore db;

  AppTenant({required this.appId, FirebaseFirestore? db})
      : db = db ?? FirebaseFirestore.instance;

  // ─── Collection references (scoped by appId) ───

  /// The app's own document: apps/{appId}
  DocumentReference<Map<String, dynamic>> get appDoc =>
      db.collection('apps').doc(appId);

  /// Users collection: apps/{appId}/users
  CollectionReference<Map<String, dynamic>> get users =>
      appDoc.collection('users');

  /// Single user: apps/{appId}/users/{uid}
  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      users.doc(uid);

  /// Monnify accounts for a user: apps/{appId}/users/{uid}/monnifyAccounts
  CollectionReference<Map<String, dynamic>> monnifyAccounts(String uid) =>
      userDoc(uid).collection('monnifyAccounts');

  /// Notifications for a user: apps/{appId}/users/{uid}/notifications
  CollectionReference<Map<String, dynamic>> notifications(String uid) =>
      userDoc(uid).collection('notifications');

  /// Global Monnify reserved accounts mirror: apps/{appId}/monnify_reserved_accounts
  CollectionReference<Map<String, dynamic>> get monnifyReservedAccounts =>
      appDoc.collection('monnify_reserved_accounts');

  /// Monnify transactions: apps/{appId}/monnify_transactions
  CollectionReference<Map<String, dynamic>> get monnifyTransactions =>
      appDoc.collection('monnify_transactions');

  /// VTPass transactions: apps/{appId}/vtpass_transactions
  CollectionReference<Map<String, dynamic>> get vtpassTransactions =>
      appDoc.collection('vtpass_transactions');

  /// App config: apps/{appId}/config
  CollectionReference<Map<String, dynamic>> get config =>
      appDoc.collection('config');

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
