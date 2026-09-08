import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'notification_store.dart';
import 'push_notification_service.dart';

/// Single source of truth for every user-facing notification.
/// Update templates here — all screens & FCM handlers use this catalog.
/// Placeholder syntax: {key} — replaced at call-site via [AppNotifications._t].
class AppNotifications {
  AppNotifications._();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static String _t(String template, [Map<String, String> vars = const {}]) {
    var out = template;
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }

  static String _displayName(User? user, {String? fallback}) {
    // Priority: Firebase displayName → Google displayName → fallback arg → email prefix → "there"
    final raw = (user?.displayName?.trim().isNotEmpty == true ? user!.displayName!.trim() : null) ??
        fallback?.trim();
    if (raw != null && raw.isNotEmpty) {
      // Use first name for brevity — "John Doe" → "John"
      return raw.split(RegExp(r'\s+')).first;
    }
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  static Future<void> _show(String title, String body, {bool persist = true}) async {
    if (kDebugMode) debugPrint('[AppNotifications] $title — $body');
    await PushNotificationService.instance.showTestNotification(title: title, body: body);
    if (!persist) return;
    // Persist per-user so NotificationPage + badge can show history
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await NotificationStore.addForUser(uid: uid, title: title, body: body, data: {'source': 'app_notifications'});
      } catch (e) {
        if (kDebugMode) debugPrint('[AppNotifications] Firestore persist failed: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🔐 Auth — the only REQUIRED ones for first-time flow
  // ---------------------------------------------------------------------------

  /// First-time welcome — call right after isNewUser == true.
  /// Shows as push notification but NOT persisted to notification history (too frequent).
  static Future<void> welcomeFirstTime({User? user, String? fallbackName}) async {
    final name = _displayName(user, fallback: fallbackName);
    await _show(
      _t('Welcome to Regentspace, {name}! 🎉', {'name': name}),
      _t("Your account is ready, {name}. Let's take off — your wallet and Canva are waiting.", {'name': name}),
      persist: false,
    );
  }

  static Future<void> loginSuccess({User? user}) async {
    final name = _displayName(user);
    await _show('Welcome back, $name', 'Regentspace is ready for you.', persist: false);
  }

  static Future<void> googleFirstTime({User? user}) async {
    final name = _displayName(user);
    await _show(
      'Welcome to Regentspace, $name! 🎉',
      'Your Google account is linked, $name. Dive in — your wallet is ready.',
      persist: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Below: catalog for the rest of the app — edit freely, keep the method
  // signatures, the UI will keep calling them. Less-important copy is marked
  // with `// TODO: tweak copy`.
  // ---------------------------------------------------------------------------

  // Wallet / Virtual Account
  static Future<void> virtualAccountCreated({required String bankName, required String accountNumber}) =>
      _show('Virtual account created', 'Your $bankName account $accountNumber is active and ready to receive funds.');

  static Future<void> virtualAccountFailed() =>
      _show('Could not create account', 'Please try again or choose another bank.');

  static Future<void> walletFunded({required String amount, String? bankName}) =>
      _show('Wallet funded — ₦$amount', bankName == null ? '₦$amount was added to your wallet.' : '₦$amount from $bankName is now available.');

  static Future<void> transferSuccess({required String amount, required String recipient}) =>
      _show('Transfer successful', '₦$amount to $recipient completed.');

  static Future<void> transferFailed({String? reason}) =>
      _show('Transfer failed', reason ?? 'Your transfer could not be completed. Please try again.');

  static Future<void> lowBalance({required String balance}) =>
      _show('Low balance', 'Your balance is ₦$balance. Consider topping up.'); // TODO: tweak copy

  static Future<void> interestCredited({required String amount, required String percent}) =>
      _show('Interest credited — ₦$amount', 'You earned $percent interest. Keep it growing!'); // TODO: tweak copy

  static Future<void> rateUpdated({required String network, required String newRate}) =>
      _show('Rate updated', '$network is now $newRate. Your changes are live.');

  // Invites / Growth
  static Future<void> inviteSent({required String email}) =>
      _show('Invite sent', 'An invite is on its way to $email.');

  static Future<void> inviteAccepted({required String friendName}) =>
      _show('Friend joined! 👏', '$friendName joined via your link.');

  static Future<void> cashbackEarned({required String amount}) =>
      _show('Cashback earned — ₦$amount', 'Your ₦$amount reward has been credited. Keep inviting!');

  static Future<void> newUserJoined({required String username}) =>
      _show('New user', '$username just joined Regentspace.'); // TODO: tweak copy — admin/feed only

  // Canva / Studio
  static Future<void> canvaProjectSaved({required String projectName}) =>
      _show('Project saved', '"$projectName" has been saved to your studio.');

  static Future<void> canvaPublished({required String projectName}) =>
      _show('Published — $projectName', 'Your app "$projectName" is live. Share the link!');

  static Future<void> canvaFailed() =>
      _show('Could not save', 'Please check your connection and try again.'); // TODO: tweak copy

  // Account
  static Future<void> emailVerificationSent({required String email}) =>
      _show('Verification email sent', 'Check $email for the link.');

  static Future<void> emailVerified() =>
      _show('Email verified ✓', 'Your email is now verified.');

  static Future<void> passwordResetSent({required String email}) =>
      _show('Reset link sent', 'Check $email for instructions.');

  static Future<void> profileUpdated() =>
      _show('Profile updated', 'Your changes have been saved.');

  static Future<void> securityAlert({String? device}) =>
      _show('New sign-in', device == null ? 'A new sign-in was detected on your account.' : 'New sign-in from $device. Was this you?');

  // System / Lifecycle — full-time push topics feed these
  static Future<void> maintenanceScheduled({required String when}) =>
      _show('Maintenance scheduled', 'Regentspace will be briefly unavailable $when.');

  static Future<void> updateAvailable({required String version}) =>
      _show('Update available — v$version', 'Tap to get the latest features and fixes.');

  static Future<void> dailySummary({required String amount}) =>
      _show('Daily summary', 'You earned ₦$amount today.'); // TODO: tweak copy

  static Future<void> promo({required String title, required String body}) =>
      _show(title, body); // generic — for remote FCM campaigns

  // ---------------------------------------------------------------------------
  // Convenience: one-liner for remote topic dispatch (keep push full-time)
  // ---------------------------------------------------------------------------
  /// Call after any auth success to ensure device keeps receiving full-time pushes.
  static Future<void> ensureSubscriptions({User? user}) async {
    try {
      await PushNotificationService.instance.subscribeToTopic('all_users');
      await PushNotificationService.instance.subscribeToTopic('announcements');
      final uid = user?.uid;
      if (uid != null) await PushNotificationService.instance.subscribeToTopic('user_$uid');
    } catch (_) {}
  }
}
