import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Regentcanva extends StatefulWidget {
  const Regentcanva({super.key});

  @override
  State<Regentcanva> createState() => _RegentcanvaState();
}

class _RegentcanvaState extends State<Regentcanva> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [

            SizedBox(
              height: screenHeight * 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F7),
                  border: Border(
                    bottom: BorderSide(
                      color:  Color(0xFFE5E5E5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTab('Select'),
                    _buildTab('Color'),
                    _buildTab('Text'),
                    _buildTab('Templates'),
                  ],
                ),
              ),
            ),
        
            SizedBox(
              height: screenHeight * 0.60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _buildDevicePreview(index),
                  );
                },
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Regentspace Canvas',
                      subtitle: 'Design and generate your app',
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Run Build',
                      subtitle: 'Build and preview your app',
                      onTap: () => _showBuildFormatSheet(context),
                      isPrimary: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactButton(
                            icon: Icons.save_rounded,
                            label: 'Save',
                            onTap: () {},
                            isDestructive: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCompactButton(
                            icon: Icons.undo_rounded,
                            label: 'Revert',
                            onTap: () {},
                            isDestructive: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // BUILD FORMAT BOTTOM SHEET
  // ================================================================

  void _showBuildFormatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Build Format', style: AppTextStyles.title()),
            const SizedBox(height: 4),
            Text('Choose the output format for your app', style: AppTextStyles.caption(color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            _buildFormatOption(
              context: ctx,
              icon: Icons.android_rounded,
              label: 'APK',
              subtitle: 'Android Package Kit',
              isAvailable: true,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Building APK...'), backgroundColor: AppColors.primary),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildFormatOption(
              context: ctx,
              icon: Icons.shop_rounded,
              label: 'AAB',
              subtitle: 'Android App Bundle',
              isAvailable: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AAB format coming soon'), backgroundColor: AppColors.textTertiary),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildFormatOption(
              context: ctx,
              icon: Icons.apple_rounded,
              label: 'iOS',
              subtitle: 'iPhone & iPad',
              isAvailable: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('iOS build coming soon'), backgroundColor: AppColors.textTertiary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isAvailable ? const Color(0xFFF7F7F7) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAvailable ? AppColors.border : const Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isAvailable ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isAvailable ? AppColors.primary : AppColors.textHint,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isAvailable ? AppColors.textPrimary : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              if (!isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                )
              else
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // TAB
  // ================================================================

  Widget _buildTab(String title) {
    return Expanded(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MOBILE DEVICE PREVIEW
  // ================================================================

  Widget _buildDevicePreview(int index) {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 480,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color.fromARGB(157, 69, 69, 69),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: [
              // Device top area
              

              // Simulated screen
                            // Simulated screen
              Expanded(
                child: Container(
                  color: const Color(0xFFF7F7F7),
                  child: _buildScreenContent(index),
                ),
              ),
              // Device bottom area
              Container(
                height: 24,
                color: const Color(0xFFF9F9F9),
                child: Center(
                  child: Container(
                    width: 55,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SECTION HEADER
  // ================================================================
    // ================================================================
  // SCREEN CONTENT (per-preview, add a case for each new screen)
  // ================================================================

  Widget _buildScreenContent(int index) {
    switch (index) {
      case 0:
        return _buildAppIntroScreen();
      case 1:
        return _buildLoginScreen();
      case 2:
        return _buildVtuHomeScreen();
      // case 3:
      //   return _buildYourNextScreen();
      default:
        return Center(
          child: Text(
            'Screen ${index + 1}',
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        );
    }
  }

  Widget _buildAppIntroScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 28,
                color: Color(0xFFB0B0B0),
              ),
            ),
            const SizedBox(height: 16),

            // App name placeholder
            const Text(
              'App Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 6),

            // App description placeholder (smaller, lighter)
            const Text(
              'A short description of what this app does goes here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildLoginScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + app name row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 14,
                  color: Color(0xFFB0B0B0),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'App Name',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // "Login" heading
          const Text(
            'Login',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Welcome back, please sign in',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 20),

          // Email field placeholder
          _buildLoginField(label: 'Email', hint: 'you@example.com'),
          const SizedBox(height: 12),

          // Password field placeholder
          _buildLoginField(label: 'Password', hint: '••••••••'),
          const SizedBox(height: 8),

          // Forgot password
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot password?',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Login button placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Log In',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign up prompt
          Center(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                  TextSpan(
                    text: 'Sign up',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10.5,
              color: Color(0xFFC0C0C0),
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildVtuHomeScreen() {
    const fullName = 'New User';
    final initials = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row: avatar + hello/name column
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE5E5E5),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello again',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 7,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    fullName,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Wallet banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 89, 88, 88),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: [
                Expanded(
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Virtual Wallet ',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 8.5,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 1),
                           const Text(
                            ':',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 8.5,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(width: 1),
                          const Text(
                            ' 0123456789',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 8.5,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                         
                        ],
                      ),
                     
                      const SizedBox(height: 5),
                      const Text(
                        '₦0.00',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                       const Text(
                        'Available Balance',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8.5,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add money',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // VTU services list
          const Text(
            'Services',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            children: const [
              _VtuServiceItem(icon: Icons.phone_android_rounded, label: 'Airtime'),
              _VtuServiceItem(icon: Icons.wifi_rounded, label: 'Data'),
              _VtuServiceItem(icon: Icons.bolt_rounded, label: 'Electricity'),
              _VtuServiceItem(icon: Icons.tv_rounded, label: 'Cable TV'),
              _VtuServiceItem(icon: Icons.school_rounded, label: 'Education'),
              _VtuServiceItem(icon: Icons.sports_soccer_rounded, label: 'Betting'),
              _VtuServiceItem(icon: Icons.water_drop_rounded, label: 'Water'),
              _VtuServiceItem(icon: Icons.more_horiz_rounded, label: 'More'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title(),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.body(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  // ================================================================
  // ACTION BUTTON
  // ================================================================

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isDestructive
                  ? const Color(0xFFFDEDED)
                  : isPrimary
                      ? AppColors.primary
                      : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPrimary
                    ? AppColors.primary
                    : isDestructive
                        ? const Color(0xFFF5C6C6)
                        : AppColors.border,
                width: isPrimary ? 0 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.15)
                        : isDestructive
                            ? const Color(0xFFE53935).withValues(alpha: 0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isPrimary
                        ? Colors.white
                        : isDestructive
                            ? AppColors.error
                            : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? Colors.white
                              : isDestructive
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: isPrimary
                              ? Colors.white.withValues(alpha: 0.75)
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPrimary)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // COMPACT BUTTON (for side-by-side layout)
  // ================================================================

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFDEDED)
                : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFF5C6C6)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VtuServiceItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VtuServiceItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF777777)),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 50,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 6,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
        ),
      ],
    );
  }
}
