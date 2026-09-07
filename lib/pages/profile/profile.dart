import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../service/user_repository.dart';
import '../../service/auth_service.dart';
import '../../auth_page/login.dart';
import '../../components/notificationpage.dart';
import 'personal_info_page.dart';
import 'security_page.dart';
import 'appearance_page.dart';
import 'help_support_page.dart';
import 'about_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text("Profile", style: AppTextStyles.headline(color: AppColors.textPrimary)),
              ),

              // ── User Info Card ──
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null ? null : UserRepository.instance.watchUser(uid),
                builder: (context, snap) {
                  final data = snap.data?.data();
                  final username = (data?['username'] ?? data?['displayName'] ?? 'User') as String;
                  final email = (data?['email'] ?? '') as String;
                  final phone = (data?['phone'] ?? '') as String;
                  final initials = username.length >= 2 ? username.substring(0, 2).toUpperCase() : username.toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryLight, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF4FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEAC5F7), width: 1),
                            ),
                            child: Center(
                              child: Text(initials, style: AppTextStyles.title(color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(username, style: AppTextStyles.title(color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(email, style: AppTextStyles.caption(color: AppColors.textTertiary)),
                                if (phone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(phone, style: AppTextStyles.caption(color: AppColors.textTertiary)),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage())),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Account Settings ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Account Settings', style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        subtitle: 'Edit your profile details',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage())),
                      ),
                      _divider,
                      _SettingTile(
                        icon: Icons.shield_outlined,
                        title: 'Security & Privacy',
                        subtitle: 'Password and security settings',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage())),
                      ),
                      _divider,
                      _SettingTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage notification preferences',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── App Settings ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('App Settings', style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: 'Theme and display settings',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearancePage())),
                      ),
                      _divider,
                      _SettingTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'FAQs and contact support',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
                      ),
                      _divider,
                      _SettingTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About Regentspace',
                        subtitle: 'Version and legal information',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Logout ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    label: Text('Log Out', style: AppTextStyles.body(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget get _divider => const Divider(height: 1, thickness: 0.5, indent: 48, color: AppColors.border);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text("Log Out", textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
        content: Text("Are you sure you want to log out?", textAlign: TextAlign.center, style: AppTextStyles.body(color: AppColors.textSecondary)),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text("Cancel", style: AppTextStyles.body(color: AppColors.textSecondary)),
              ),
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await AuthService().signOutGoogle();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const Loginpage()),
                      (_) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text("Log Out", style: AppTextStyles.body(color: AppColors.error).copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
