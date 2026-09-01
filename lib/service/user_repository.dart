import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firestore `users/{uid}` — same shape whether user came from
/// email/password form or Google. Keep create-account fields as source of truth.
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  /// Create/update profile from email/password flow.
  /// Mirrors exactly what the Create Account page asks for.
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
    if (kDebugMode) debugPrint('[UserRepository] saved email user ${user.uid} -> $username / $phone');
  }

  /// Create/update profile from Google credential.
  /// Extracts the SAME fields that the create-account form requests,
  /// falling back to email prefix when Google doesn't supply them.
  /// NOTE: Google OAuth does NOT expose phoneNumber via standard profile scope.
  /// We preserve any existing Firestore `phone` and leave it empty so caller can
  /// prompt the user to fill it afterward (see collectMissingPhoneIfNeeded).
  Future<void> saveGoogleUser({
    required UserCredential credential,
  }) async {
    final user = credential.user;
    if (user == null) throw StateError('No Firebase user after Google sign-in');
    final isNew = credential.additionalUserInfo?.isNewUser ?? false;

    // Google API extraction — mirrors create-account fields
    final googleProfile = credential.additionalUserInfo?.profile; // Map from Google id_token
    final email = (user.email ?? (googleProfile?['email'] as String?) ?? '').trim().toLowerCase();
    // username: Firebase displayName → Google profile name → email prefix
    final rawName = (user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : null) ??
        (googleProfile?['name'] as String?)?.trim() ??
        email.split('@').first;
    final username = rawName.isEmpty ? 'User' : rawName;
    // phone: Google API never returns phone via normal OAuth scope.
    // Do NOT overwrite existing phone with empty string.
    var phone = (user.phoneNumber ?? (googleProfile?['phone'] as String?) ?? '').trim();
    final photoUrl = (user.photoURL ?? (googleProfile?['picture'] as String?) ?? '').trim();
    final provider = credential.credential?.providerId ?? 'google.com';

    // Preserve existing phone if Google provides nothing
    if (phone.isEmpty) {
      try {
        final snap = await _users.doc(user.uid).get();
        final existingPhone = (snap.data()?['phone'] as String?)?.trim() ?? '';
        if (existingPhone.isNotEmpty) phone = existingPhone;
      } catch (_) {}
    }

    final data = {
      'uid': user.uid,
      'email': email,
      'username': username,
      'displayName': username,
      // Only include phone key if we actually have a value — avoids wiping existing phone on merge
      if (phone.isNotEmpty) 'phone': phone,
      'photoUrl': photoUrl,
      'provider': provider,
      'googleProfile': googleProfile, // keep raw for debugging / future phone extraction
      'emailVerified': user.emailVerified, // Google emails are pre-verified (true)
      'phoneNumberAuth': user.phoneNumber ?? '',
      'createdAt': isNew ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isNewUser': isNew,
    }..removeWhere((_, v) => v == null);

    await _saveMerged(user.uid, data, isNewUser: isNew);
    if (kDebugMode) debugPrint('[UserRepository] saved google user ${user.uid} isNew=$isNew -> $username / $email / phone="$phone" emailVerified=${user.emailVerified}');
  }

  /// Returns true if user document exists but phone is missing/empty — caller should prompt user.
  Future<bool> needsPhone(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      final phone = (snap.data()?['phone'] as String?)?.trim() ?? '';
      return phone.isEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Ensure existing email user doc is touched on subsequent login (lastLoginAt, emailVerified, etc.)
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

  /// Store FCM token alongside profile for targeted pushes (user_<uid> topic already handled elsewhere)
  Future<void> saveFcmToken({required String uid, required String token}) async {
    try {
      await _users.doc(uid).set({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] saveFcmToken failed: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) => _users.doc(uid).get();
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) => _users.doc(uid).snapshots();

  Future<void> updateProfile(String uid, Map<String, dynamic> patch) =>
      _users.doc(uid).set({...patch, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

  Future<void> _saveMerged(String uid, Map<String, dynamic> data, {required bool isNewUser}) async {
    final doc = _users.doc(uid);
    if (isNewUser) {
      // create only if missing — preserves original createdAt for returning users
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set(data, SetOptions(merge: false));
        return;
      }
    }
    // merge (upsert) — never overwrite createdAt if already present for returning users
    final toMerge = Map<String, dynamic>.from(data);
    if (!isNewUser) toMerge.remove('createdAt');
    // Never clobber existing non-empty phone/username with empty value on merge
    if (toMerge.containsKey('phone') && (toMerge['phone'] as String).trim().isEmpty) {
      toMerge.remove('phone');
    }
    await doc.set(toMerge, SetOptions(merge: true));
  }
}
