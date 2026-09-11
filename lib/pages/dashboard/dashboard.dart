import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../service/user_repository.dart';
import '../../auth_page/verificationpage.dart';
import '../../service/auth_service.dart';
import '../../service/notification_store.dart';
import '../../service/monnify_service.dart';
import '../../service/monnify_config.dart';
import '../../service/build_tracker.dart';
import '../../components/notificationpage.dart';
import '../../components/shareinvite.dart';
import '../../pages/finances/all_recent_activity.dart';
import 'newusertab.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<String> images = const ['assets/ads1.png', 'assets/ads2.png'];

  // Static mock data — no API
  bool isHidden = false;
  // double balance = 45230.50;
  // double moneyIn = 12000;
  // double moneyOut = 5400;

  // static const mockUser = {
  //   'username': 'John Doe',
  //   'email': 'john@example.com',
  //   'bankname': 'Wema Bank',
  //   'accountnumber': '0123456789',
  // };

  String _fmtBalance(num? v) {
    if (v == null) return '₦0.00';
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(v);
  }

  String _fmtUpdated(Timestamp? ts) {
    if (ts == null) return 'just now';
    final d = ts.toDate();
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, h:mm a').format(d);
  }

  Future<void> _onRefresh() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await MonnifyConfig.ensureConfigured();
      // Force server fetch for user doc + reserved account to refresh balance
      final userSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get(const GetOptions(source: Source.server));
      final primary = userSnap.data()?['primaryVirtualAccount'] as Map<String, dynamic>?;
      final ref = (primary?['accountReference'] as String?)?.trim();
      if (ref != null && ref.isNotEmpty) {
        await FirebaseFirestore.instance.collection('monnify_reserved_accounts').doc(ref).get(const GetOptions(source: Source.server));
        // Best-effort: derive balance from Firestore mirror (webhook updates); no direct Monnify balance API for reserved
        try {
          await MonnifyService.instance.getReservedAccountBalance(ref);
        } catch (_) {}
      }
      // Give streams a moment to emit
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balance refreshed'), backgroundColor: Color(0xFF740690), duration: Duration(seconds: 1)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refresh failed: $e'), backgroundColor: const Color(0xFF740690)));
  }
}

  void _showAddMoneySheet() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMoneySheet(uid: uid),
    );
  }

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied'), backgroundColor: const Color(0xFF740690), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 252, 255),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 254, 252, 255),
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Regentspace',
          style: AppTextStyles.headline(color: AppColors.primaryDark),
        ),
        actions: [
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('https://regentspace.com/support'), mode: LaunchMode.externalApplication),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 22, color: AppColors.accent),
            ),
          ),
          _NotificationIcon(uid: uid),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF740690),
          backgroundColor: Colors.white,
          displacement: 40,
          strokeWidth: 3,
          elevation: 2,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
              // ── Email verification / phone missing banner ──
              _VerificationBanner(uid: uid),
              const SizedBox(height: 12),
              // ── Bank / Account / Balance — live from Monnify + Firestore ──
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                builder: (context, userSnap) {
                  final userData = userSnap.data?.data();
                  final primary = userData?['primaryVirtualAccount'] as Map<String, dynamic>?;
                  final bankName = (primary?['bankName'] as String?)?.trim();
                  final acctNo = (primary?['accountNumber'] as String?)?.trim();
                  final acctRef = (primary?['accountReference'] as String?)?.trim();
                  final hasAccount = bankName != null && bankName.isNotEmpty && acctNo != null && acctNo.isNotEmpty;

                  // If no Monnify account yet (just signed up, still creating), show creating state
                  if (!hasAccount) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Setting up...', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color.fromARGB(219, 25, 27, 35))),
                                  const SizedBox(width: 6),
                                  Shimmer.fromColors(
                                    baseColor: const Color(0xFF740690).withOpacity(0.3),
                                    highlightColor: const Color(0xFF740690).withOpacity(0.1),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF740690),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(isHidden ? '₦••••••' : '₦0.00', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 78, 6, 102), letterSpacing: -0.5)),
                              const SizedBox(height: 2),
                              const Text('Virtual account is being created...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color.fromARGB(190, 25, 27, 35))),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Watch live balance / last updated from monnify_reserved_accounts/{ref}
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: acctRef == null || acctRef.isEmpty
                        ? null
                        : FirebaseFirestore.instance.collection('monnify_reserved_accounts').doc(acctRef).snapshots(),
                    builder: (context, acctSnap) {
                      final acctData = acctSnap.data?.data();
                      final balance = (acctData?['totalReceived'] as num?) ?? (primary?['balance'] as num?) ?? 0;
                      final ts = (acctData?['lastPaymentAt'] as Timestamp?) ??
                          (acctData?['updatedAt'] as Timestamp?) ??
                          (userData?['updatedAt'] as Timestamp?);
                      final updatedText = _fmtUpdated(ts);
                      final displayBalance = isHidden ? '₦••••••' : _fmtBalance(balance);

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(child: Text(bankName, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color.fromARGB(219, 25, 27, 35)))),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Text('·', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color.fromARGB(219, 25, 27, 35))),
                                    ),
                                    Text(acctNo, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color.fromARGB(219, 25, 27, 35))),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(displayBalance, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 78, 6, 102), letterSpacing: -0.5)),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => setState(() => isHidden = !isHidden),
                                      child: SvgPicture.asset(isHidden ? 'assets/icons/Eye.svg' : 'assets/icons/Eye_off.svg', width: 18, height: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('Current Balance (updated · $updatedText)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color.fromARGB(190, 25, 27, 35))),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllRecentActivityPage())),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 252, 244, 255),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.history_rounded, size: 19, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('View History', style: AppTextStyles.label(color: AppColors.textPrimary)),
                                    const SizedBox(height: 1),
                                    Text('Transactions & activity', style: AppTextStyles.caption(color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showAddMoneySheet,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.add_rounded, size: 19, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Add Money', style: AppTextStyles.label(color: Colors.white)),
                                    const SizedBox(height: 1),
                                    Text('Top up wallet', style: AppTextStyles.caption(color: Colors.white.withValues(alpha: 0.7))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEAC5F7),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFEAC5F7),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                      
                        // ─────────────────────────────────────────────
                        // Decorative background circles
                        // ─────────────────────────────────────────────
                
                        Positioned(
                          right: -45,
                          top: -55,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF4D5FA),
                            ),
                          ),
                        ),
                
                        Positioned(
                          right: 60,
                          bottom: -80,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1D4F8),
                            ),
                          ),
                        ),
                
                        // ─────────────────────────────────────────────
                        // Text + Button
                        // ─────────────────────────────────────────────
                
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            
                              const Text(
                                "Invite a friend &",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF740690),
                                  height: 1.2,
                                ),
                              ),
                
                              const Text(
                                "Earn ₦2,000 cashback",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF740690),
                                  height: 1.2,
                                ),
                              ),
                
                              const SizedBox(height: 10),
                
                              InkWell(
                                onTap: () => sendInvite(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF740690),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Share Invite',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF740690),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                
                                      const SizedBox(width: 6),
                
                                      SvgPicture.asset(
                                        'assets/icons/Decimal.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                
                        // ─────────────────────────────────────────────
                        // HUGE LOGO
                        // ─────────────────────────────────────────────
                
                        Positioned(
                          right: -12,
                          top: -18,
                          child: Transform.rotate(
                            angle: 20 * 3.14159265359 / 180,
                            child: Image.asset(
                              'assets/logo.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Build result banner ──
              _BuildResultBanner(),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("New Users", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 78, 6, 102))),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Full user list coming soon'), backgroundColor: Color(0xFF740690)),
                          );
                        },
                        child: const Text("View all", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 78, 6, 102), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _UserListForGeneratedApp(uid: uid),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
        ),
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(44, 158, 158, 158),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// Banner that indicates unverified email or missing phone.
/// - Email: checks FirebaseAuth.currentUser.emailVerified (reloads on "Check")
/// - Phone: watches Firestore users/{uid}.phone
class _VerificationBanner extends StatefulWidget {
  final String? uid;
  const _VerificationBanner({required this.uid});

