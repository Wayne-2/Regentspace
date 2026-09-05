// Template signup screen — replaced by generator.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/build_config.dart';
import '../service/auth_service.dart';
import '../service/user_repository.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (username.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await _auth.signUp(email: email, password: pass);
      await UserRepository.instance.saveEmailUser(
        user: cred.user!,
        username: username,
        phone: '',
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message ?? 'Signup failed'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Signup failed: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();
    return Scaffold(
      backgroundColor: config.getScreenBg(2),
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
              Text(config.getText('signup_heading', fallback: 'Create Account'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700,
                  color: config.getElementColor('signup_heading', fallback: const Color(0xFF333333)))),
              const SizedBox(height: 4),
              Text(config.getText('signup_subtitle', fallback: 'Join us today'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 13,
                  color: config.getElementColor('signup_subtitle', fallback: const Color(0xFFAAAAAA)))),
              const SizedBox(height: 28),
              _buildField('Username', 'e.g. John', controller: _usernameCtrl),
              const SizedBox(height: 16),
              _buildField('Email', 'you@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _passCtrl, obscure: true),
              const SizedBox(height: 16),
              _buildField('Confirm Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _confirmCtrl, obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _signup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _loading
                        ? config.getContainerBg('signup_button', fallback: const Color(0xFFCCCCCC))
                        : config.getContainerBg('signup_button', fallback: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(config.getText('signup_button', fallback: 'Create Account'),
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600,
                              color: config.getElementColor('signup_button', fallback: const Color(0xFF666666)))),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text(config.getText('signup_login', fallback: 'Already have an account? Sign in'),
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 11,
                      color: config.getElementColor('signup_login', fallback: const Color(0xFFAAAAAA)))),
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
