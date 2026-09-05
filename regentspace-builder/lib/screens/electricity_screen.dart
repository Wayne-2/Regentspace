import 'package:flutter/material.dart';
import '../config/build_config.dart';
import '../service/vtpass_config.dart';
import '../service/vtpass_service.dart';
import '../service/app_notifications.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  String? _selectedDisco;
  String? _selectedType;
  final _meterController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;

  final _discos = [
    {'id': 'ikeja-electric', 'name': 'Ikeja Electric (IKEDC)', 'short': 'IKEDC'},
    {'id': 'eko-electric', 'name': 'Eko Electricity (EKEDC)', 'short': 'EKEDC'},
    {'id': 'abuja-electric', 'name': 'Abuja Electric (AEDC)', 'short': 'AEDC'},
    {'id': 'ibadan-electric', 'name': 'Ibadan Electric (IBEDC)', 'short': 'IBEDC'},
    {'id': 'portharcourt-electric', 'name': 'Port Harcourt (PHED)', 'short': 'PHED'},
    {'id': 'kano-electric', 'name': 'Kano Electric (KEDCO)', 'short': 'KEDCO'},
    {'id': 'jos-electric', 'name': 'Jos Electric (JED)', 'short': 'JED'},
    {'id': 'kaduna-electric', 'name': 'Kaduna Electric (KAEDCO)', 'short': 'KAEDCO'},
    {'id': 'enugu-electric', 'name': 'Enugu Electric (EEDC)', 'short': 'EEDC'},
    {'id': 'benin-electric', 'name': 'Benin Electric (BEDC)', 'short': 'BEDC'},
  ];

  final _types = [
    {'id': 'prepaid', 'name': 'Prepaid'},
    {'id': 'postpaid', 'name': 'Postpaid'},
  ];

  @override
  void dispose() {
    _meterController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    if (_selectedDisco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a distribution company')),
      );
      return;
    }
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select prepaid or postpaid')),
      );
      return;
    }
    final meter = _meterController.text.trim();
    if (meter.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid meter number')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    if (!VtpassConfig.isConfigured) {
      await VtpassConfig.ensureConfigured();
      if (!VtpassConfig.isConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('VTPass not configured.')),
          );
        }
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final res = await VtpassService.instance.buyElectricity(
        serviceID: _selectedDisco!,
        variationCode: _selectedType!,
        meterNumber: meter,
        amount: amount,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      );
      final content = res['content'];
      final transactions = (content is Map<String, dynamic>)
          ? (content['transactions'] as Map<String, dynamic>? ?? {})
          : <String, dynamic>{};
      final status = transactions['status'] ?? 'unknown';
      final extras = transactions['extras'];
      if (mounted) {
        await AppNotifications.electricityPurchased(disco: _selectedDisco!);
        final msg = status == 'delivered' ? 'Electricity payment successful' : 'Electricity payment pending';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(extras != null && extras.toString().isNotEmpty
              ? '$msg\nToken: $extras'
              : msg),
          duration: const Duration(seconds: 4),
          backgroundColor: status == 'delivered' ? const Color(0xFF00A651) : const Color(0xFFCC8800),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();

    return Scaffold(
      backgroundColor: config.getScreenBg(0),
      appBar: AppBar(
        title: Text(config.getText('electricity_title', fallback: 'Electricity'),
          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribution Company',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDisco,
                  hint: Text('Select disco', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
                  items: _discos.map((d) => DropdownMenuItem(
                    value: d['id'] as String,
                    child: Text(d['name'] as String, style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedDisco = v),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Meter Type',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            Row(
              children: _types.map((t) {
                final selected = _selectedType == t['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = t['id']),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF6C0090).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? const Color(0xFF6C0090) : const Color(0xFFE0E0E0),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(t['name'] as String,
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600,
                            color: selected ? const Color(0xFF6C0090) : Color(0xFF666666))),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Meter Number',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _meterController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('e.g. 41234567890'),
            ),
            const SizedBox(height: 20),
            Text('Amount (₦)',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('e.g. 5000'),
            ),
            const SizedBox(height: 20),
            Text('Email (optional)',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('Token will be sent here'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.getContainerBg('electricity_button', fallback: const Color(0xFF6C0090)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(config.getText('electricity_button', fallback: 'Pay Electricity'),
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFFBBBBBB)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE0E0E0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
