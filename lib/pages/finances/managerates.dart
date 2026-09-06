import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';

class ManageRatesPage extends StatefulWidget {
  const ManageRatesPage({super.key});

  @override
  State<ManageRatesPage> createState() => _ManageRatesPageState();
}

class _ManageRatesPageState extends State<ManageRatesPage> {
  final Map<String, double> airtimeRates = {
    'MTN': 98.0,
    'GLO': 97.0,
    'Airtel': 96.0,
    '9mobile': 95.0,
  };

  final Map<String, double> dataRates = {
    'MTN': 280,
    'GLO': 270,
    'Airtel': 285,
    '9mobile': 300,
  };

  void _editRateDialog(String type, String network, double currentRate) {
    final controller = TextEditingController(text: currentRate.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Edit $network $type Rate",
            style: AppTextStyles.title(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: type == "Airtime" ? "Discount (%)" : "₦ per GB",
              labelStyle: AppTextStyles.body(color: AppColors.textTertiary),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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
                      final newRate = double.tryParse(controller.text);
                      if (newRate != null) {
                        setState(() {
                          if (type == "Airtime") {
                            airtimeRates[network] = newRate;
                          } else {
                            dataRates[network] = newRate;
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Save", style: AppTextStyles.body(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRateCard(String title, Map<String, double> rates, String type) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title(color: AppColors.primaryDark)),
            const Divider(height: 20, thickness: 0.6),
            ...rates.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: AppTextStyles.body(color: AppColors.textPrimary)),
                    Row(
                      children: [
                        Text(
                          type == "Airtime" ? "${entry.value.toStringAsFixed(1)}%" : "₦${entry.value.toStringAsFixed(0)}",
                          style: AppTextStyles.titleSmall(color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _editRateDialog(type, entry.key, entry.value),
                          child: const Icon(CupertinoIcons.pencil_circle, color: AppColors.primary, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Manage Rates", style: AppTextStyles.headline(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Adjust your data and airtime rates to suit your business preferences.", style: AppTextStyles.body(color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            _buildRateCard("Airtime Rates", airtimeRates, "Airtime"),
            _buildRateCard("Data Rates", dataRates, "Data"),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rates saved successfully"), backgroundColor: AppColors.primary),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  label: Text("Save Changes", style: AppTextStyles.label(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
