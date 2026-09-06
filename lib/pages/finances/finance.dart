import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../components/loadingpopup.dart';
import '../../components/userpfp.dart';
import '../../components/recent_activities.dart';
import '../../service/app_notifications.dart';
import '../../service/monnify_service.dart';
import '../../service/monnify_config.dart';
import '../../service/user_repository.dart';
import 'managerates.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  final GlobalKey _walletButtonKey = GlobalKey();

  String _fmtBalance(num? v) {
    if (v == null) return '₦0.00';
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(v);
  }

  final List<Map<String, String>> supportedBanks = const [
    {"name": "Wema Bank", "code": "035"},
    {"name": "Sterling Bank", "code": "232"},
  ];

  void _showWalletDropdown(GlobalKey key) async {
    final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    final List<_WalletAction> actions = [
      _WalletAction(
        label: "Create Virtual Account",
        icon: Icons.add_circle_outline,
        onTap: () => _showActionAlert(
          title: "Create Virtual Account",
          message: "This will create a new virtual account linked to your wallet.",
          confirmLabel: "Create",
          onConfirm: () {
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 100), () => _showBankSelectionSheet(context));
          },
        ),
      ),
      _WalletAction(
        label: "Manage Account",
        icon: Icons.settings_outlined,
        onTap: () => _showActionAlert(
          title: "Manage Account",
          message: "Access advanced account settings.",
          confirmLabel: "Manage",
          onConfirm: () => Navigator.pop(context),
        ),
      ),
      _WalletAction(
        label: "Delete Account",
        icon: Icons.delete_outline,
        color: AppColors.error,
        onTap: () => _showActionAlert(
          title: "Delete Account",
          message: "Are you sure you want to delete this virtual account?",
          confirmLabel: "Delete",
          confirmColor: AppColors.error,
          onConfirm: () => Navigator.pop(context),
        ),
      ),
    ];

    final result = await showMenu<_WalletAction>(
      context: context,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height + 6,
        position.dx + button.size.width,
        0,
      ),
      items: actions.map((action) {
        return PopupMenuItem<_WalletAction>(
          value: action,
          child: Row(
            children: [
              Icon(action.icon, color: action.color ?? AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(action.label, style: AppTextStyles.body(color: AppColors.textPrimary)),
            ],
          ),
        );
      }).toList(),
    );

    result?.onTap();
  }

  void _showActionAlert({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    Color? confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.title(color: AppColors.textPrimary)),
        content: Text(message, style: AppTextStyles.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: AppTextStyles.body(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onConfirm,
            child: Text(confirmLabel, style: AppTextStyles.body(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBankSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            Text("Select Preferred Bank", style: AppTextStyles.title()),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: supportedBanks.length,
                itemBuilder: (context, index) {
                  final bank = supportedBanks[index];
                  return ListTile(
                    leading: const Icon(Icons.account_balance, color: AppColors.primary),
                    title: Text(bank["name"]!, style: AppTextStyles.body(color: AppColors.textPrimary)),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmCreateAccount(context, bank["name"]!, bank["code"]!);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmCreateAccount(BuildContext context, String bankName, String bankCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Create Virtual Account", style: AppTextStyles.title()),
        content: Text("Proceed to create a virtual account with $bankName?", style: AppTextStyles.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: AppTextStyles.body(color: AppColors.textTertiary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createVirtualAccount(bankCode);
            },
            child: Text("Continue", style: AppTextStyles.body(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _createVirtualAccount(String bankCode) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: Loadingpopup()));
    try {
      final doc = await MonnifyService.instance.createReservedAccount(
        getAllAvailableBanks: false,
        preferredBanks: [bankCode],
      );
      final acct = (doc['primaryAccountNumber'] ?? doc['accounts']?[0]?['accountNumber'] ?? bankCode).toString();
      final bank = (doc['primaryBankName'] ?? bankCode).toString();
      await AppNotifications.virtualAccountCreated(bankName: bank, accountNumber: acct);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Virtual account created: $bank • $acct'), backgroundColor: AppColors.primary),
      );
    } catch (e) {
      debugPrint('[Monnify] manual create failed: $e');
      if (!mounted) return;
      Navigator.pop(context);
      await AppNotifications.virtualAccountFailed();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed: $e', style: AppTextStyles.body(color: Colors.white)),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header with user name from Firestore ──
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  final username = (data?['username'] ?? data?['displayName'] ?? 'User') as String;
                  final initials = username.length >= 2 ? username.substring(0, 2).toUpperCase() : username.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hello Again", style: AppTextStyles.caption(color: AppColors.textTertiary)),
                            const SizedBox(height: 2),
                            Text(username, style: AppTextStyles.headline(color: AppColors.textPrimary)),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFE5E5E5),
                          child: Text(initials, style: AppTextStyles.title(color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Balance + Wallet button ──
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                builder: (context, userSnap) {
                  final userData = userSnap.data?.data();
                  final primary = userData?['primaryVirtualAccount'] as Map<String, dynamic>?;
                  final bankName = (primary?['bankName'] as String?) ?? '';
                  final acctNo = (primary?['accountNumber'] as String?) ?? '';
                  final acctRef = (primary?['accountReference'] as String?) ?? '';
                  final hasAccount = bankName.isNotEmpty && acctNo.isNotEmpty;

                  if (!hasAccount) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Balance", style: AppTextStyles.caption(color: AppColors.textTertiary)),
                          const SizedBox(height: 4),
                          Text('₦0.00', style: AppTextStyles.display(color: AppColors.primaryDark)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, color: AppColors.primary)),
                              const SizedBox(width: 6),
                              Text('Setting up virtual account...', style: AppTextStyles.caption(color: AppColors.textTertiary)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: acctRef.isEmpty
                        ? null
                        : FirebaseFirestore.instance.collection('monnify_reserved_accounts').doc(acctRef).snapshots(),
                    builder: (context, acctSnap) {
                      final acctData = acctSnap.data?.data();
                      final balance = (acctData?['totalReceived'] as num?) ?? (primary?['balance'] as num?) ?? 0;
                      final displayBalance = _fmtBalance(balance);
                      final last4 = acctNo.length >= 4 ? acctNo.substring(acctNo.length - 4) : acctNo;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total Balance", style: AppTextStyles.caption(color: AppColors.textTertiary)),
                                  const SizedBox(height: 4),
                                  Text(displayBalance, style: AppTextStyles.display(color: AppColors.primaryDark)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              key: _walletButtonKey,
                              onTap: () => _showWalletDropdown(_walletButtonKey),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primaryLight),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Manage Wallet", style: AppTextStyles.caption(color: AppColors.textPrimary)),
                                        const SizedBox(height: 1),
                                        Text('$bankName • $last4', overflow: TextOverflow.ellipsis, style: AppTextStyles.caption(color: AppColors.accent)),
                                      ],
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 8),

              // ── Action buttons ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRatesPage())),
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
                                  child: const Icon(Icons.speed_rounded, size: 19, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Manage Rates', style: AppTextStyles.label(color: Colors.white)),
                                      const SizedBox(height: 1),
                                      Text('Airtime & data', style: AppTextStyles.caption(color: Colors.white.withValues(alpha: 0.7))),
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
                          onTap: () {},
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryLight, width: 1),
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
                                  child: const Icon(Icons.trending_up_rounded, size: 19, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Monitor Interest', style: AppTextStyles.label(color: AppColors.textPrimary)),
                                      const SizedBox(height: 1),
                                      Text('Earnings tracker', style: AppTextStyles.caption(color: AppColors.textTertiary)),
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
              ),

              const SizedBox(height: 6),

              // ── Finance summary card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primarySoft,
                    border: Border.all(color: AppColors.primaryLight, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Finance Summary", style: AppTextStyles.titleSmall(color: AppColors.primaryDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSummaryTile("Today's Earnings", "₦2,000.00")),
                          Container(width: 1, height: 32, color: AppColors.primaryLight),
                          Expanded(child: _buildSummaryTile("Week's Earnings", "₦5,300.00")),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryDetail("Interest Rate", "25%"),
                          _buildSummaryDetail("Withdrawal Balance", "₦22,550.00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Recent Activity ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: AppTextStyles.title(color: AppColors.textPrimary)),
                    Text('See all', style: AppTextStyles.caption(color: AppColors.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RecentActivities(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.accent)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSummaryDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.title(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _WalletAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  _WalletAction({required this.label, required this.icon, required this.onTap, this.color});
}
