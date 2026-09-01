import 'package:flutter/material.dart';
import '../../components/userpfp.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const mockUser = {
    'username': 'John Doe',
    'email': 'john@example.com',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 244, 255, 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(234, 197, 247, 1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const UserAvatar(name: 'John Doe', size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mockUser['username']!,
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F1F)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mockUser['email']!,
                          style: TextStyle(fontFamily: 'DMSans', color: Colors.black54, fontSize: 12.5, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: Colors.grey[600], size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Account Settings',
              style: TextStyle(fontFamily: 'DMSans', color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.2),
            ),
            const SizedBox(height: 10),
            _SettingTile(icon: Icons.person, title: 'Personal Information', onTap: _staticSnack),
            _SettingTile(icon: Icons.security, title: 'Security & Privacy', onTap: _staticSnack),
            _SettingTile(icon: Icons.notifications, title: 'Notifications', onTap: _staticSnack),
            const SizedBox(height: 20),
            Text(
              'App Settings',
              style: TextStyle(fontFamily: 'DMSans', color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.2),
            ),
            const SizedBox(height: 10),
            _SettingTile(icon: Icons.wb_sunny, title: 'Appearance', onTap: _staticSnack),
            _SettingTile(icon: Icons.help_outline, title: 'Help & Support', onTap: _staticSnack),
            _SettingTile(icon: Icons.info_outline, title: 'About Regentspace', onTap: _staticSnack),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text('Logout', style: TextStyle(fontFamily: 'DMSans', color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  static void _staticSnack() {
    // static placeholder — no action
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped (static demo)'), backgroundColor: const Color(0xFF740690)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[800], size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontFamily: 'DMSans', fontSize: 13.5, color: Colors.black87, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
