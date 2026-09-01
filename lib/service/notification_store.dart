import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      title: (m['title'] as String?) ?? 'Notification',
      body: (m['body'] as String?) ?? '',
      data: (m['data'] as Map?)?.cast<String, dynamic>() ?? {},
      timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: (m['isRead'] as bool?) ?? false,
    );
  }
}

class NotificationStore {
  static final List<AppNotification> _items = [];
  static List<AppNotification> get items => List.unmodifiable(_items);

  // In-memory fallback (pre-Firestore, no uid)
  static void addFromRemoteMessage(RemoteMessage m) {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: m.notification?.title ?? m.data['title'] ?? 'Notification',
      body: m.notification?.body ?? m.data['body'] ?? '',
      data: m.data,
      timestamp: DateTime.now(),
    );
    _items.insert(0, n);
    if (_items.length > 50) _items.removeLast();
    // Also persist per-user if logged in
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      addForUser(uid: uid, title: n.title, body: n.body, data: n.data).catchError((e) {
        if (kDebugMode) debugPrint('[NotificationStore] Firestore persist failed: $e');
      });
    }
  }

  static void addLocal(String title, String body) {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: {},
      timestamp: DateTime.now(),
    );
    _items.insert(0, n);
    if (_items.length > 50) _items.removeLast();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      addForUser(uid: uid, title: title, body: body, data: {}).catchError((e) {
        if (kDebugMode) debugPrint('[NotificationStore] Firestore persist failed: $e');
      });
    }
  }

  static void clear() => _items.clear();

  // ---------------- Firestore per-user ----------------

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications');

  /// Persist notification for user — called from AppNotifications._show + FCM handlers
  static Future<void> addForUser({
    required String uid,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      await _col(uid).add({
        'title': title,
        'body': body,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationStore] addForUser failed: $e');
      rethrow;
    }
  }

  static Stream<List<AppNotification>> watchForUser(String uid) {
    return _col(uid)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppNotification.fromDoc(d)).toList());
  }

  static Stream<int> watchUnreadCount(String uid) {
    return _col(uid).where('isRead', isEqualTo: false).snapshots().map((s) => s.docs.length);
  }

  static Future<void> markAsRead(String uid, String notifId) async {
    await _col(uid).doc(notifId).update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
  }

  static Future<void> markAllRead(String uid) async {
    final q = await _col(uid).where('isRead', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  static Future<void> deleteForUser(String uid, String notifId) async {
    await _col(uid).doc(notifId).delete();
  }

  static Future<void> clearForUser(String uid) async {
    final q = await _col(uid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in q.docs) batch.delete(d.reference);
    await batch.commit();
  }
}
