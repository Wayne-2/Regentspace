import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/loadingpopup.dart';
import '../../components/userpfp.dart';
import '../../components/recent_activities.dart';
import '../../service/app_notifications.dart';
import '../../service/monnify_service.dart';
import '../../service/user_repository.dart';
import 'managerates.dart';

class Finances extends StatefulWidget {
  const Finances({super.key});

  @override
  State<Finances> createState() => _FinancesState();
}

class _FinancesState extends State<Finances> {
  final GlobalKey _walletButtonKey = GlobalKey();

  // Static mock user — no API
  static const mockUser = {
    'username': 'John Doe',
    'bankname': 'Wema Bank',
  };

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
          message: "This will create a new virtual account linked to your wallet. (Static demo)",
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
          message: "Access advanced account settings. (Static demo)",
          confirmLabel: "Manage",
          onConfirm: () => Navigator.pop(context),
        ),
      ),
      _WalletAction(
        label: "Delete Account",
        icon: Icons.delete_outline,
        color: Colors.redAccent,
        onTap: () => _showActionAlert(
          title: "Delete Account",
          message: "Are you sure you want to delete this virtual account? (Static demo)",
          confirmLabel: "Delete",
          confirmColor: Colors.redAccent,
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
              Icon(action.icon, color: action.color ?? Colors.deepPurple, size: 20),
              const SizedBox(width: 10),
              Text(action.label, style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
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
        title: Text(title, style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.bold, color: const Color.fromRGBO(46, 3, 66, 1))),
        content: Text(message, style: TextStyle(fontFamily: 'DMSans', fontSize: 15, color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(fontFamily: 'DMSans', color: Colors.grey[700]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? const Color.fromRGBO(108, 0, 144, 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onConfirm,
            child: Text(confirmLabel, style: TextStyle(fontFamily: 'DMSans', color: Colors.white)),
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
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 12),
            Text("Select Preferred Bank", style: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: supportedBanks.length,
                itemBuilder: (context, index) {
                  final bank = supportedBanks[index];
                  return ListTile(
                    leading: const Icon(Icons.account_balance, color: Color(0xFF740690)),
                    title: Text(bank["name"]!, style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w500)),
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
        title: const Text("Create Virtual Account"),
        content: Text("Proceed to create a virtual account with $bankName? (Static demo)"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createVirtualAccount(bankCode);
            },
            child: const Text("Yes, Continue"),
          ),
        ],
      ),
    );
  }

  Future<void> _createVirtualAccount(String bankCode) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: Loadingpopup()));
    try {
      // Prefer sandbox direct for dev; for prod set MONNIFY_USE_DIRECT=false + deploy Functions
      final doc = await MonnifyService.instance.createReservedAccount(
        getAllAvailableBanks: false,
        preferredBanks: [bankCode],
      );
      debugPrint('[Monnify DEBUG] manual create success doc=$doc');
      final acct = (doc['primaryAccountNumber'] ?? doc['accounts']?[0]?['accountNumber'] ?? bankCode).toString();
      final bank = (doc['primaryBankName'] ?? bankCode).toString();
      await AppNotifications.virtualAccountCreated(bankName: bank, accountNumber: acct);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Virtual account created: $bank • $acct'), backgroundColor: const Color(0xFF740690)),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Monnify DEBUG success: $bank • $acct', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
        backgroundColor: Colors.green.shade700,
        duration: Duration(seconds: 5),
      ));
    } catch (e) {
      debugPrint('[Monnify DEBUG] manual create failed: $e');
      if (!mounted) return;
      Navigator.pop(context);
      await AppNotifications.virtualAccountFailed();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Monnify DEBUG failed: $e', style: TextStyle(fontFamily: 'DMSans', fontSize: 11)),
        backgroundColor: Colors.red.shade700,
        duration: Duration(seconds: 8),
        action: SnackBarAction(label: 'COPY', textColor: Colors.white, onPressed: () => Clipboard.setData(ClipboardData(text: e.toString()))),
      ));
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Monnify debug — create failed', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(child: SelectableText(e.toString(), style: TextStyle(fontFamily: 'DMSans', fontSize: 10))),
        actions: [
          TextButton(onPressed: () { Clipboard.setData(ClipboardData(text: e.toString())); Navigator.pop(context); }, child: Text('Copy')),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 244, 255, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header — live from Firestore users/{uid} (email/Google) + monnify
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  final username = (data?['username'] ?? data?['displayName'] ?? mockUser['username']) as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hello Again",
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 12.5, color: const Color.fromRGBO(140, 140, 140, 1), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(username,
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 18, color: const Color.fromRGBO(64, 62, 62, 1), fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                          ],
                        ),
                        UserAvatar(name: username, size: 38),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Balance",
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: const Color.fromRGBO(112, 112, 112, 1), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text("₦45,230.00", style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_drop_down, size: 16, color: Color.fromRGBO(153, 0, 100, 1)),
                            Text("4,000 (25% interest)",
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: const Color.fromRGBO(153, 0, 100, 1), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                      builder: (context, snap2) {
                        final d2 = snap2.data?.data();
                        final primary = d2?['primaryVirtualAccount'] as Map<String, dynamic>?;
                        final bankName = (primary?['bankName'] as String?) ?? mockUser['bankname']!;
                        final acctNo = (primary?['accountNumber'] as String?) ?? '';
                        return GestureDetector(
                          key: _walletButtonKey,
                          onTap: () => _showWalletDropdown(_walletButtonKey),
                          child: Container(
                            width: 155,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: const Color.fromRGBO(234, 197, 247, 1),
                              border: Border.all(color: Colors.black.withOpacity(0.05)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Manage Wallet",
                                            style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: const Color.fromRGBO(76, 76, 76, 1), fontWeight: FontWeight.w600)),
                                        Text(
                                          acctNo.isEmpty ? bankName : '$bankName • ${acctNo.substring(acctNo.length - 4)}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontFamily: 'DMSans', fontSize: 10.5, color: const Color.fromARGB(255, 135, 0, 180), fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Color.fromRGBO(16, 16, 16, 1)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRatesPage())),
                        child: _buildActionButton("Manage Rates", filled: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildActionButton("Monitor Interests", outlined: true)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromRGBO(234, 197, 247, 1),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Finance summary",
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: const Color.fromRGBO(74, 0, 99, 1))),
                          Row(
                            children: [
                              _buildSummaryStat("Today's Earnings", "N2000.00"),
                              const SizedBox(width: 10),
                              Container(width: 1, height: 24, color: Colors.black26),
                              const SizedBox(width: 10),
                              _buildSummaryStat("Week's Earnings", "N5300.00"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryDetail("Percentage Interest", "25% per Earnings"),
                          _buildSummaryDetail("Withdrawal Balance", "N22,550.00", alignRight: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: const Color.fromRGBO(31, 31, 31, 1))),
                    Text('See all', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ],
                ),
              ),
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

  Widget _buildActionButton(String text, {bool filled = false, bool outlined = false, bool light = false}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: filled ? const Color.fromRGBO(153, 0, 204, 1) : light ? const Color.fromRGBO(234, 197, 247, 1) : Colors.white,
        border: outlined ? Border.all(color: const Color.fromRGBO(153, 0, 204, 1), width: 1.2) : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontFamily: 'DMSans', fontSize: 12.5, fontWeight: FontWeight.w600, color: filled ? Colors.white : const Color.fromRGBO(153, 0, 204, 1))),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: const Color.fromRGBO(191, 0, 255, 1), fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: const Color.fromRGBO(10, 0, 13, 1), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryDetail(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: const Color.fromRGBO(38, 38, 38, 1), fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: const Color.fromRGBO(15, 15, 15, 1), fontWeight: FontWeight.w700)),
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
