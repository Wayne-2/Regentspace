import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_store.dart';

/// Central push notification service for the app.
/// Handles:
/// * Permission request (Android 13+, iOS)
/// * FCM token (get/refresh)
/// * Foreground display via flutter_local_notifications
/// * Background/terminated tap handling
/// * Topic subscription
/// * Local test notifications
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;

  // Callback when user taps a notification (payload = data)
  void Function(Map<String, dynamic> data)? onNotificationTap;

  Future<void> init({void Function(RemoteMessage)? onForegroundMessage}) async {
    if (_initialized) return;
    _initialized = true;

    // 1. Init local notifications — use notification_display_icon for status bar (launcher stays @mipmap/ic_launcher)
    const androidInit = AndroidInitializationSettings('@mipmap/notification_display_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        // payload is data string
        if (res.payload != null && onNotificationTap != null) {
          try {
            // payload is simple string, try to route
          } catch (_) {}
        }
        if (kDebugMode) debugPrint('Local tap payload: ${res.payload}');
      },
    );

    // Create Android channel
    const channel = AndroidNotificationChannel(
      'regentspace_channel',
      'Regentspace Notifications',
      description: 'General notifications for Regentspace',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    if (kDebugMode) debugPrint('FCM permission: ${settings.authorizationStatus}');

    // For Android 13+, also request via local plugin
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS foreground presentation
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Token
    final token = await _fcm.getToken();
    if (kDebugMode) debugPrint('FCM token: $token');
    _fcm.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('FCM token refreshed: $newToken');
      // TODO: send to server / Firestore
    });

    // 4. Foreground handler - show local notification
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('FCM onMessage: ${message.notification?.title} | data: ${message.data}');
      }
      NotificationStore.addFromRemoteMessage(message);
      await _showLocalNotification(message);
      if (onForegroundMessage != null) onForegroundMessage(message);
    });

    // 5. Background tap (app in background)
    _onOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('FCM onMessageOpenedApp: ${message.data}');
      NotificationStore.addFromRemoteMessage(message);
      _handleTap(message);
    });

    // 6. Terminated state
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      if (kDebugMode) debugPrint('FCM getInitialMessage: ${initial.data}');
      NotificationStore.addFromRemoteMessage(initial);
      // Delay to ensure navigator ready
      Future.delayed(const Duration(seconds: 1), () => _handleTap(initial));
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    // Use title/body from notification or data
    final title = notification?.title ?? message.data['title'] ?? 'Regentspace';
    final body = notification?.body ?? message.data['body'] ?? '';
    if (title.isEmpty && body.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'regentspace_channel',
      'Regentspace Notifications',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/notification_display_icon',
      color: Color(0xFF740690),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _local.show(
      notification.hashCode,
      title,
      body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleTap(RemoteMessage message) {
    // Route based on data e.g. message.data['route']
    if (onNotificationTap != null) onNotificationTap!(message.data);
  }

  /// Show a local test notification instantly (no FCM needed)
  Future<void> showTestNotification({String title = 'Test notification', String body = 'Push is working!'}) async {
    NotificationStore.addLocal(title, body);
    const androidDetails = AndroidNotificationDetails(
      'regentspace_channel',
      'Regentspace Notifications',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/notification_display_icon',
      color: Color(0xFF740690),
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _local.show(8888, title, body, details, payload: 'test');
  }

  Future<String?> getToken() => _fcm.getToken();
  Future<void> deleteToken() => _fcm.deleteToken();
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _fcm.unsubscribeFromTopic(topic);

  void dispose() {
    _onMessageSub?.cancel();
    _onOpenedAppSub?.cancel();
  }
}