  @override
  State<_VerificationBanner> createState() => _VerificationBannerState();
}

class _VerificationBannerState extends State<_VerificationBanner> {
  bool _checking = false;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final isVerified = user?.emailVerified ?? true; // if no user, hide

    if (widget.uid == null || user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: UserRepository.instance.watchUser(widget.uid!),
      builder: (context, snap) {
        final phone = (snap.data?.data()?['phone'] as String?)?.trim() ?? '';
        final needsPhone = phone.isEmpty;
        // Hide if everything ok
        if (isVerified && !needsPhone) return const SizedBox.shrink();

        final title = !isVerified ? 'Email not verified' : 'Phone number missing';
        final subtitle = !isVerified
            ? '$email — tap Resend or Verify'
            : 'Add your phone number to complete your profile (Google doesn\'t provide it).';
        final color = !isVerified ? const Color(0xFFFF9800) : const Color(0xFF740690);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: !isVerified ? const Color(0xFFFFF3E0) : const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(!isVerified ? Icons.mark_email_unread_outlined : Icons.phone_outlined, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 12.5, color: !isVerified ? const Color(0xFFE65100) : const Color(0xFF2E0342))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black.withOpacity(0.6))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!isVerified) ...[
                _BannerAction(
                  label: _sending ? '...' : 'Resend',
                  onTap: _sending
                      ? null
                      : () async {
                          setState(() => _sending = true);
                          try {
                            await AuthService().sendEmailVerification();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification email sent to $email'), backgroundColor: const Color(0xFF740690)));
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resend failed: $e'), backgroundColor: const Color(0xFF740690)));
                          } finally {
                            if (mounted) setState(() => _sending = false);
                          }
                        },
                ),
                const SizedBox(width: 6),
                _BannerAction(
                  label: _checking ? '...' : 'Check',
                  onTap: _checking
                      ? null
                      : () async {
                          setState(() => _checking = true);
                          try {
                            final v = await AuthService().reloadAndCheckVerified();
                            if (!mounted) return;
                            if (v) {
                              try { await UserRepository.instance.touchLogin(FirebaseAuth.instance.currentUser!); } catch (_) {}
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified ✓'), backgroundColor: Color(0xFF740690)));
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not verified yet — check inbox/spam'), backgroundColor: Color(0xFF740690)));
                            }
                          } finally {
                            if (mounted) setState(() => _checking = false);
                          }
                        },
                ),
              ] else ...[
                _BannerAction(
                  label: 'Add',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Verificationpage(email: email, showPhonePrompt: true))),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BannerAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _BannerAction({required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF740690), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String? uid;
  const _NotificationIcon({required this.uid});

  @override
  Widget build(BuildContext context) {
    final icon = GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.accent),
      ),
    );
    if (uid == null) return icon;
    return StreamBuilder<int>(
      stream: NotificationStore.watchUnreadCount(uid!),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        if (count == 0) return icon;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class InOutLoading extends StatelessWidget {
  final double width;
  final double height;
  const InOutLoading({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(145, 224, 224, 224),
      highlightColor: const Color.fromARGB(249, 245, 245, 245),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(127, 224, 224, 224),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  final String? uid;
  const _AddMoneySheet({required this.uid});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied'), backgroundColor: const Color(0xFF740690), duration: const Duration(seconds: 1)));
  }

  void _copyAll(String bankName, String acctNo, String acctName) {
    final all = 'Bank: $bankName\nAccount: $acctNo\nName: $acctName';
    Clipboard.setData(ClipboardData(text: all));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All details copied'), backgroundColor: Color(0xFF740690)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.uid;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ),

                  // Header with gradient accent
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Add Money', style: TextStyle(fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1E))),
                                  SizedBox(height: 4),
                                  Text('Fund your wallet via bank transfer', style: TextStyle(fontFamily: 'DMSans', fontSize: 12.5, color: Color(0xFF8A8A94)),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF8A8A94)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (uid == null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F5FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: const Color(0xFFEAC5F7).withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.login_rounded, color: Color(0xFF740690), size: 20),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(child: Text('Please log in to view your virtual account.', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF5A5A64)))),
                            ]),
                          )
                        else
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: UserRepository.instance.watchUser(uid),
                            builder: (context, userSnap) {
                              final userData = userSnap.data?.data();
                              final primary = userData?['primaryVirtualAccount'] as Map<String, dynamic>?;
                              final bankName = (primary?['bankName'] as String?)?.trim();
                              final acctNo = (primary?['accountNumber'] as String?)?.trim();
                              final acctRef = (primary?['accountReference'] as String?)?.trim();
                              final acctName = (primary?['accountName'] as String?)?.trim() ?? (userData?['username'] as String?) ?? '—';
                              final hasAccount = bankName != null && bankName.isNotEmpty && acctNo != null && acctNo.isNotEmpty;
                              if (!hasAccount) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F5FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(children: [
                                    Shimmer.fromColors(
                                      baseColor: const Color(0xFF740690).withValues(alpha: 0.3),
                                      highlightColor: const Color(0xFF740690).withValues(alpha: 0.1),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(color: Color(0xFF740690), shape: BoxShape.circle),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Text('Virtual account is being created...', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF5A5A64))),
                                    ),
                                  ]),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bank account card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: const Color(0xFFEAC5F7).withValues(alpha: 0.5)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(14),
                                                boxShadow: [BoxShadow(color: const Color(0xFF740690).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                                              ),
                                              child: const Icon(Icons.account_balance_rounded, size: 20, color: Color(0xFF740690)),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(bankName, style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2E0342))),
                                                  const SizedBox(height: 1),
                                                  Text(acctName, style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: Colors.black.withValues(alpha: 0.45))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        // Account number — prominent, tappable
                                        GestureDetector(
                                          onTap: () => _copy(context, acctNo, 'Account number'),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: const Color(0xFFEAC5F7).withValues(alpha: 0.6)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(acctNo, style: const TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1E), letterSpacing: 1.5)),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF3E5F5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.copy_rounded, size: 13, color: Color(0xFF740690)),
                                                      SizedBox(width: 4),
                                                      Text('Copy', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF740690))),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Tips
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAFAFA),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.lightbulb_rounded, size: 15, color: Color(0xFFF59E0B)),
                                            SizedBox(width: 8),
                                            Text('How it works', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1A1E))),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _TipRow(text: 'Transfer from any bank app to your $bankName account'),
                                        const SizedBox(height: 8),
                                        const _TipRow(text: 'Funds reflect instantly — pull down to refresh'),
                                        const SizedBox(height: 8),
                                        const _TipRow(text: 'Your dedicated account — save it for future top-ups'),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _copyAll(bankName, acctNo, acctName),
                                          icon: const Icon(Icons.copy_all_rounded, size: 16),
                                          label: const Text('Copy all details', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF740690),
                                            side: const BorderSide(color: Color(0xFFEAC5F7)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: acctNo));
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied — paste in your bank app'), backgroundColor: Color(0xFF740690)));
                                          },
                                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                          label: const Text('Pay now', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF740690),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shadowColor: const Color(0xFF740690).withValues(alpha: 0.3),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      'Powered by Monnify',
                                      style: TextStyle(fontFamily: 'DMSans', fontSize: 10.5, color: Colors.black.withValues(alpha: 0.25), letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(color: Color(0xFF740690), shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Colors.black.withValues(alpha: 0.55), height: 1.4))),
      ],
    );
  }
}

