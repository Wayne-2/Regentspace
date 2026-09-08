import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I create a virtual account?',
      'answer': 'Go to the Finance tab and tap "Manage Rates" to set up your preferred bank. Your virtual account will be created automatically.',
    },
    {
      'question': 'How do I buy airtime or data?',
      'answer': 'Use the generated app to purchase airtime or data. The rates you set in "Manage Rates" will be applied.',
    },
    {
      'question': 'How do I withdraw my earnings?',
      'answer': 'Go to Finance > Withdrawal to transfer your earnings to your bank account.',
    },
    {
      'question': 'How do I customize my app?',
      'answer': 'Use the Canvas tab to design your app. You can change colors, text, and layout to match your brand.',
    },
    {
      'question': 'How do I build my app?',
      'answer': 'After designing in the Canvas, tap the APK button to build your app. The download will be available in the Dashboard.',
    },
    {
      'question': 'How is interest calculated?',
      'answer': 'Interest is calculated daily based on your configured rate and the transactions processed through your app.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Help & Support", style: AppTextStyles.headline(color: AppColors.textPrimary)),
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
            // ── Contact Support ──
            Text("Contact Us", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight, width: 1),
              ),
              child: Column(
                children: [
                  _ContactTile(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@regentspace.com',
                    onTap: () => _launchUrl('mailto:support@regentspace.com'),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 52, color: AppColors.primaryLight),
                  _ContactTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: 'Chat with our support team',
                    onTap: () => launchUrl(Uri.parse('https://regentspace.com/support'), mode: LaunchMode.externalApplication),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 52, color: AppColors.primaryLight),
                  _ContactTile(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    subtitle: '+234 800 123 4567',
                    onTap: () => _launchUrl('tel:+2348001234567'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── FAQs ──
            Text("Frequently Asked Questions", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ...faqs.map((faq) => _FaqTile(question: faq['question']!, answer: faq['answer']!)),

            const SizedBox(height: 24),

            // ── Legal ──
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
                  _LinkTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => _launchUrl('https://regentspace.com/terms'),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 52, color: AppColors.border),
                  _LinkTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _launchUrl('https://regentspace.com/privacy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
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

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.question, style: AppTextStyles.body(color: AppColors.textPrimary)),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(widget.answer, style: AppTextStyles.caption(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
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
                child: Text(title, style: AppTextStyles.body(color: AppColors.textPrimary)),
              ),
              const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
