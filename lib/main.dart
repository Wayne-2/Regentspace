import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'auth_page/login.dart';
import 'auth_page/networkerror.dart';
import 'firebase_options.dart';
import 'service/monnify_config.dart';
import 'service/push_notification_service.dart';
import 'service/build_tracker.dart';
import 'service/app_notifications.dart';
import 'service/notification_store.dart';
import 'theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationStore.initLocal();
  runApp(const _AppRoot());
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool? _firebaseOk;
  bool _initializing = false;
  Timer? _fallbackTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _initFirebase() async {
    if (_initializing) return;
    _initializing = true;

    _fallbackTimer?.cancel();
    _connectivitySub?.cancel();
    if (mounted) setState(() => _firebaseOk = null);

    // Check actual connectivity before attempting Firebase
    bool hasConnection = true;
    try {
      final results = await Connectivity().checkConnectivity().timeout(const Duration(seconds: 3));
      hasConnection = results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      hasConnection = false;
    }

    if (!hasConnection) {
      // Actually offline — show error page immediately
      _initializing = false;
      if (mounted) setState(() => _firebaseOk = false);
      _startConnectivityListener();
      return;
    }

    // Online — start Firebase init with a fallback timer
    _fallbackTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _firebaseOk == null && !_initializing) {
        _initializing = false;
        setState(() => _firebaseOk = false);
        _startConnectivityListener();
      }
    });

    // Start listening for connectivity changes during init
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final backOnline = results.any((r) => r != ConnectivityResult.none);
      if (backOnline && mounted && _firebaseOk != true && !_initializing) {
        _initFirebase();
      }
    });

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await PushNotificationService.instance.init();
      await BuildTracker.instance.init();
      await AppNotifications.ensureSubscriptions();

      // MonnifyConfig may fail at cold-start (unauth) — that's OK, retried after login
      try {
        await MonnifyConfig.loadFromFirestore();
      } catch (_) {}

      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null && !MonnifyConfig.isConfigured) {
          await MonnifyConfig.loadFromFirestore();
        }
      });

      _fallbackTimer?.cancel();
      _connectivitySub?.cancel();
      _initializing = false;
      if (mounted) {
        setState(() => _firebaseOk = true);
        final nav = Navigator.of(context);
        if (nav.canPop()) {
          nav.pushReplacement(MaterialPageRoute(builder: (_) => const Loginpage()));
        }
      }
    } catch (_) {
      _fallbackTimer?.cancel();
      _initializing = false;
      if (mounted && _firebaseOk == null) {
        setState(() => _firebaseOk = false);
      }
      _startConnectivityListener();
    }
  }

  void _startConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && mounted && _firebaseOk != true && !_initializing) {
        _initFirebase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scaffoldMessengerKey: _scaffoldKey,
      home: Loadingpage(firebaseOk: _firebaseOk, onRetry: _initFirebase),
    );
  }
}

class Loadingpage extends StatefulWidget {
  final bool? firebaseOk;
  final Future<void> Function() onRetry;
  const Loadingpage({super.key, required this.firebaseOk, required this.onRetry});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  bool _navigated = false;

  @override
  void didUpdateWidget(covariant Loadingpage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firebaseOk != oldWidget.firebaseOk) {
      _navigated = false;
    }
    if (widget.firebaseOk != null && !_navigated) {
      _navigate();
    }
  }

  void _navigate() {
    if (!mounted || _navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final destination = widget.firebaseOk == true
          ? MaterialPageRoute(builder: (_) => const Loginpage())
          : MaterialPageRoute(builder: (_) => Networkerror(onRetry: widget.onRetry));
      Navigator.of(context).push(destination);
    });
  }

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

    if (widget.firebaseOk != null) {
      _navigate();
    }
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
