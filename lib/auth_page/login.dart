import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../navigator.dart';
import 'createaccount.dart';
import 'verificationpage.dart';
import '../components/button.dart';
import '../components/inputarea.dart';
import '../components/loadingpopup.dart';
import '../components/text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/auth_service.dart';
import '../service/messaging_service.dart';
import '../service/app_notifications.dart';
import '../service/user_repository.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
  }

  bool _isLoading = false;

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      _showMessage("Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);
    _showLoading();
    try {
      final cred = await AuthService().signIn(email: email, password: password);
      // Init FCM after login - get token & subscribe (full-time push)
      // ignore: unused_local_variable
      final fcmToken = await MessagingService().getToken();
      // Keep Firestore profile fresh on each login
      try {
        await UserRepository.instance.touchLogin(cred.user!);
        if (fcmToken != null) await UserRepository.instance.saveFcmToken(uid: cred.user!.uid, token: fcmToken);
      } catch (e) {
        if (kDebugMode) debugPrint('Firestore touchLogin failed: $e');
      }
      await AppNotifications.ensureSubscriptions(user: cred.user);
      // Returning user — subtle login notification (optional, remove if too noisy)
      await AppNotifications.loginSuccess(user: cred.user);
      if (!mounted) return;
      Navigator.pop(context); // close loading

      // Indicate verification status for email/password users (Google is already verified)
      final isVerified = cred.user?.emailVerified ?? false;
      final needsPhone = await UserRepository.instance.needsPhone(cred.user!.uid);
      if (!isVerified || needsPhone) {
        _showMessage(isVerified ? 'Login successful! Please add your phone number.' : 'Login successful! ⚠️ Email not verified — check your inbox.');
        // Give user choice: go verify now or continue
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(!isVerified ? 'Email not verified' : 'Phone missing', style: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16)),
            content: Text(
              !isVerified
                  ? 'Your email ${cred.user?.email ?? email} is not verified. Tap Verify to resend/confirm, or Continue to use the app (a banner will remain until verified).'
                  : 'Your phone number is missing. Please add it to complete your profile.',
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav()));
                },
                child: const Text('Continue'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF740690), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Verificationpage(email: cred.user?.email ?? email, showPhonePrompt: needsPhone)));
                },
                child: Text(!isVerified ? 'Verify email' : 'Add phone'),
              ),
            ],
          ),
        );
        return;
      }

      _showMessage("Login successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegentBottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      String msg = e.message ?? "Login failed";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = "Invalid email or password";
      } else if (e.code == 'user-disabled') {
        msg = "Account disabled";
      }
      _showMessage(msg);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage("Login failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    _showLoading();
    try {
      final cred = await AuthService().signInWithGoogle();
      final isNew = cred.additionalUserInfo?.isNewUser ?? false;
      // Login page: Google sign-in only for existing accounts. New Google users must create account first.
      if (isNew) {
        // Clean up the auto-created Firebase Auth user (and any partial Firestore doc) so they can properly sign up later
        try {
          await cred.user?.delete();
        } catch (_) {
          try {
            await FirebaseAuth.instance.signOut();
            await AuthService().signOutGoogle();
          } catch (_) {}
        }
        try {
          if (cred.user != null) {
            await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).delete();
          }
        } catch (_) {}
        if (!mounted) return;
        Navigator.pop(context);
        _showMessage('No account found. Please create an account first.');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Createaccountpage()));
        return;
      }
      // Existing user — persist profile + FCM (same shape as create-account)
      try {
        await UserRepository.instance.saveGoogleUser(credential: cred);
      } catch (e) {
        debugPrint('Firestore save failed (google login): $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile save failed: $e', style: const TextStyle(fontFamily: 'DMSans', fontSize: 12)), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 5)),
          );
        }
      }
      final fcmToken = await MessagingService().getToken();
      if (kDebugMode) debugPrint('Google FCM token: $fcmToken');
      if (fcmToken != null && cred.user != null) {
        await UserRepository.instance.saveFcmToken(uid: cred.user!.uid, token: fcmToken);
      }
      await AppNotifications.loginSuccess(user: cred.user);
      await AppNotifications.ensureSubscriptions(user: cred.user);
      if (!mounted) return;
      Navigator.pop(context);
      // Check phone (Google never provides it) — prompt if missing
      final gNeedsPhone = cred.user != null ? await UserRepository.instance.needsPhone(cred.user!.uid) : false;
      if (gNeedsPhone) {
        _showMessage('Google sign-in successful! Please add your phone number.');
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Phone missing', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16)),
            content: const Text('Google doesn\'t share phone numbers. Please add yours to complete your profile.', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
            actions: [
              TextButton(onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav())); }, child: const Text('Later')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF740690), foregroundColor: Colors.white),
                onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Verificationpage(email: cred.user?.email ?? '', showPhonePrompt: true))); },
                child: const Text('Add phone'),
              ),
            ],
          ),
        );
        return;
      }
      _showMessage('Google sign-in successful!');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      if (e.code == 'account-exists-with-different-credential') {
        _showMessage('Account exists with email/password. Please sign in with email or link Google in profile.');
      } else if (e.code != 'cancelled') {
        _showMessage(e.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF740690)),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Loadingpopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            right: -64,
            top: -25,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/logo.png'),
                ),
              ),
              width: 117,
              height: 252,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(108, 0, 144, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RegentSpace',
                          style: TextStyle(fontFamily: 'DMSans', 
                            height: 1.2,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(46, 3, 66, 1),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Technologies',
                          style: TextStyle(fontFamily: 'DMSans', 
                            height: 1.2,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromRGBO(46, 3, 66, 1),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Textlarge(text: 'Login'),
                const SizedBox(height: 6),
                const Textmedium(text: 'Welcome back!'),
                const Textmedium(text: 'Please login to continue'),
                const SizedBox(height: 20),
                Inputarea(
                  prefixicon: 'assets/icons/Mail.svg',
                  label: 'Email Address',
                  placeholder: 'Your email address',
                  suffixicon: '',
                  obscuretext: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                InputAreaForPassword(
                  prefixIcon: 'assets/icons/Lock.svg',
                  label: 'Password',
                  placeholder: 'Enter your password',
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _loginUser,
                  child: const Button(label: 'Login'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot password?',
                      style: TextStyle(fontFamily: 'DMSans', 
                        color: const Color.fromRGBO(133, 99, 188, 1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(fontFamily: 'DMSans', color: Colors.grey, fontSize: 12))),
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                ]),
                const SizedBox(height: 16),
                // Google Sign-In button — project 964930079549
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: SvgPicture.asset("assets/icons/google.svg", width: 20, height: 20,),
                    label: Text('Sign in with Google', style: TextStyle(fontFamily: 'DMSans', color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13.5)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Textmedium(text: "Don't have account?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Createaccountpage(),
                          ),
                        );
                      },
                      child: Text(
                        'Create Now',
                        style: TextStyle(fontFamily: 'DMSans', 
                          color: const Color.fromRGBO(133, 99, 188, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
