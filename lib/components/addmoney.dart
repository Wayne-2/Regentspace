import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Static UI only — no Riverpod, no url_launcher.
Future<void> addMoney(BuildContext context) async {
  showDialog(context: context, barrierDismissible: true, builder: (context) => const AddMoneyDialog());
}

class AddMoneyDialog extends StatelessWidget {
  const AddMoneyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Static mock wallet info — no backend
    const String accountName = "John Doe";
    const String bankName = "Wema Bank";
    const String accountNumber = "0123456789";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 248, 236, 255), borderRadius: BorderRadius.circular(12)),
                  child: Image.asset("assets/addLogo.png", width: 26, height: 26),
                ),
                const SizedBox(width: 12),
                Text("Add Money", style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1F0033))),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.05)),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("Fund this account", style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildInfoRow("Account Name", accountName),
            _buildInfoRow("Bank", bankName),
            _buildCopyRow(context, "Account Number", accountNumber),
            const Divider(height: 40, thickness: 1),
            Text("Or open your bank app directly",
                style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildBankButton(context, "Opay"),
            _buildBankButton(context, "Moniepoint"),
            _buildBankButton(context, "Palmpay"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCopyRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15)),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied (static demo)"), duration: Duration(milliseconds: 900), backgroundColor: Color(0xFF740690)),
              );
            },
            child: Row(
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF740690)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankButton(BuildContext context, String bankName) {
    final iconMap = {
      "Opay": "assets/opay.png",
      "Moniepoint": "assets/moniepoint.png",
      "Palmpay": "assets/palmpay.png",
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Open $bankName tapped (static demo)"), backgroundColor: const Color(0xFF740690)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: const Color.fromARGB(255, 245, 214, 255), width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage(iconMap[bankName] ?? "assets/addLogo.png"))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text("Open $bankName",
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF43106E))),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF740690)),
            ],
          ),
        ),
      ),
    );
  }
}
