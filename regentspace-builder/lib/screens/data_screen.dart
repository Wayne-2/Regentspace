import 'package:flutter/material.dart';
import '../config/build_config.dart';
import '../service/vtpass_config.dart';
import '../service/vtpass_service.dart';
import '../service/app_notifications.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String? _selectedNetwork;
  String? _selectedPlan;
  final _phoneController = TextEditingController();
  bool _loading = false;
  bool _loadingPlans = false;
  bool _loadingPhone = true;
  List<Map<String, dynamic>> _plans = [];

  final _networks = [
    {'id': 'mtn-data', 'name': 'MTN', 'color': Color(0xFFFFCC00)},
    {'id': 'airtel-data', 'name': 'Airtel', 'color': Color(0xFFED1C24)},
    {'id': 'glo-data', 'name': 'Glo', 'color': Color(0xFF00A651)},
    {'id': '9mobile-data', 'name': '9mobile', 'color': Color(0xFF006B3F)},
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultPhone();
  }

  Future<void> _loadDefaultPhone() async {
    final phone = await VtpassService.instance.getDefaultPhone();
    if (mounted && phone.isNotEmpty) {
      setState(() {
        _phoneController.text = phone;
        _loadingPhone = false;
      });
    } else if (mounted) {
      setState(() => _loadingPhone = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    if (_selectedNetwork == null) return;
    setState(() {
      _loadingPlans = true;
      _plans = [];
      _selectedPlan = null;
    });
    try {
      final plans = await VtpassService.instance.getVariationCodes(_selectedNetwork!);
      if (mounted) setState(() => _plans = plans);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load plans: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPlans = false);
    }
  }

  Future<void> _buy() async {
    if (_selectedNetwork == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a network')),
      );
      return;
    }
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a data plan')),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
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
      final res = await VtpassService.instance.buyData(
        serviceID: _selectedNetwork!,
        variationCode: _selectedPlan!,
        phone: phone,
      );
      final content = res['content'];
      final transactions = (content is Map<String, dynamic>)
          ? (content['transactions'] as Map<String, dynamic>? ?? {})
          : <String, dynamic>{};
      final status = transactions['status'] ?? 'unknown';
      if (mounted) {
        await AppNotifications.dataPurchased(
          network: _selectedNetwork!.replaceAll('-data', ''),
        );
        final msg = status == 'delivered' ? 'Data purchase successful' : 'Data purchase pending';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
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
        title: Text(config.getText('data_title', fallback: 'Buy Data'),
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
            Text('Select Network',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _networks.map((n) {
                final selected = _selectedNetwork == n['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedNetwork = n['id'] as String);
                    _loadPlans();
                  },
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? (n['color'] as Color).withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? (n['color'] as Color) : const Color(0xFFE0E0E0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_rounded, color: n['color'] as Color, size: 24),
                        const SizedBox(height: 6),
                        Text(n['name'] as String, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Phone Number',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('e.g. 08012345678'),
            ),
            const SizedBox(height: 20),
            Text('Data Plan',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            if (_loadingPlans)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
            else if (_plans.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFE0E0E0)),
                ),
                child: Text(
                  _selectedNetwork == null ? 'Select a network first' : 'No plans available',
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF999999)),
                ),
              )
            else
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
                    value: _selectedPlan,
                    hint: Text('Choose a plan', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
                    items: _plans.map((p) {
                      final name = p['name'] ?? p['variation_code'] ?? 'Unknown';
                      final desc = p['variation_description'] ?? '';
                      final price = p['variation_amount'] ?? '';
                      return DropdownMenuItem(
                        value: (p['variation_code'] ?? '').toString(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$name', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
                            if (desc.toString().isNotEmpty)
                              Text('$desc — ₦$price', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF999999))),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedPlan = v),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: config.getContainerBg('data_button', fallback: const Color(0xFF6C0090)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(config.getText('data_button', fallback: 'Buy Data'),
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
