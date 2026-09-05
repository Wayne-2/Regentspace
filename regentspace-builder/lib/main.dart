import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/build_config.dart';
import 'firebase_options.dart';
import 'service/app_tenant.dart';
import 'service/monnify_config.dart';
import 'service/vtpass_config.dart';
import 'service/notification_store.dart';
import 'service/app_notifications.dart';
import 'service/push_notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Firebase ───
  try {
    if (kDebugMode) print('[Boot] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) print('[Boot] Firebase initialized OK');
  } catch (e, st) {
    if (kDebugMode) print('[Boot] Firebase init FAILED: $e\n$st');
    // App can still show UI; show error banner
  }

  // ─── Hive ───
  try {
    if (kDebugMode) print('[Boot] Initializing Hive...');
    await Hive.initFlutter();
    await NotificationStore.initLocal();
    if (kDebugMode) print('[Boot] Hive initialized OK');
  } catch (e) {
    if (kDebugMode) print('[Boot] Hive init FAILED: $e');
  }

  // ─── Build config ───
  if (kDebugMode) print('[Boot] Loading build config...');
  final config = BuildConfig.load();
  final appId = config.appId;
  if (kDebugMode) print('[Boot] appId=$appId, appName=${config.appName}');

  // ─── Push notifications ───
  try {
    if (kDebugMode) print('[Boot] Initializing PushNotificationService...');
    await PushNotificationService.instance.init(
      channelId: '${config.appId}_channel',
      channelName: '${config.appName} Notifications',
    );
    if (kDebugMode) print('[Boot] PushNotificationService initialized OK');
  } catch (e) {
    if (kDebugMode) print('[Boot] PushNotificationService init FAILED: $e');
  }

  // ─── Multi-tenant context ───
  AppTenant.init(appId);
  AppNotifications.setAppName(config.appName);

  if (kDebugMode) print('[Boot] Launching app...');
  runApp(MyApp(appName: config.appName));

  // ─── Firestore config (non-blocking, after app starts) ───
  // These require auth; they'll fail silently before login and retry on demand.
  Future.microtask(() async {
    try {
      if (kDebugMode) print('[Boot] Loading Monnify config from Firestore...');
      await MonnifyConfig.loadFromFirestore().timeout(const Duration(seconds: 5));
      if (kDebugMode) print('[Boot] Monnify config loaded: ${MonnifyConfig.isConfigured}');
    } catch (e) {
      if (kDebugMode) print('[Boot] Monnify config load failed: $e');
    }
    try {
      if (kDebugMode) print('[Boot] Loading VTPass config from Firestore...');
      await VtpassConfig.loadFromFirestore().timeout(const Duration(seconds: 5));
      if (kDebugMode) print('[Boot] VTPass config loaded: ${VtpassConfig.isConfigured}');
    } catch (e) {
      if (kDebugMode) print('[Boot] VTPass config load failed: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  final String appName;
  const MyApp({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const IntroScreen(),
      // Named routes for post-auth navigation
      // The generator adds routes for all screen types here
    );
  }
}
