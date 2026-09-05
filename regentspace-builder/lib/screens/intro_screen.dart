// Template intro screen — replaced by generator with a designed version.
// This serves as the fallback if the generator doesn't produce an intro screen.
import 'package:flutter/material.dart';
import '../config/build_config.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();
    return Scaffold(
      backgroundColor: config.getScreenBg(0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(Icons.image_outlined, size: 36, color: Color(0xFFB0B0B0)),
                ),
                const SizedBox(height: 20),
                Text(
                  config.getText('intro_title', fallback: config.appName),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w600,
                    color: config.getElementColor('intro_title'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  config.getText('intro_description', fallback: ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans', fontSize: 14,
                    color: config.getElementColor('intro_description', fallback: const Color(0xFFAAAAAA)),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: config.getElementColor('login_button', fallback: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          config.getText('login_button', fallback: 'Login'),
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600,
                            color: config.getElementColor('login_button_text', fallback: const Color(0xFF666666))),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: Text(
                    config.getText('intro_signup', fallback: "Don't have an account? Sign up"),
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 12,
                      color: config.getElementColor('intro_signup', fallback: const Color(0xFFAAAAAA))),
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
