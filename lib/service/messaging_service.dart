import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';

/// Backward-compatible wrapper. Prefer PushNotificationService.instance directly.
class MessagingService {
  Future<void> init({void Function(RemoteMessage)? onMessage}) =>
      PushNotificationService.instance.init(onForegroundMessage: onMessage);

  Future<String?> getToken() => PushNotificationService.instance.getToken();
  Future<void> subscribeToTopic(String topic) =>
      PushNotificationService.instance.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      PushNotificationService.instance.unsubscribeFromTopic(topic);
}
