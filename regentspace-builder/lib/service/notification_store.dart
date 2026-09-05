import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_tenant.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'data': data,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isRead': isRead,
      };

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
        id: (m['id'] as String?) ?? '',
        title: (m['title'] as String?) ?? 'Notification',
        body: (m['body'] as String?) ?? '',
        data: (m['data'] as Map?)?.cast<String, dynamic>() ?? {},
        timestamp:
            DateTime.fromMillisecondsSinceEpoch((m['timestamp'] as int?) ?? 0),
        isRead: (m['isRead'] as bool?) ?? false,
      );
}

class NotificationStore {
  static final List<AppNotification> _items = [];
  static List<AppNotification> get items => List.unmodifiable(_items);

  static const String _boxName = 'notifications';
  static Box? _box;
  static final StreamController<List<AppNotification>> _localController =
      StreamController<List<AppNotification>>.broadcast();
  static Stream<List<AppNotification>> get localStream =>
      _localController.stream;

  static Future<void> initLocal() async {
    _box = await Hive.openBox(_boxName);
    _loadFromLocal();
  }

  static void _loadFromLocal() {
    if (_box == null) return;
    _items.clear();
    for (final key in _box!.keys) {
      final raw = _box!.get(key);
      if (raw is Map) {
        _items.add(AppNotification.fromMap(Map<String, dynamic>.from(raw)));
      }
    }
    _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _notifyListeners();
  }

  static void _notifyListeners() {
    if (!_localController.isClosed) {
      _localController.add(List.unmodifiable(_items));
    }
  }

  static Future<void> _saveToLocal(AppNotification n) async {
    if (_box == null) await initLocal();
    await _box!.put(n.id, n.toMap());
  }

  static Future<void> _removeFromLocal(String id) async {
    if (_box == null) await initLocal();
    await _box!.delete(id);
  }

  static Future<void> _clearLocal() async {
    if (_box == null) await initLocal();
    await _box!.clear();
  }

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      AppTenant.current.notifications(uid);

  static Future<void> addNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
    String? id,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await addForUser(uid: uid, title: title, body: body, data: data);
    } else {
      final notifId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final n = AppNotification(
        id: notifId,
        title: title,
        body: body,
        data: data,
        timestamp: DateTime.now(),
      );
      _items.removeWhere((e) => e.id == n.id);
      _items.insert(0, n);
      if (_items.length > 50) _items.removeLast();
      await _saveToLocal(n);
      _notifyListeners();
    }
  }

  static Future<void> deleteNotification(String uid, String notifId) async {
    _items.removeWhere((e) => e.id == notifId);
    await _removeFromLocal(notifId);
    _notifyListeners();
    try {
      await deleteForUser(uid, notifId);
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationStore] Firestore delete failed: $e');
    }
  }

  static Future<void> deleteMultiple(String uid, List<String> ids) async {
    for (final id in ids) {
      _items.removeWhere((e) => e.id == id);
      await _removeFromLocal(id);
    }
    _notifyListeners();
    for (final id in ids) {
      try {
        await deleteForUser(uid, id);
      } catch (e) {
        if (kDebugMode) debugPrint('[NotificationStore] Firestore delete failed: $e');
      }
    }
  }

  static Future<void> clearAll(String uid) async {
    _items.clear();
    await _clearLocal();
    _notifyListeners();
    try {
      await clearForUser(uid);
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationStore] Firestore clear failed: $e');
    }
  }

  static Future<void> markAsReadLocal(String uid, String notifId) async {
    final idx = _items.indexWhere((e) => e.id == notifId);
    if (idx != -1) {
      final old = _items[idx];
      _items[idx] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        data: old.data,
        timestamp: old.timestamp,
        isRead: true,
      );
      await _saveToLocal(_items[idx]);
      _notifyListeners();
    }
    try {
      await markAsRead(uid, notifId);
    } catch (_) {}
  }

  static Future<void> markAllReadLocal(String uid) async {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (!_items[i].isRead) {
        final old = _items[i];
        _items[i] = AppNotification(
          id: old.id,
          title: old.title,
          body: old.body,
          data: old.data,
          timestamp: old.timestamp,
          isRead: true,
        );
        await _saveToLocal(_items[i]);
        changed = true;
      }
    }
    if (changed) _notifyListeners();
    try {
      await markAllRead(uid);
    } catch (_) {}
  }

  static Future<void> syncFromFirestore(String uid) async {
    try {
      final snap = await _col(uid)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get(const GetOptions(source: Source.server));
      final remoteIds = <String>{};
      for (final doc in snap.docs) {
        final n = AppNotification.fromDoc(doc);
        remoteIds.add(n.id);
        final existing = _items.indexWhere((e) => e.id == n.id);
        if (existing == -1) {
          _items.insert(0, n);
          await _saveToLocal(n);
        }
      }
      _items.removeWhere((e) => !remoteIds.contains(e.id));
      for (final key in List.from(_box?.keys ?? [])) {
        if (!remoteIds.contains(key)) await _box?.delete(key);
      }
      _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[NotificationStore] syncFromFirestore failed: $e');
    }
  }

  static StreamSubscription? _firestoreSub;
  static void startFirestoreListener(String uid) {
    _firestoreSub?.cancel();
    _firestoreSub = _col(uid)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) async {
      final remoteIds = <String>{};
      for (final doc in snap.docs) {
        final n = AppNotification.fromDoc(doc);
        remoteIds.add(n.id);
        final existing = _items.indexWhere((e) => e.id == n.id);
        if (existing == -1) {
          _items.insert(0, n);
          await _saveToLocal(n);
        } else {
          if (_items[existing].isRead != n.isRead) {
            _items[existing] = n;
            await _saveToLocal(n);
          }
        }
      }
      _items.removeWhere((e) => !remoteIds.contains(e.id));
      _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notifyListeners();
    }, onError: (e) {
      if (kDebugMode) debugPrint('[NotificationStore] Firestore listener error: $e');
    });
  }

  static void stopFirestoreListener() {
    _firestoreSub?.cancel();
    _firestoreSub = null;
  }

  static void addFromRemoteMessage(RemoteMessage m) {
    final n = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: m.notification?.title ?? m.data['title'] ?? 'Notification',
      body: m.notification?.body ?? m.data['body'] ?? '',
      data: m.data,
      timestamp: DateTime.now(),
    );
    addNotification(title: n.title, body: n.body, data: n.data, id: n.id);
  }

  static void addLocal(String title, String body) {
    addNotification(title: title, body: body);
  }

  static void clear() {
    _items.clear();
    _clearLocal();
    _notifyListeners();
  }

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
    final batch = AppTenant.current.db.batch();
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
    final batch = AppTenant.current.db.batch();
    for (final d in q.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
