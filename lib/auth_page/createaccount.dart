import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'login.dart';
import '../components/button.dart';
import '../components/inputarea.dart';
import '../components/loadingpopup.dart';
import '../components/text.dart';
import 'verificationpage.dart';
import '../navigator.dart';
import '../service/auth_service.dart';
import '../service/messaging_service.dart';
import '../service/app_notifications.dart';
import '../service/monnify_service.dart';
import '../service/user_repository.dart';
import '../theme/app_theme.dart';

class Createaccountpage extends StatefulWidget {
  const Createaccountpage({super.key});

  @override
  State<Createaccountpage> createState() => _CreateaccountpageState();
}

class _CreateaccountpageState extends State<Createaccountpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if ([email, username, phone, password, confirmPassword].any((e) => e.isEmpty)) {
      _showError('Please fill in all fields');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Loadingpopup(),
    );

    try {
      final cred = await AuthService().signUp(email: email, password: password);
      // Save displayName & phone to Firebase user profile
      await cred.user?.updateDisplayName(username);
      // IMPORTANT: persist manual fields to Firestore — surface errors instead of swallowing
      if (cred.user != null) {
        try {
          await UserRepository.instance.saveEmailUser(user: cred.user!, username: username, phone: phone);
          if (kDebugMode) debugPrint('[CreateAccount] Firestore users/${cred.user!.uid} saved: $username / $phone');
        } catch (e) {
          debugPrint('Firestore save failed (email): $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile save failed: $e — check Firestore rules', style: const TextStyle(fontFamily: 'DMSans', fontSize: 12)),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 6),
              ),
            );
          }
          // Don't abort signup — auth succeeded, user can retry phone in profile
        }
      }
      // Send verification email — this is what marks emailVerified=true after user clicks link
      try {
        await cred.user?.sendEmailVerification();
        if (kDebugMode) debugPrint('[CreateAccount] verification email sent to $email');
        await AppNotifications.emailVerificationSent(email: email);
      } catch (e) {
        debugPrint('sendEmailVerification failed: $e');
        if (kDebugMode) debugPrint('Verify email send failed (non-blocking): $e');
      }
      // Full-time push: congrats notification + keep topics alive
      await AppNotifications.welcomeFirstTime(user: cred.user, fallbackName: username);
      await AppNotifications.ensureSubscriptions(user: cred.user);
      if (!mounted) return;
      Navigator.pop(context); // close loader
      final isVerified = cred.user?.emailVerified ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isVerified ? 'Account created! Email already verified.' : 'Account created! Verification email sent to $email — check inbox/spam.'),
          backgroundColor: const Color(0xFF740690),
          duration: const Duration(seconds: 4),
        ),
      );
      // Auto-create Monnify virtual account (all banks) on first-time signup
      if (cred.user != null) {
        // Check existing to avoid duplicates (e.g. retry)
        try {
          final existing = await MonnifyService.instance.getUserAccountsOnce(cred.user!.uid);
          if (existing.docs.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Virtual account is being created...'), backgroundColor: Color(0xFF740690), duration: Duration(seconds: 3)),
              );
            }
            try {
              final doc = await MonnifyService.instance.createReservedAccount(getAllAvailableBanks: true);
              debugPrint('[Monnify DEBUG] success doc=$doc');
              if (mounted) {
                final bank = (doc['primaryBankName'] ?? 'your bank').toString();
                final acct = (doc['primaryAccountNumber'] ?? '').toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(acct.isEmpty ? 'Virtual account ready at $bank' : 'Virtual account ready: $bank • $acct'), backgroundColor: Color(0xFF740690)),
                );
                // Visible debug success
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Monnify DEBUG success: ${acct.isEmpty ? doc : "$bank • $acct"}', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
                  backgroundColor: Colors.green.shade700,
                  duration: Duration(seconds: 5),
                ));
              }
              await AppNotifications.virtualAccountCreated(bankName: (doc['primaryBankName'] ?? 'Monnify').toString(), accountNumber: (doc['primaryAccountNumber'] ?? '').toString());
            } catch (e) {
              debugPrint('Auto virtual account failed: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Monnify DEBUG failed: $e', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
                  backgroundColor: Colors.red.shade700,
                  duration: Duration(seconds: 8),
                  action: SnackBarAction(label: 'COPY', textColor: Colors.white, onPressed: () => Clipboard.setData(ClipboardData(text: e.toString()))),
                ));
                // Full debug dialog for copy/paste
                showDialog(context: context, builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Monnify debug — create failed', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
                  content: SingleChildScrollView(child: SelectableText(e.toString(), textAlign: TextAlign.center, style: AppTextStyles.body(color: AppColors.textSecondary))),
                  actions: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const RoundedRectangleBorder(), minimumSize: const Size(double.infinity, 48)),
                          onPressed: () { Clipboard.setData(ClipboardData(text: e.toString())); Navigator.pop(context); },
                          child: Text('Copy', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const RoundedRectangleBorder(), minimumSize: const Size(double.infinity, 48)),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ));
              }
            }
          }
        } catch (e) {
          debugPrint('Check existing accounts failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Monnify DEBUG check failed: $e', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
              backgroundColor: Colors.orange.shade700,
              duration: Duration(seconds: 6),
            ));
          }
        }
      }
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      // Route to verification page so user SEES the unverified state (and can resend/check)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Verificationpage(email: email)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      String msg = e.message ?? "Sign up failed";
      if (e.code == 'email-already-in-use') msg = "Email already in use";
      else if (e.code == 'weak-password') msg = "Password too weak";
      else if (e.code == 'invalid-email') msg = "Invalid email";
      _showError(msg);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError("Sign up failed: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Loadingpopup());
    try {
      final cred = await AuthService().signInWithGoogle();
      // Mirror create-account fields from Google API into Firestore users/{uid}
      try {
        await UserRepository.instance.saveGoogleUser(credential: cred);
      } catch (e) {
        debugPrint('Firestore save failed (google): $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile save failed: $e', style: const TextStyle(fontFamily: 'DMSans', fontSize: 12)), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 5)),
          );
        }
      }
      final token = await MessagingService().getToken();
      if (kDebugMode) debugPrint('Google token $token');
      if (token != null && cred.user != null) {
        await UserRepository.instance.saveFcmToken(uid: cred.user!.uid, token: token);
      }
      final isNew = cred.additionalUserInfo?.isNewUser ?? false;
      if (isNew) {
        await AppNotifications.welcomeFirstTime(user: cred.user);
      } else {
        await AppNotifications.loginSuccess(user: cred.user);
      }
      await AppNotifications.ensureSubscriptions(user: cred.user);
      if (!mounted) return;
      Navigator.pop(context);
      // Google emails are pre-verified, but phone is missing from Google API — prompt if needed
      final needsPhone = cred.user != null ? await UserRepository.instance.needsPhone(cred.user!.uid) : false;
      if (needsPhone && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in successful! Please add your phone number to complete your profile.'), backgroundColor: Color(0xFF740690), duration: Duration(seconds: 4)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isNew ? 'Welcome, ${cred.user?.displayName ?? 'there'}! 🎉' : 'Google sign-in successful!'), backgroundColor: const Color(0xFF740690)));
      }
      // Auto-create virtual account for first-time Google users
      if (isNew && cred.user != null) {
        try {
          final existing = await MonnifyService.instance.getUserAccountsOnce(cred.user!.uid);
          if (existing.docs.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Virtual account is being created...'), backgroundColor: Color(0xFF740690), duration: Duration(seconds: 3)),
              );
            }
            try {
              final doc = await MonnifyService.instance.createReservedAccount(getAllAvailableBanks: true);
              debugPrint('[Monnify DEBUG] success (google) doc=$doc');
              if (mounted) {
                final bank = (doc['primaryBankName'] ?? 'your bank').toString();
                final acct = (doc['primaryAccountNumber'] ?? '').toString();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(acct.isEmpty ? 'Virtual account ready at $bank' : 'Virtual account ready: $bank • $acct'), backgroundColor: Color(0xFF740690)),
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Monnify DEBUG success: ${acct.isEmpty ? doc : "$bank • $acct"}', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
                  backgroundColor: Colors.green.shade700,
                  duration: Duration(seconds: 5),
                ));
              }
              await AppNotifications.virtualAccountCreated(bankName: (doc['primaryBankName'] ?? 'Monnify').toString(), accountNumber: (doc['primaryAccountNumber'] ?? '').toString());
            } catch (e) {
              debugPrint('Auto virtual account failed (google): $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Monnify DEBUG failed: $e', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
                  backgroundColor: Colors.red.shade700,
                  duration: Duration(seconds: 8),
                  action: SnackBarAction(label: 'COPY', textColor: Colors.white, onPressed: () => Clipboard.setData(ClipboardData(text: e.toString()))),
                ));
                showDialog(context: context, builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text('Monnify debug — create failed (google)', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
                  content: SingleChildScrollView(child: SelectableText(e.toString(), textAlign: TextAlign.center, style: AppTextStyles.body(color: AppColors.textSecondary))),
                  actions: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const RoundedRectangleBorder(), minimumSize: const Size(double.infinity, 48)),
                          onPressed: () { Clipboard.setData(ClipboardData(text: e.toString())); Navigator.pop(context); },
                          child: Text('Copy', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const RoundedRectangleBorder(), minimumSize: const Size(double.infinity, 48)),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ));
              }
            }
          }
        } catch (e) {
          debugPrint('Check existing accounts failed (google): $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Monnify DEBUG check failed: $e', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
              backgroundColor: Colors.orange.shade700,
              duration: Duration(seconds: 6),
            ));
          }
        }
      }
      // Small delay so snackbars are visible before navigating
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      final gmail = cred.user?.email ?? '';
      final gNeedsPhone = cred.user != null ? await UserRepository.instance.needsPhone(cred.user!.uid) : false;
      if (gNeedsPhone) {
        // Route to verification page to collect phone (Google has no phone in API)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Verificationpage(email: gmail, showPhonePrompt: true)));
        return;
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      if (e.code != 'cancelled') _showError(e.message ?? 'Google sign-in failed');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError('Google sign-in failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF740690),
      ),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Loginpage()),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(108, 0, 144, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'RegentSpace',
                            style: TextStyle(fontFamily: 'DMSans', 
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(46, 3, 66, 1),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Technologies',
                            style: TextStyle(fontFamily: 'DMSans', 
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
                  const Textlarge(text: 'Create Account'),
                  const SizedBox(height: 6),
                  const Textmedium(
                    text: 'Enter your information below to create an account.',
                  ),
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
                  Inputarea(
                    prefixicon: 'assets/icons/Person.svg',
                    label: 'Username',
                    placeholder: 'Your full name',
                    suffixicon: '',
                    obscuretext: false,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 12),
                  Inputarea(
                    prefixicon: 'assets/icons/Phone.svg',
                    label: 'Mobile Number',
                    placeholder: 'Your mobile number',
                    suffixicon: '',
                    obscuretext: false,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 12),
                  InputAreaForPassword(
                    prefixIcon: 'assets/icons/Lock.svg',
                    label: 'Password',
                    placeholder: 'Enter your password',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12),
                  InputAreaForPassword(
                    prefixIcon: 'assets/icons/Lock.svg',
                    label: 'Confirm Password',
                    placeholder: 'Re-enter your password',
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _createAccount,
                    child: const Button(label: 'Create account'),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(fontFamily: 'DMSans', color: Colors.grey, fontSize: 12))),
                    const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE0E0E0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.white),
                      onPressed: _signInWithGoogle,
                      icon: SvgPicture.asset("assets/icons/google.svg", width: 20, height: 20,),
                      label: Text('Sign up with Google', style: TextStyle(fontFamily: 'DMSans', color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Textmedium(text: "Already have an account?"),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Loginpage()),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontFamily: 'DMSans', 
                            color: const Color.fromRGBO(133, 99, 188, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
