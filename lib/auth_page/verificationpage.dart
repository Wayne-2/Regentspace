import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../navigator.dart';
import '../service/auth_service.dart';
import '../service/user_repository.dart';
import 'loadingscreen.dart';

/// Full verification screen — shows emailVerified status and lets the
/// user resend the link or refresh.
/// For password sign-ups: emailVerified is false until they click the link.
/// For Google sign-ups: this screen shows already-verified badge.
class Verificationpage extends StatefulWidget {
  final String email;
  final bool showPhonePrompt;
  const Verificationpage({super.key, required this.email, this.showPhonePrompt = false});

  @override
  State<Verificationpage> createState() => _VerificationpageState();
}

class _VerificationpageState extends State<Verificationpage> {
  bool _isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  bool _sending = false;
  bool _checking = false;
  Timer? _pollTimer;

  // Phone collection for Google users (phone not in Google API)
  final TextEditingController _phoneController = TextEditingController();
  bool _phoneSaving = false;
  bool _phoneNeeded = false;

  @override
  void initState() {
    super.initState();
    _isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (widget.showPhonePrompt) {
      _phoneNeeded = true; // caller already knows phone missing
    } else {
      _checkPhoneNeeded();
    }
    // Auto-poll every 3s so user doesn't have to tap manually
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _silentReload());
  }

  Future<void> _checkPhoneNeeded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final needs = await UserRepository.instance.needsPhone(uid);
    if (!mounted) return;
    setState(() => _phoneNeeded = needs);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _silentReload() async {
    if (_isVerified || !mounted) return;
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final v = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (v && mounted) {
        setState(() => _isVerified = true);
        // Update Firestore mirror
        try {
          final u = FirebaseAuth.instance.currentUser;
          if (u != null) await UserRepository.instance.touchLogin(u);
        } catch (_) {}
        _pollTimer?.cancel();
      }
    } catch (_) {}
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      final v = await AuthService().reloadAndCheckVerified();
      if (!mounted) return;
      setState(() {
        _isVerified = v;
        _checking = false;
      });
      if (v) {
        try {
          final u = FirebaseAuth.instance.currentUser;
          if (u != null) await UserRepository.instance.touchLogin(u);
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified ✓'), backgroundColor: Color(0xFF740690)),
        );
        _pollTimer?.cancel();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not verified yet. Check your inbox and spam folder.'), backgroundColor: Color(0xFF740690)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check failed: $e'), backgroundColor: const Color(0xFF740690)),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await AuthService().sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email resent to ${widget.email}'), backgroundColor: const Color(0xFF740690)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = e.message ?? 'Could not resend';
      if (e.code == 'too-many-requests') msg = 'Too many requests. Try again in a minute.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFF740690)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend failed: $e'), backgroundColor: const Color(0xFF740690)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _savePhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile number'), backgroundColor: Color(0xFF740690)),
      );
      return;
    }
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number'), backgroundColor: Color(0xFF740690)),
      );
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _phoneSaving = true);
    try {
      await UserRepository.instance.updateProfile(uid, {'phone': phone});
      if (!mounted) return;
      setState(() {
        _phoneNeeded = false;
        _phoneSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number saved ✓'), backgroundColor: Color(0xFF740690)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _phoneSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save phone: $e'), backgroundColor: const Color(0xFF740690)),
      );
    }
  }

  void _continue() {
    // Allow continue even if not verified — dashboard will show banner
    // But if verified we go straight. If phone still needed we block until saved.
    if (_phoneNeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add your phone number before continuing'), backgroundColor: Color(0xFF740690)),
      );
      return;
    }
    if (_isVerified) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Loadingscreen()));
    } else {
      // Unverified users can still continue — app shows persistent banner
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Email not verified', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A1E))),
          content: Text('Your email ${widget.email} is not verified yet. You can continue but some features may be limited. We\'ve sent a verification link — check inbox/spam.\n\nContinue anyway?', style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF5A5A64))),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFDF4FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Stay', style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF5A5A64))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF740690),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Continue', style: TextStyle(fontFamily: 'DMSans')),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF740690)),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegentBottomNav())),
        ),
        title: const Text('Verify your email', style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF2E0342), fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isVerified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isVerified ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFFFF9800).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isVerified ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_isVerified ? Icons.verified : Icons.mark_email_unread_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isVerified ? 'Email verified ✓' : 'Email not verified',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.email,
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12.5, color: Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isVerified ? 'Your email is confirmed. You\'re all set.' : 'We sent a verification link. Tap it in your inbox (check spam too). This page auto-checks every 3s.',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: Colors.black.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (!_isVerified) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checking ? null : _checkNow,
                  icon: _checking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh, size: 18),
                  label: Text(_checking ? 'Checking…' : 'I\'ve verified — check now', style: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF740690),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sending ? null : _resend,
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_outlined, size: 18),
                  label: Text(_sending ? 'Sending…' : 'Resend verification email', style: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF740690),
                    side: const BorderSide(color: Color(0xFF740690)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: _continue,
                  child: const Text('Skip for now — continue to app', style: TextStyle(fontFamily: 'DMSans', color: Colors.grey, fontSize: 13)),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _phoneNeeded ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF740690),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            // ── Phone missing notice (Google users) ──
            if (_phoneNeeded) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF740690).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: Color(0xFF740690)),
                        SizedBox(width: 6),
                        Text('Add your mobile number', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2E0342))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Google doesn\'t share phone numbers. Please add yours so we can store it and create your virtual account correctly.',
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: Colors.black.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. 08012345678',
                        hintStyle: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.phone, size: 18, color: Color(0xFF740690)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF740690))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _phoneSaving ? null : _savePhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF740690),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _phoneSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save phone number', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
