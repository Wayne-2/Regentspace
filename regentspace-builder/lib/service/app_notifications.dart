import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';
import 'notification_store.dart';
import 'push_notification_service.dart';

/// Single source of truth for every user-facing notification.
/// Placeholder syntax: {key} — replaced at call-site via [_t].
/// App name comes from BuildConfig at runtime.
class AppNotifications {
  AppNotifications._();

  static String _appName = 'Regentspace';

  static void setAppName(String name) => _appName = name;

  static String _t(String template, [Map<String, String> vars = const {}]) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }

  static String _displayName(User? user, {String? fallback}) {
    final raw =
        (user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!.trim()
                : null) ??
            fallback?.trim();
    if (raw != null && raw.isNotEmpty) return raw.split(RegExp(r'\s+')).first;
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  static Future<void> _show(String title, String body) async {
    if (kDebugMode) debugPrint('[AppNotifications] $title — $body');
    await PushNotificationService.instance.showTestNotification(
      title: title,
      body: body,
    );
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await NotificationStore.addForUser(
          uid: uid,
          title: title,
          body: body,
          data: {'source': 'app_notifications'},
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[AppNotifications] Firestore persist failed: $e');
      }
    }
  }

  // ─── Auth ───

  static Future<void> welcomeFirstTime({User? user, String? fallbackName}) async {
    final name = _displayName(user, fallback: fallbackName);
    await _show(
      _t('Welcome to $_appName, {name}!', {'name': name}),
      _t("Your account is ready, {name}. Let's take off!", {'name': name}),
    );
  }

  static Future<void> loginSuccess({User? user}) async {
    final name = _displayName(user);
    await _show('Welcome back, $name', '$_appName is ready for you.');
  }

  static Future<void> googleFirstTime({User? user}) async {
    final name = _displayName(user);
    await _show(
      'Welcome to $_appName, $name!',
      'Your Google account is linked, $name. Dive in!',
    );
  }

  // ─── Wallet / Virtual Account ───

  static Future<void> virtualAccountCreated({required String bankName, required String accountNumber}) =>
      _show('Virtual account created', 'Your $bankName account $accountNumber is active.');

  static Future<void> virtualAccountFailed() =>
      _show('Could not create account', 'Please try again or choose another bank.');

  static Future<void> walletFunded({required String amount, String? bankName}) =>
      _show('Wallet funded — ₦$amount', bankName == null ? '₦$amount was added to your wallet.' : '₦$amount from $bankName is now available.');

  static Future<void> transferSuccess({required String amount, required String recipient}) =>
      _show('Transfer successful', '₦$amount to $recipient completed.');

  static Future<void> transferFailed({String? reason}) =>
      _show('Transfer failed', reason ?? 'Your transfer could not be completed.');

  static Future<void> lowBalance({required String balance}) =>
      _show('Low balance', 'Your balance is ₦$balance.');

  static Future<void> interestCredited({required String amount, required String percent}) =>
      _show('Interest credited — ₦$amount', 'You earned $percent interest.');

  static Future<void> rateUpdated({required String network, required String newRate}) =>
      _show('Rate updated', '$network is now $newRate.');

  // ─── Invites / Growth ───

  // ─── VTPass Services ───

  static Future<void> airtimePurchased({required String network, required String amount}) =>
      _show('Airtime purchased', '₦$amount $network airtime was successful.');

  static Future<void> dataPurchased({required String network}) =>
      _show('Data purchased', '$network data subscription is active.');

  static Future<void> cableTvPurchased({required String provider}) =>
      _show('$provider subscription', 'Your cable TV subscription was successful.');

  static Future<void> electricityPurchased({required String disco}) =>
      _show('Electricity payment', 'Your $disco payment was successful.');

  static Future<void> inviteSent({required String email}) =>
      _show('Invite sent', 'An invite is on its way to $email.');

  static Future<void> inviteAccepted({required String friendName}) =>
      _show('Friend joined!', '$friendName joined via your link.');

  static Future<void> cashbackEarned({required String amount}) =>
      _show('Cashback earned — ₦$amount', 'Your ₦$amount reward has been credited.');

  static Future<void> newUserJoined({required String username}) =>
      _show('New user', '$username just joined.');

  // ─── Canva / Studio ───

  static Future<void> canvaProjectSaved({required String projectName}) =>
      _show('Project saved', '"$projectName" has been saved.');

  static Future<void> canvaPublished({required String projectName}) =>
      _show('Published — $projectName', 'Your app "$projectName" is live.');

  static Future<void> canvaFailed() =>
      _show('Could not save', 'Please check your connection and try again.');

  // ─── Account ───

  static Future<void> emailVerificationSent({required String email}) =>
      _show('Verification email sent', 'Check $email for the link.');

  static Future<void> emailVerified() =>
      _show('Email verified', 'Your email is now verified.');

  static Future<void> passwordResetSent({required String email}) =>
      _show('Reset link sent', 'Check $email for instructions.');

  static Future<void> profileUpdated() =>
      _show('Profile updated', 'Your changes have been saved.');

  static Future<void> securityAlert({String? device}) =>
      _show('New sign-in', device == null ? 'A new sign-in was detected.' : 'New sign-in from $device.');

  // ─── System ───

  static Future<void> maintenanceScheduled({required String when}) =>
      _show('Maintenance scheduled', '$_appName will be briefly unavailable $when.');

  static Future<void> updateAvailable({required String version}) =>
      _show('Update available — v$version', 'Tap to get the latest features.');

  static Future<void> dailySummary({required String amount}) =>
      _show('Daily summary', 'You earned ₦$amount today.');

  static Future<void> promo({required String title, required String body}) =>
      _show(title, body);

  // ─── Subscriptions ───

  static Future<void> ensureSubscriptions({User? user}) async {
    final topics = <String>[];
    try {
      final appId = AppTenant.currentAppId;
      if (appId.isNotEmpty) {
        final topic1 = 'announcements_$appId';
        await PushNotificationService.instance.subscribeToTopic(topic1);
        topics.add(topic1);
      }
      final uid = user?.uid;
      if (uid != null) {
        final topic2 = 'user_$uid';
        await PushNotificationService.instance.subscribeToTopic(topic2);
        topics.add(topic2);
      }
      if (uid != null && topics.isNotEmpty) {
        try {
          await AppTenant.current.userDoc(uid)
              .update({'subscribed_topics': topics});
        } catch (_) {}
      }
    } catch (_) {}
  }
}
