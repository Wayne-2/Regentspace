import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
        _handleRetry();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    try {
      await widget.onRetry();
    } catch (_) {}
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    color: Color(0xFFFDF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: Color(0xFF6C0090),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.4,
                    color: const Color(0xFF1A1A1E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF5A5A64),
                  ),
                ),
                const SizedBox(height: 36),
                _isRetrying
                    ? LoadingAnimationWidget.fourRotatingDots(
                        size: 36,
                        color: const Color(0xFF6C0090),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C0090),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                          ),
                          child: const Text('Retry'),
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
