import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ManageRatesPage extends StatefulWidget {
  const ManageRatesPage({super.key});

  @override
  State<ManageRatesPage> createState() => _ManageRatesPageState();
}

class _ManageRatesPageState extends State<ManageRatesPage> {
  // ── Airtime commission rates (%) ──
  final Map<String, double> airtimeRates = {
    'MTN': 3.5,
    'GLO': 3.0,
    'Airtel': 3.0,
    '9mobile': 3.0,
  };

  // ── Data profit margin (₦ per GB) ──
  final Map<String, Map<String, double>> dataRates = {
    'MTN': {'SME': 280, 'Gifting': 260, 'Corporate': 250},
    'GLO': {'SME': 270, 'Gifting': 250, 'Corporate': 240},
    'Airtel': {'SME': 285, 'Gifting': 265, 'Corporate': 255},
    '9mobile': {'SME': 300, 'Gifting': 280, 'Corporate': 270},
  };

  // ── Cable TV commission rates ──
  final Map<String, double> cableTvRates = {
    'DSTV': 2.5,
    'GOTV': 2.0,
    'Startimes': 1.5,
  };

  // ── Electricity processing fee (%) ──
  final Map<String, double> electricityRates = {
    'IKEDC': 1.0,
    'EKEDC': 1.0,
    'AEDC': 1.0,
    'IBEDC': 1.0,
    'PHED': 1.0,
    'KEDCO': 1.0,
    'JED': 1.0,
    'CEEDC': 1.0,
    'AEDC-Prepaid': 1.0,
  };

  // ── Service toggles ──
  final Map<String, bool> serviceToggles = {
    'Airtime': true,
    'Data': true,
    'Cable TV': true,
    'Electricity': true,
    'Education': false,
  };

  // ── Transaction limits ──
  double minTransaction = 100;
  double maxTransaction = 500000;

