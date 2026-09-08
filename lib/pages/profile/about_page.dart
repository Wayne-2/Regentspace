import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("About Regentspace", style: AppTextStyles.headline(color: AppColors.textPrimary)),
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
            // ── App Logo & Name ──
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLight, width: 1),
                ),
                child: const Icon(Icons.apps_rounded, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text("Regentspace", style: AppTextStyles.headline(color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text("Version 1.0.0", style: AppTextStyles.caption(color: AppColors.textTertiary)),
            ),

            const SizedBox(height: 32),

            // ── About Description ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight, width: 1),
              ),
              child: Text(
                "Regentspace is a platform that allows you to create and customize your own mobile app for selling airtime, data, cable TV subscriptions, and electricity bills. Set your own rates, track your earnings, and grow your business.",
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 24),

            // ── Features ──
            Text("Features", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            _buildFeatureItem(Icons.phone_android_rounded, "Airtime & Data Sales", "Sell airtime and data at your own rates"),
            _buildFeatureItem(Icons.tv_rounded, "Cable TV Subscriptions", "Process cable TV payments for your customers"),
            _buildFeatureItem(Icons.flash_on_rounded, "Electricity Bills", "Accept electricity bill payments"),
            _buildFeatureItem(Icons.trending_up_rounded, "Interest Earnings", "Earn interest on transactions"),
            _buildFeatureItem(Icons.palette_rounded, "Custom Branding", "Design your app with your own brand identity"),

            const SizedBox(height: 24),

            // ── Legal Links ──
            Text("Legal", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _LegalTile(title: 'Terms of Service', onTap: () => launchUrl(Uri.parse('https://regentspace.com/terms'), mode: LaunchMode.externalApplication)),
                  const Divider(height: 1, thickness: 0.5, indent: 16, color: AppColors.border),
                  _LegalTile(title: 'Privacy Policy', onTap: () => launchUrl(Uri.parse('https://regentspace.com/privacy'), mode: LaunchMode.externalApplication)),
                  const Divider(height: 1, thickness: 0.5, indent: 16, color: AppColors.border),
                  _LegalTile(title: 'Open Source Licenses', onTap: () => showLicensePage(context: context)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Copyright ──
            Center(
              child: Text(
                "© 2026 Regentspace. All rights reserved.",
                style: AppTextStyles.caption(color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
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
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.body(color: AppColors.textPrimary))),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
