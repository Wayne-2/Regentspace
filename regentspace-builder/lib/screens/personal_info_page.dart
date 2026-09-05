import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/user_repository.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await UserRepository.instance.watchUser(uid).first;
      final data = doc.data();
      if (data != null && mounted) {
        _nameCtrl.text = (data['displayName'] as String?) ?? '';
        _emailCtrl.text = (data['email'] as String?) ?? FirebaseAuth.instance.currentUser?.email ?? '';
        _phoneCtrl.text = (data['phone'] as String?) ?? '';
        _usernameCtrl.text = (data['username'] as String?) ?? '';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await UserRepository.instance.updateProfile(
        uid,
        {
          'displayName': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Personal Information',
          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE5E5E5),
                      child: Text(
                        _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text.substring(0, 2).toUpperCase()
                            : 'U',
                        style: const TextStyle(fontFamily: 'DMSans', fontSize: 18,
                          fontWeight: FontWeight.w700, color: Color(0xFF777777)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field('Display Name', _nameCtrl, hint: 'Your name'),
                  const SizedBox(height: 16),
                  _field('Username', _usernameCtrl, hint: 'username'),
                  const SizedBox(height: 16),
                  _field('Email', _emailCtrl, enabled: false),
                  const SizedBox(height: 16),
                  _field('Phone Number', _phoneCtrl, hint: '08012345678', keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  Text('This phone number will be used as default for airtime and data purchases.',
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFF999999))),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C0090),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes',
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, bool enabled = true, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 12,
          color: Color(0xFF888888))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(fontFamily: 'DMSans', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFFC0C0C0)),
            filled: true,
            fillColor: enabled ? Colors.white : Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFE0E0E0))),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFE8E8E8))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