  void _editRateDialog({
    required String title,
    required String label,
    required double currentValue,
    required ValueChanged<double> onSave,
    String? suffix,
    double? min,
    double? max,
  }) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(title, textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, textAlign: TextAlign.center, style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: suffix,
                  suffixStyle: AppTextStyles.body(color: AppColors.textTertiary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              if (min != null || max != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Range: ${min ?? 0} - ${max ?? '∞'}${suffix ?? ''}',
                  style: AppTextStyles.caption(color: AppColors.textHint),
                ),
              ],
            ],
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () {
                    final newValue = double.tryParse(controller.text);
                    if (newValue != null) {
                      onSave(newValue);
                      Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text("Save", style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                ),
                Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text("Cancel", style: AppTextStyles.body(color: AppColors.primary)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _editDataRateDialog(String network, String type, double currentRate) {
    _editRateDialog(
      title: '$network $type Rate',
      label: 'Profit margin per GB',
      currentValue: currentRate,
      suffix: '₦',
      min: 0,
      max: 500,
      onSave: (v) => setState(() => dataRates[network]![type] = v),
    );
  }

  void _editAirtimeRateDialog(String network, double currentRate) {
    _editRateDialog(
      title: '$network Commission Rate',
      label: 'Commission percentage you earn per sale',
      currentValue: currentRate,
      suffix: '%',
      min: 0,
      max: 10,
      onSave: (v) => setState(() => airtimeRates[network] = v),
    );
  }

  void _editCableTvRateDialog(String provider, double currentRate) {
    _editRateDialog(
      title: '$provider Commission Rate',
      label: 'Commission percentage you earn per subscription',
      currentValue: currentRate,
      suffix: '%',
      min: 0,
      max: 10,
      onSave: (v) => setState(() => cableTvRates[provider] = v),
    );
  }

  void _editElectricityRateDialog(String disco, double currentRate) {
    _editRateDialog(
      title: '$disco Processing Fee',
      label: 'Processing fee percentage',
      currentValue: currentRate,
      suffix: '%',
      min: 0,
      max: 5,
      onSave: (v) => setState(() => electricityRates[disco] = v),
    );
  }

  void _editTransactionLimitsDialog() {
    final minCtrl = TextEditingController(text: minTransaction.toStringAsFixed(0));
    final maxCtrl = TextEditingController(text: maxTransaction.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text("Transaction Limits", textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minimum Transaction (₦)',
                  labelStyle: AppTextStyles.body(color: AppColors.textTertiary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Maximum Transaction (₦)',
                  labelStyle: AppTextStyles.body(color: AppColors.textTertiary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () {
                    final minVal = double.tryParse(minCtrl.text) ?? 100;
                    final maxVal = double.tryParse(maxCtrl.text) ?? 500000;
                    setState(() {
                      minTransaction = minVal;
                      maxTransaction = maxVal;
                    });
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text("Save", style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                ),
                Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text("Cancel", style: AppTextStyles.body(color: AppColors.primary)),
                ),
              ],
            ),
          ],
        );
      },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Set your commission rates and profit margins for each service.", style: AppTextStyles.body(color: AppColors.textTertiary)),
            const SizedBox(height: 20),

            // ── Transaction Limits ──
            _buildSectionHeader('Transaction Limits', Icons.swap_horiz_rounded),
            const SizedBox(height: 10),
            _buildTransactionLimitsCard(),
            const SizedBox(height: 20),

            // ── Airtime Rates ──
            _buildSectionHeader('Airtime Commission', Icons.phone_android_rounded),
            const SizedBox(height: 10),
            _buildAirtimeRatesCard(),
            const SizedBox(height: 20),

            // ── Data Rates ──
            _buildSectionHeader('Data Profit Margins', Icons.wifi_rounded),
            const SizedBox(height: 10),
            _buildDataRatesCard(),
            const SizedBox(height: 20),

            // ── Cable TV Rates ──
            _buildSectionHeader('Cable TV Commission', Icons.tv_rounded),
            const SizedBox(height: 10),
            _buildCableTvRatesCard(),
            const SizedBox(height: 20),

            // ── Electricity Rates ──
            _buildSectionHeader('Electricity Processing Fee', Icons.flash_on_rounded),
            const SizedBox(height: 10),
            _buildElectricityRatesCard(),
            const SizedBox(height: 20),

            // ── Service Toggles ──
            _buildSectionHeader('Enable/Disable Services', Icons.toggle_on_rounded),
            const SizedBox(height: 10),
            _buildServiceTogglesCard(),
            const SizedBox(height: 24),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Rates saved successfully"), backgroundColor: AppColors.primary),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text("Save All Changes", style: AppTextStyles.label(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTransactionLimitsCard() {
    return GestureDetector(
      onTap: _editTransactionLimitsDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Min: ₦${minTransaction.toStringAsFixed(0)}", style: AppTextStyles.body(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text("Max: ₦${maxTransaction.toStringAsFixed(0)}", style: AppTextStyles.body(color: AppColors.textPrimary)),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirtimeRatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: airtimeRates.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: AppTextStyles.body(color: AppColors.textPrimary)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${entry.value.toStringAsFixed(1)}%",
                        style: AppTextStyles.titleSmall(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _editAirtimeRateDialog(entry.key, entry.value),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: dataRates.entries.map((networkEntry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(networkEntry.key, style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ...networkEntry.value.entries.map((typeEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(typeEntry.key, style: AppTextStyles.caption(color: AppColors.textTertiary)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "₦${typeEntry.value.toStringAsFixed(0)}/GB",
                                style: AppTextStyles.caption(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _editDataRateDialog(networkEntry.key, typeEntry.key, typeEntry.value),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCableTvRatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: cableTvRates.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: AppTextStyles.body(color: AppColors.textPrimary)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${entry.value.toStringAsFixed(1)}%",
                        style: AppTextStyles.titleSmall(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _editCableTvRateDialog(entry.key, entry.value),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElectricityRatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: electricityRates.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: AppTextStyles.body(color: AppColors.textPrimary)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${entry.value.toStringAsFixed(1)}%",
                        style: AppTextStyles.titleSmall(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _editElectricityRateDialog(entry.key, entry.value),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceTogglesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Column(
        children: serviceToggles.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: AppTextStyles.body(color: AppColors.textPrimary)),
                Switch(
                  value: entry.value,
                  onChanged: (v) => setState(() => serviceToggles[entry.key] = v),
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
