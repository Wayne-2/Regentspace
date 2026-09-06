import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_theme.dart';

class Networkerror extends StatefulWidget {
  final Future<void> Function() onRetry;
  const Networkerror({super.key, required this.onRetry});

  @override
  State<Networkerror> createState() => _NetworkerrorState();
}

class _NetworkerrorState extends State<Networkerror> {
  bool _isRetrying = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && mounted && !_isRetrying) {
        _popAndRetry();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  /// Pop back to Loadingpage, then trigger retry.
  void _popAndRetry() {
    if (!mounted) return;
    _isRetrying = true;
    // Pop this page — the Loadingpage underneath will show loading animation
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    // Fire retry (sets _firebaseOk = null → Loadingpage shows loading)
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline(),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRetrying ? null : _popAndRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.body(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: _isRetrying
                        ? LoadingAnimationWidget.fourRotatingDots(size: 24, color: Colors.white)
                        : const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
