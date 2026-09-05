import 'package:flutter/material.dart';
import '../config/build_config.dart';
import '../service/vtpass_config.dart';
import '../service/vtpass_service.dart';
import '../service/app_notifications.dart';

class CableTvScreen extends StatefulWidget {
  const CableTvScreen({super.key});

  @override
  State<CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends State<CableTvScreen> {
  String? _selectedProvider;
  String? _selectedPlan;
  final _smartcardController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _loadingPlans = false;
  List<Map<String, dynamic>> _plans = [];

  final _providers = [
    {'id': 'dstv', 'name': 'DSTV', 'color': Color(0xFF006B3F)},
    {'id': 'gotv', 'name': 'GOTV', 'color': Color(0xFF006B3F)},
    {'id': 'startimes', 'name': 'Startimes', 'color': Color(0xFF0099FF)},
    {'id': 'showmax', 'name': 'Showmax', 'color': Color(0xFFE50914)},
  ];

  @override
  void dispose() {
    _smartcardController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    if (_selectedProvider == null) return;
    setState(() {
      _loadingPlans = true;
      _plans = [];
      _selectedPlan = null;
    });
    try {
      final plans = await VtpassService.instance.getVariationCodes(_selectedProvider!);
      if (mounted) setState(() => _plans = plans);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load packages: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPlans = false);
    }
  }

  Future<void> _buy() async {
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a provider')),
      );
      return;
    }
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a package')),
      );
      return;
    }
    final smartcard = _smartcardController.text.trim();
    if (smartcard.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid smartcard/IUC number')),
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
      final res = await VtpassService.instance.buyTvSubscription(
        serviceID: _selectedProvider!,
        variationCode: _selectedPlan!,
        smartCardNumber: smartcard,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      );
      final content = res['content'];
      final transactions = (content is Map<String, dynamic>)
          ? (content['transactions'] as Map<String, dynamic>? ?? {})
          : <String, dynamic>{};
      final status = transactions['status'] ?? 'unknown';
      if (mounted) {
        await AppNotifications.cableTvPurchased(provider: _selectedProvider!.toUpperCase());
        final msg = status == 'delivered' ? 'Cable TV subscription successful' : 'Cable TV subscription pending';
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
        title: Text(config.getText('cable_title', fallback: 'Cable TV'),
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
            Text('Select Provider',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _providers.map((p) {
                final selected = _selectedProvider == p['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedProvider = p['id'] as String);
                    _loadPlans();
                  },
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? (p['color'] as Color).withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? (p['color'] as Color) : const Color(0xFFE0E0E0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.tv_rounded, color: p['color'] as Color, size: 24),
                        const SizedBox(height: 6),
                        Text(p['name'] as String, style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Smartcard / IUC Number',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _smartcardController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('e.g. 7031234567'),
            ),
            const SizedBox(height: 20),
            Text('Email (optional)',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
              decoration: _inputDecoration('you@example.com'),
            ),
            const SizedBox(height: 20),
            Text('Package',
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
                  _selectedProvider == null ? 'Select a provider first' : 'No packages available',
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
                    hint: Text('Choose a package', style: TextStyle(fontFamily: 'DMSans', fontSize: 13)),
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
                  backgroundColor: config.getContainerBg('cable_button', fallback: const Color(0xFF6C0090)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(config.getText('cable_button', fallback: 'Subscribe'),
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
