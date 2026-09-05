import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';

/// Firestore user profiles — scoped under apps/{appId}/users/{uid}.
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  /// Users collection scoped to current app tenant
  CollectionReference<Map<String, dynamic>> get _users =>
      AppTenant.current.users;

  Future<void> saveEmailUser({
    required User user,
    required String username,
    required String phone,
  }) async {
    final data = {
      'uid': user.uid,
      'email': (user.email ?? '').trim().toLowerCase(),
      'username': username.trim(),
      'displayName': username.trim(),
      'phone': phone.trim(),
      'photoUrl': user.photoURL ?? '',
      'provider': 'password',
      'emailVerified': user.emailVerified,
      'phoneNumberAuth': user.phoneNumber ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    await _saveMerged(user.uid, data, isNewUser: true);
    if (kDebugMode) {
      debugPrint('[UserRepository] saved email user ${user.uid}');
    }
  }

  Future<void> saveGoogleUser({
    required UserCredential credential,
  }) async {
    final user = credential.user;
    if (user == null) throw StateError('No Firebase user after Google sign-in');
    final isNew = credential.additionalUserInfo?.isNewUser ?? false;

    final googleProfile = credential.additionalUserInfo?.profile;
    final email =
        (user.email ?? (googleProfile?['email'] as String?) ?? '')
            .trim()
            .toLowerCase();
    final rawName = (user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : null) ??
        (googleProfile?['name'] as String?)?.trim() ??
        email.split('@').first;
    final username = rawName.isEmpty ? 'User' : rawName;
    var phone =
        (user.phoneNumber ?? (googleProfile?['phone'] as String?) ?? '')
            .trim();
    final photoUrl =
        (user.photoURL ?? (googleProfile?['picture'] as String?) ?? '')
            .trim();
    final provider = credential.credential?.providerId ?? 'google.com';

    if (phone.isEmpty) {
      try {
        final snap = await _users.doc(user.uid).get();
        final existingPhone =
            (snap.data()?['phone'] as String?)?.trim() ?? '';
        if (existingPhone.isNotEmpty) phone = existingPhone;
      } catch (_) {}
    }

    final data = {
      'uid': user.uid,
      'email': email,
      'username': username,
      'displayName': username,
      if (phone.isNotEmpty) 'phone': phone,
      'photoUrl': photoUrl,
      'provider': provider,
      'googleProfile': googleProfile,
      'emailVerified': user.emailVerified,
      'phoneNumberAuth': user.phoneNumber ?? '',
      'createdAt': isNew ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isNewUser': isNew,
    }..removeWhere((_, v) => v == null);

    await _saveMerged(user.uid, data, isNewUser: isNew);
    if (kDebugMode) {
      debugPrint('[UserRepository] saved google user ${user.uid} isNew=$isNew');
    }
  }

  Future<bool> needsPhone(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      final phone = (snap.data()?['phone'] as String?)?.trim() ?? '';
      return phone.isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> touchLogin(User user) async {
    try {
      await _users.doc(user.uid).set({
        'uid': user.uid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] touchLogin failed: $e');
    }
  }

  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _users.doc(uid).set({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] saveFcmToken failed: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) =>
      _users.doc(uid).get();

  /// Ensure a minimal user doc exists (call after login).
  Future<void> ensureUserDoc(User user) async {
    try {
      await _users.doc(user.uid).set({
        'uid': user.uid,
        'email': (user.email ?? '').trim().toLowerCase(),
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] ensureUserDoc failed: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) =>
      _users.doc(uid).snapshots();

  Future<void> updateProfile(String uid, Map<String, dynamic> patch) =>
      _users.doc(uid).set(
        {...patch, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

  Future<void> _saveMerged(
    String uid,
    Map<String, dynamic> data, {
    required bool isNewUser,
  }) async {
    final doc = _users.doc(uid);
    if (isNewUser) {
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set(data, SetOptions(merge: false));
        return;
      }
    }
    final toMerge = Map<String, dynamic>.from(data);
    if (!isNewUser) toMerge.remove('createdAt');
    if (toMerge.containsKey('phone') &&
        (toMerge['phone'] as String).trim().isEmpty) {
      toMerge.remove('phone');
    }
    await doc.set(toMerge, SetOptions(merge: true));
  }
}
