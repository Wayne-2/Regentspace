import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'auth_page/login.dart';
import 'firebase_options.dart';
import 'service/monnify_config.dart';
import 'service/push_notification_service.dart';
import 'service/app_notifications.dart';
import 'theme/app_theme.dart';

/// Background handler for FCM - must be top-level.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // System shows notification automatically for `notification` payload in background.
  // For data-only, you could show local notification here with flutter_local_notifications.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Init push (permissions, local channel, foreground handler, token) — runs full-time for entire app lifecycle
  await PushNotificationService.instance.init();
  // Global topics for full-time delivery (user-specific added after auth via AppNotifications.ensureSubscriptions)
  await AppNotifications.ensureSubscriptions();
   // Monnify — load contract/keys from Firestore config/monnify (allows rotation without rebuild)
  // First attempt runs before auth (may fail with permission-denied — see log 13:00:27.991).
  // Retry automatically when user signs in via authStateChanges + ensureConfigured() in MonnifyService.
  await MonnifyConfig.loadFromFirestore();
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null && !MonnifyConfig.isConfigured) {
      await MonnifyConfig.loadFromFirestore();
    }
  });
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Loadingpage(),
    ),
  );
}

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Loginpage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 1.0,
        child: Stack(
          children: [
            Positioned(
              right: -402,
              top: -508,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 83, 240, 0.28),
                  borderRadius: BorderRadius.circular(1000),
                ),
                width: 804,
                height: 743,
              ),
            ),
            Positioned(
              right: -639,
              top: -238,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 83, 240, 0.28),
                  borderRadius: BorderRadius.circular(1000),
                ),
                width: 804,
                height: 743,
              ),
            ),
            Positioned(
              left: -508,
              bottom: -445,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 83, 240, 0.28),
                  borderRadius: BorderRadius.circular(1000),
                ),
                width: 804,
                height: 743,
              ),
            ),
            Positioned(
              left: -555,
              bottom: -445,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 83, 240, 0.28),
                  borderRadius: BorderRadius.circular(1000),
                ),
                width: 804,
                height: 743,
              ),
            ),
            Positioned(
              left: -617,
              bottom: -445,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 83, 240, 0.28),
                  borderRadius: BorderRadius.circular(1000),
                ),
                width: 804,
                height: 743,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/logo.png'),
                      ),
                    ),
                    width: 134,
                    height: 288,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Welcome to Regentspace',
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.8,
                      color: const Color.fromRGBO(65, 0, 86, 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Are you ready to take off?',
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      color: Color.fromRGBO(65, 0, 86, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        size: 50,
                        color: const Color.fromRGBO(209, 69, 255, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