class _BuildResultBanner extends StatefulWidget {
  @override
  State<_BuildResultBanner> createState() => _BuildResultBannerState();
}

class _BuildResultBannerState extends State<_BuildResultBanner> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _elapsedTimer?.cancel();
        return;
      }
      final builds = BuildTracker.instance.builds.value;
      final active = builds.where((b) => b.status == 'building' || b.status == 'preparing');
      if (active.isEmpty) {
        _elapsedTimer?.cancel();
        return;
      }
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String _fmtElapsed(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  void _showCancelDialog(BuildContext context, BuildInfo build) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text('Cancel Build?', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to cancel building "${build.appName}"? This cannot be undone.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('No, keep', style: AppTextStyles.body(color: AppColors.textSecondary)),
              ),
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  BuildTracker.instance.cancelBuild(build.buildId);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Yes, cancel', style: AppTextStyles.body(color: AppColors.error).copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BuildInfo>>(
      valueListenable: BuildTracker.instance.builds,
      builder: (context, builds, _) {
        if (builds.isEmpty) return const SizedBox.shrink();

        final latest = builds.first;
        final isBuilding = latest.status == 'building' || latest.status == 'preparing';
        final isCompleted = latest.status == 'completed';
        final isFailed = latest.status == 'failed';
        final isCancelled = latest.status == 'cancelled';

        // Restart timer when build starts
        if (isBuilding && (_elapsedTimer == null || !_elapsedTimer!.isActive)) {
          _elapsed = DateTime.now().difference(latest.createdAt);
          _startElapsedTimer();
        }

        final bgColor = isCompleted
            ? const Color(0xFFE8F5E9)
            : isFailed || isCancelled
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFF3E5F5);
        final borderColor = isCompleted
            ? const Color(0xFF00875A)
            : isFailed || isCancelled
                ? const Color(0xFFC62828)
                : const Color(0xFF740690);
        final iconColor = isCompleted
            ? const Color(0xFF00875A)
            : isFailed || isCancelled
                ? const Color(0xFFC62828)
                : const Color(0xFF740690);

        final icon = isCompleted
            ? Icons.check_circle_rounded
            : isCancelled
                ? Icons.cancel_rounded
                : isFailed
                    ? Icons.error_rounded
                    : Icons.build_rounded;

        final title = isCompleted
            ? 'Build Complete'
            : isCancelled
                ? 'Build Cancelled'
                : isFailed
                    ? 'Build Failed'
                    : 'Building ${latest.appName}...';

        String subtitle;
        if (isBuilding) {
          subtitle = 'Elapsed: ${_fmtElapsed(_elapsed)} — Please keep the app open';
        } else if (isCompleted) {
          subtitle = '${latest.appName} is ready to download';
        } else if (isFailed) {
          subtitle = _sanitizeError(latest.error ?? 'An error occurred during build');
        } else if (isCancelled) {
          subtitle = 'The build was cancelled. You can restart from the canva.';
        } else {
          subtitle = 'Processing...';
        }

        final sizeText = latest.apkSize != null
            ? '${(latest.apkSize! / 1024 / 1024).toStringAsFixed(1)} MB'
            : '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isBuilding
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: iconColor,
                            ),
                          )
                        : Icon(icon, size: 19, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: borderColor)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black.withOpacity(0.55)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (sizeText.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(sizeText, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Colors.black.withOpacity(0.4))),
                        ],
                      ],
                    ),
                  ),
                  if (isBuilding) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showCancelDialog(context, latest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC62828).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stop_rounded, size: 14, color: Color(0xFFC62828)),
                            SizedBox(width: 4),
                            Text('Cancel', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC62828))),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isCompleted && latest.downloadUrl != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse('$kBuildServerUrl${latest.downloadUrl}');
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00875A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Download', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (isCompleted || isFailed || isCancelled) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => BuildTracker.instance.dismissBuild(0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close_rounded, size: 16, color: Colors.black.withOpacity(0.4)),
                      ),
                    ),
                  ],
                ],
              ),
              // Show error details for failed builds
              if (isFailed && latest.error != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _sanitizeError(latest.error!),
                    style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFFC62828), height: 1.4),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _sanitizeError(String error) {
    return error
        .replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '')
        .replaceAll(RegExp(r'Woah!.*?root\.\s*'), '')
        .replaceAll(RegExp(r'/\s*'), '')
        .replaceAll(RegExp(r'📎\s*'), '')
        .trim();
  }
}

class _UserListForGeneratedApp extends StatelessWidget {
  final String? uid;
  const _UserListForGeneratedApp({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const UserList(appId: null);

    return FutureBuilder<FirebaseFirestore>(
      future: BuilderFirestore.instance,
      builder: (context, dbSnap) {
        if (dbSnap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 76,
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 10, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 60, height: 8, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final db = dbSnap.data;
        if (db == null) {
          return const SizedBox(
            height: 76,
            child: Center(child: Text('Config error', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFC62828)))),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db
              .collection('apps')
              .doc('regentspace-builder')
              .collection('apps')
              .where('createdBy', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 76,
                child: Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100, height: 10, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(width: 60, height: 8, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const SizedBox(
                height: 76,
                child: Center(
                  child: Text('No new user yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFAAAAAA))),
                ),
              );
            }
            final appId = docs.first.id;
            return UserList(appId: appId);
          },
        );
      },
    );
  }
}
