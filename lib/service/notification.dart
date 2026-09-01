import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';

// Legacy helper kept for backwards compat — now uses local + FCM.
Future<void> sendPush(String userId, String title, String body) async {
  // Local preview (instant, no server)
  await PushNotificationService.instance.showTestNotification(title: title, body: body);
  // For real remote push, call your backend which uses FCM HTTP v1:
  // POST https://fcm.googleapis.com/v1/projects/regentsspace/messages:send
  // with token/topic. See docs/push.md
  // ignore: avoid_print
  print("Notification shown locally: $title - $body for $userId");
}

/// Subscribe device to per-user topic for targeted pushes.
Future<void> subscribeToUserTopic(String userId) async {
  await FirebaseMessaging.instance.subscribeToTopic('user_$userId');
}

/// Subscribe to global topics for app-wide announcements
Future<void> subscribeToGlobalTopics() async {
  await FirebaseMessaging.instance.subscribeToTopic('all_users');
  await FirebaseMessaging.instance.subscribeToTopic('announcements');
}

/// Show an instant local notification (testing without FCM)
Future<void> showLocalNotification(String title, String body) async {
  await PushNotificationService.instance.showTestNotification(title: title, body: body);
}
