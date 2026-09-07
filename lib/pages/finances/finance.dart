import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../components/loadingpopup.dart';
import '../../components/recent_activities.dart';
import '../../service/app_notifications.dart';
import '../../service/monnify_service.dart';
import '../../service/monnify_config.dart';
import '../../service/user_repository.dart';
import 'managerates.dart';
import 'monitor_interest.dart';
import 'all_recent_activity.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  String _fmtBalance(num? v) {
    if (v == null) return '₦0.00';
    return NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2).format(v);
  }

  final List<Map<String, String>> supportedBanks = const [
    {"name": "Wema Bank", "code": "035"},
    {"name": "Sterling Bank", "code": "232"},
  ];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.title(color: AppColors.textPrimary)),
        content: Text(message, style: AppTextStyles.body(color: AppColors.textSecondary)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Cancel", style: AppTextStyles.body(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor ?? AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: onConfirm,
                  child: Text(confirmLabel, style: AppTextStyles.body(color: Colors.white)),
                ),
              ),
            ],
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Select Preferred Bank", style: AppTextStyles.title()),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Choose a bank for your virtual account", style: AppTextStyles.caption(color: AppColors.textTertiary)),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: supportedBanks.length,
                itemBuilder: (context, index) {
                  final bank = supportedBanks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                      ),
                      title: Text(bank["name"]!, style: AppTextStyles.body(color: AppColors.textPrimary)),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmCreateAccount(context, bank["name"]!, bank["code"]!);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create Virtual Account", style: AppTextStyles.title()),
        content: Text("Proceed to create a virtual account with $bankName?", style: AppTextStyles.body(color: AppColors.textSecondary)),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("Cancel", style: AppTextStyles.body(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _createVirtualAccount(bankCode);
                  },
                  child: Text("Continue", style: AppTextStyles.body(color: Colors.white)),
                ),
              ),
            ],
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
      backgroundColor: Colors.white,
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF4FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
                          ),
                          child: Center(
                            child: Text(initials, style: AppTextStyles.title(color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Balance ──
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Balance", style: AppTextStyles.caption(color: AppColors.textTertiary)),
                            const SizedBox(height: 4),
                            Text(displayBalance, style: AppTextStyles.display(color: AppColors.primaryDark)),
                            const SizedBox(height: 2),
                            Text('$bankName • $last4', style: AppTextStyles.caption(color: AppColors.textTertiary)),
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MonitorInterestPage())),
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
                          Expanded(child: _buildSummaryTile("Interest Rate", "25%")),
                          Container(width: 1, height: 32, color: AppColors.primaryLight),
                          Expanded(child: _buildSummaryTile("Today's Earnings", "₦2,000.00")),
                          Container(width: 1, height: 32, color: AppColors.primaryLight),
                          Expanded(child: _buildSummaryTile("Withdrawal Balance", "₦22,550.00")),
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
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllRecentActivityPage())),
                      child: Text('See all', style: AppTextStyles.caption(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RecentActivities(limit: 5),
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
        Text(label, style: AppTextStyles.caption(color: AppColors.accent), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleSmall(color: AppColors.textPrimary), textAlign: TextAlign.center),
      ],
    );
  }
}
