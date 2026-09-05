// Template login screen — replaced by generator.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/build_config.dart';
import '../service/auth_service.dart';
import '../service/user_repository.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await _auth.signIn(email: email, password: pass);
      await UserRepository.instance.ensureUserDoc(cred.user!);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message ?? 'Login failed'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Login failed: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();
    return Scaffold(
      backgroundColor: config.getScreenBg(1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: Icon(Icons.apps_rounded, size: 18, color: Color(0xFFB0B0B0)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    config.appName,
                    style: TextStyle(
                      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600,
                      color: config.getElementColor('intro_title', fallback: const Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(config.getText('login_heading', fallback: 'Login'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700,
                  color: config.getElementColor('login_heading', fallback: const Color(0xFF333333)))),
              const SizedBox(height: 4),
              Text(config.getText('login_subtitle', fallback: 'Welcome back, please sign in'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 13,
                  color: config.getElementColor('login_subtitle', fallback: const Color(0xFFAAAAAA)))),
              const SizedBox(height: 28),
              _buildField('Email', 'you@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _passCtrl, obscure: true),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(config.getText('login_forgot', fallback: 'Forgot password?'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w500,
                    color: config.getElementColor('login_forgot', fallback: const Color(0xFFB0B0B0)))),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _login,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _loading
                        ? config.getContainerBg('login_button', fallback: const Color(0xFFCCCCCC))
                        : config.getContainerBg('login_button', fallback: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(config.getText('login_button', fallback: 'Log In'),
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600,
                              color: config.getElementColor('login_button', fallback: const Color(0xFF666666)))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: Text(config.getText('login_signup', fallback: "Don't have an account? Sign up"),
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 11,
                      color: config.getElementColor('login_signup', fallback: const Color(0xFFAAAAAA)))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, {TextEditingController? controller, bool obscure = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF888888))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFFC0C0C0)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: TextStyle(fontFamily: 'DMSans', fontSize: 13),
        ),
      ],
    );
  }
}
