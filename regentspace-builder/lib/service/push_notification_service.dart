import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_store.dart';
import 'user_repository.dart';

/// Central push notification service — shared across all generated apps.
/// Channel name is templated via {{FCM_CHANNEL}} at build time.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

  void Function(Map<String, dynamic> data)? onNotificationTap;

  /// [channelId] and [channelName] come from BuildConfig at init time.
  Future<void> init({
    required String channelId,
    required String channelName,
    void Function(RemoteMessage)? onForegroundMessage,
  }) async {
    if (_initialized) return;
    _initialized = true;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        if (res.payload != null && onNotificationTap != null) {
          try {
            // payload routing handled by caller
          } catch (_) {}
        }
        if (kDebugMode) debugPrint('Local tap payload: ${res.payload}');
      },
    );

    final channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'General notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) debugPrint('FCM permission: ${settings.authorizationStatus}');

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _fcm.getToken();
    if (kDebugMode) debugPrint('FCM token: $token');
    if (token != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await UserRepository.instance.saveFcmToken(uid: uid, token: token);
          if (kDebugMode) debugPrint('[Push] FCM token saved to Firestore');
        } catch (e) {
          if (kDebugMode) debugPrint('[Push] Failed to save FCM token: $e');
        }
      }
    }
    _fcm.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) debugPrint('FCM token refreshed: $newToken');
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await UserRepository.instance.saveFcmToken(uid: uid, token: newToken);
        } catch (_) {}
      }
    });

    _onMessageSub =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint(
            'FCM onMessage: ${message.notification?.title} | data: ${message.data}');
      }
      NotificationStore.addFromRemoteMessage(message);
      await _showLocalNotification(channelId, channelName, message);
      if (onForegroundMessage != null) onForegroundMessage(message);
    });

    _onOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('FCM onMessageOpenedApp: ${message.data}');
      NotificationStore.addFromRemoteMessage(message);
      _handleTap(message);
    });

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      if (kDebugMode) debugPrint('FCM getInitialMessage: ${initial.data}');
      NotificationStore.addFromRemoteMessage(initial);
      Future.delayed(const Duration(seconds: 1), () => _handleTap(initial));
    }
  }

  Future<void> _showLocalNotification(
    String channelId,
    String channelName,
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF740690),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _local.show(
      notification.hashCode,
      title,
      body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleTap(RemoteMessage message) {
    if (onNotificationTap != null) onNotificationTap!(message.data);
  }

  Future<void> showTestNotification({
    String title = 'Test notification',
    String body = 'Push is working!',
    String channelId = 'regentspace_channel',
    String channelName = 'Regentspace Notifications',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF740690),
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());
    await _local.show(8888, title, body, details, payload: 'test');
  }

  Future<String?> getToken() => _fcm.getToken();
  Future<void> deleteToken() => _fcm.deleteToken();
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  /// Re-request notification permission and save FCM token.
  /// Called after login to ensure token is persisted.
  Future<void> ensurePermissionAndToken() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
    try {
      final token = await _fcm.getToken();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (token != null && uid != null) {
        await UserRepository.instance.saveFcmToken(uid: uid, token: token);
        if (kDebugMode) debugPrint('[Push] FCM token saved after login');
      }
    } catch (_) {}
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
  }
}
