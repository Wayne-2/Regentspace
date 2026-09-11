import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ManageRatesPage extends StatefulWidget {
  const ManageRatesPage({super.key});

  @override
  State<ManageRatesPage> createState() => _ManageRatesPageState();
}

class _ManageRatesPageState extends State<ManageRatesPage> {
  final Map<String, double> airtimeRates = {
    'MTN': 3.5,
    'GLO': 3.0,
    'Airtel': 3.0,
    '9mobile': 3.0,
  };

  final Map<String, Map<String, double>> dataRates = {
    'MTN': {'SME': 280, 'Gifting': 260, 'Corporate': 250},
    'GLO': {'SME': 270, 'Gifting': 250, 'Corporate': 240},
    'Airtel': {'SME': 285, 'Gifting': 265, 'Corporate': 255},
    '9mobile': {'SME': 300, 'Gifting': 280, 'Corporate': 270},
  };

  final Map<String, double> cableTvRates = {
    'DSTV': 2.5,
    'GOTV': 2.0,
    'Startimes': 1.5,
  };

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

  final Map<String, bool> serviceToggles = {
    'Airtime': true,
    'Data': true,
    'Cable TV': true,
    'Electricity': true,
    'Education': false,
  };

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

            _buildSectionHeader('Transaction Limits', Icons.swap_horiz_rounded),
            const SizedBox(height: 10),
            _buildTransactionLimitsTile(),
            const SizedBox(height: 20),

            _buildSectionHeader('Airtime Commission', Icons.phone_android_rounded),
            const SizedBox(height: 10),
            ...airtimeRates.entries.map((e) => _buildRateTile(
              icon: Icons.phone_android_rounded,
              title: e.key,
              subtitle: 'Commission per sale',
              value: '${e.value.toStringAsFixed(1)}%',
              onTap: () => _editAirtimeRateDialog(e.key, e.value),
            )),
            const SizedBox(height: 20),

            _buildSectionHeader('Data Profit Margins', Icons.wifi_rounded),
            const SizedBox(height: 10),
            ...dataRates.entries.expand((network) => network.value.entries.map((type) => _buildRateTile(
              icon: Icons.wifi_rounded,
              title: '${network.key} ${type.key}',
              subtitle: 'Profit per GB',
              value: '₦${type.value.toStringAsFixed(0)}/GB',
              onTap: () => _editDataRateDialog(network.key, type.key, type.value),
            ))),
            const SizedBox(height: 20),

            _buildSectionHeader('Cable TV Commission', Icons.tv_rounded),
            const SizedBox(height: 10),
            ...cableTvRates.entries.map((e) => _buildRateTile(
              icon: Icons.tv_rounded,
              title: e.key,
              subtitle: 'Commission per subscription',
              value: '${e.value.toStringAsFixed(1)}%',
              onTap: () => _editCableTvRateDialog(e.key, e.value),
            )),
            const SizedBox(height: 20),

            _buildSectionHeader('Electricity Processing Fee', Icons.flash_on_rounded),
            const SizedBox(height: 10),
            ...electricityRates.entries.map((e) => _buildRateTile(
              icon: Icons.flash_on_rounded,
              title: e.key,
              subtitle: 'Processing fee',
              value: '${e.value.toStringAsFixed(1)}%',
              onTap: () => _editElectricityRateDialog(e.key, e.value),
            )),
            const SizedBox(height: 20),

            _buildSectionHeader('Enable/Disable Services', Icons.toggle_on_rounded),
            const SizedBox(height: 10),
            ...serviceToggles.entries.map((e) => _buildToggleTile(
              title: e.key,
              value: e.value,
              onChanged: (v) => setState(() => serviceToggles[e.key] = v),
            )),
            const SizedBox(height: 24),

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

  Widget _buildTransactionLimitsTile() {
    return GestureDetector(
      onTap: _editTransactionLimitsDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8EA)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Transaction Limits', overflow: TextOverflow.ellipsis, style: AppTextStyles.body(color: AppColors.textPrimary))),
                      const SizedBox(width: 8),
                      Text('₦${minTransaction.toStringAsFixed(0)} - ₦${maxTransaction.toStringAsFixed(0)}', style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Min & max per transaction', overflow: TextOverflow.ellipsis, style: AppTextStyles.caption(color: AppColors.textTertiary))),
                      const SizedBox(width: 8),
                      Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8EA)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF4FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
              ),
              child: Center(
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, overflow: TextOverflow.ellipsis, style: AppTextStyles.body(color: AppColors.textPrimary))),
                      const SizedBox(width: 8),
                      Text(value, style: AppTextStyles.titleSmall(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(subtitle, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption(color: AppColors.textTertiary))),
                      const SizedBox(width: 8),
                      Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8EA)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value ? const Color(0xFFFDF4FF) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value ? const Color(0xFFEAC5F7) : const Color(0xFFE8E8EA),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                value ? Icons.check_rounded : Icons.close_rounded,
                size: 18,
                color: value ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.body(color: AppColors.textPrimary)),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
