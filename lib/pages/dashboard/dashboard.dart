import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../service/user_repository.dart';
import '../../auth_page/verificationpage.dart';
import '../../service/auth_service.dart';
import '../../service/notification_store.dart';
import '../../service/monnify_service.dart';
import '../../service/monnify_config.dart';
import '../../components/notificationpage.dart';
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
      backgroundColor: Color.fromARGB(255, 253, 244, 255),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/profile-1.svg',
                    height: 36,
                    width: 36,
                  ),
                  const SizedBox(width: 10),
                  // Search bar - flexible
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAC5F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              height: 16,
                              width: 16,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search Regentspace',
                                hintStyle: TextStyle(fontSize: 12.5, color: Color.fromARGB(255, 25, 27, 35), fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Action buttons
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFFEAC5F7),
                        child: SvgPicture.asset(
                          'assets/icons/customer-care.svg',
                          width: 18,
                          height: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification icon with unread badge and navigation
                      _NotificationIcon(uid: uid),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.8, color: Color(0xFF740690)),
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
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAC5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/refresh.svg', width: 18, height: 18),
                            const SizedBox(width: 6),
                            const Text('View History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 78, 6, 102))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _showAddMoneySheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAC5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/add_money.svg', width: 18, height: 18),
                            const SizedBox(width: 6),
                            const Text('Add Money', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 78, 6, 102))),
                          ],
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
                                onTap: () {},
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("New Users", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 78, 6, 102))),
                      GestureDetector(
                        onTap: () {},
                        child: const Text("View all", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 78, 6, 102), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const UserList(),
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
      child: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFFEAC5F7),
        child: SvgPicture.asset('assets/icons/nofication.svg', width: 18, height: 18),
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
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
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
  bool _showCardView = false;

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
        color: Color.fromARGB(255, 253, 244, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Money', style: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 78, 6, 102))),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFFEAC5F7), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, size: 18, color: Color.fromARGB(255, 78, 6, 102)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Fund your wallet via bank transfer — works from any Nigerian bank app.', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color.fromARGB(190, 25, 27, 35))),
                  const SizedBox(height: 16),
                  if (uid == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04))),
                      child: const Row(children: [Icon(Icons.login_rounded, color: Color(0xFF740690)), SizedBox(width: 10), Expanded(child: Text('Please log in to view your virtual account.', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)))]),
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
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04))),
                            child: Row(children: [
                              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF740690))),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Virtual account is being created... Pull down on dashboard to refresh.', style: TextStyle(fontFamily: 'DMSans', fontSize: 12.5))),
                            ]),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // View toggle
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('List', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600)),
                                  selected: !_showCardView,
                                  selectedColor: const Color(0xFF740690),
                                  labelStyle: TextStyle(color: !_showCardView ? Colors.white : const Color(0xFF740690)),
                                  backgroundColor: const Color(0xFFEAC5F7),
                                  onSelected: (v) => setState(() => _showCardView = false),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Card', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600)),
                                  selected: _showCardView,
                                  selectedColor: const Color(0xFF740690),
                                  labelStyle: TextStyle(color: _showCardView ? Colors.white : const Color(0xFF740690)),
                                  backgroundColor: const Color(0xFFEAC5F7),
                                  onSelected: (v) => setState(() => _showCardView = true),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _copyAll(bankName, acctNo, acctName),
                                  icon: const Icon(Icons.copy_all_rounded, size: 16, color: Color(0xFF740690)),
                                  label: const Text('Copy all', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF740690), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_showCardView)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF740690), Color(0xFF9C27B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(color: const Color(0xFF740690).withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 6))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(bankName, style: const TextStyle(fontFamily: 'DMSans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                        const Icon(Icons.account_balance_rounded, color: Colors.white70, size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Text(acctNo, style: const TextStyle(fontFamily: 'DMSans', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 1.2)),
                                    const SizedBox(height: 6),
                                    Text(acctName, style: const TextStyle(fontFamily: 'DMSans', color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => _copy(context, acctNo, 'Account number'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.copy_rounded, size: 14, color: Color(0xFF740690)), SizedBox(width: 6), Text('Copy number', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF740690)))]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _copy(context, bankName, 'Bank name'),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white30)),
                                            child: const Text('Copy bank', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            else
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: (acctRef == null || acctRef.isEmpty) ? null : FirebaseFirestore.instance.collection('monnify_reserved_accounts').doc(acctRef).snapshots(),
                                builder: (context, acctSnap) {
                                  final acctData = acctSnap.data?.data();
                                  final accounts = (acctData?['accounts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                                  final listToShow = accounts.isNotEmpty
                                      ? accounts
                                      : [
                                          {'bankName': bankName, 'accountNumber': acctNo, 'bankCode': primary?['bankCode'] ?? ''}
                                        ];
                                  return Column(
                                    children: listToShow.map((a) {
                                      final bName = (a['bankName'] as String?) ?? bankName;
                                      final aNo = (a['accountNumber'] as String?) ?? acctNo;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(10)),
                                              child: const Icon(Icons.account_balance_rounded, size: 18, color: Color(0xFF740690)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(bName, style: const TextStyle(fontFamily: 'DMSans', fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF2E0342))),
                                                  const SizedBox(height: 2),
                                                  Text(aNo, style: const TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1F1F1F), letterSpacing: 0.4)),
                                                  const SizedBox(height: 2),
                                                  Text(acctName, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.black.withOpacity(0.55))),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _copy(context, aNo, 'Account number'),
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(color: const Color(0xFF740690), borderRadius: BorderRadius.circular(10)),
                                                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.copy_rounded, size: 14, color: Colors.white), SizedBox(width: 4), Text('Copy', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            const SizedBox(height: 14),
                            // Suggestions / tips
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEAC5F7)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle), child: const Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFF740690))), const SizedBox(width: 8), const Text('Tips', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF2E0342)))]),
                                  const SizedBox(height: 8),
                                  _TipRow(text: 'Use bank transfer from any app — choose $bankName or any listed bank.'),
                                  const SizedBox(height: 6),
                                  const _TipRow(text: 'Funds reflect instantly; if delayed, pull to refresh on dashboard.'),
                                  const SizedBox(height: 6),
                                  const _TipRow(text: 'Account is dedicated to you — keep it for future top-ups.'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _copyAll(bankName, acctNo, acctName),
                                          icon: const Icon(Icons.copy_all_rounded, size: 16),
                                          label: const Text('Copy details', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600)),
                                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF740690), side: const BorderSide(color: Color(0xFF740690)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: acctNo));
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied — paste in your bank app'), backgroundColor: Color(0xFF740690)));
                                          },
                                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                          label: const Text('Pay now', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700)),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF740690), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(child: Text('Powered by Monnify • NGN only', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Colors.black.withOpacity(0.35)))),
                          ],
                        );
                      },
                    ),
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
        const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF4CAF50))),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: Colors.black.withOpacity(0.65), height: 1.3))),
      ],
    );
  }
}
