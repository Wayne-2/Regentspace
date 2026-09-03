import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

class Regentcanva extends StatefulWidget {
  const Regentcanva({super.key});

  @override
  State<Regentcanva> createState() => _RegentcanvaState();
}

class _RegentcanvaState extends State<Regentcanva> {
  bool _isEditMode = false;
  String? _selectedElementId;

  // Editable state
  IconData _appIcon = Icons.image_outlined;
  Uint8List? _appIconImage;
  final Map<String, String> _elementTexts = {
    'intro_title': 'App Name',
    'intro_description': 'A short description of what this app does goes here.',
    'login_heading': 'Login',
    'login_subtitle': 'Welcome back, please sign in',
    'login_email_label': 'Email',
    'login_email_hint': 'you@example.com',
    'login_password_label': 'Password',
    'login_password_hint': '••••••••',
    'login_forgot': 'Forgot password?',
    'login_button': 'Log In',
    'login_signup': "Don't have an account? Sign up",
    'signup_heading': 'Create Account',
    'signup_subtitle': 'Welcome user, fill the follow',
    'signup_email_label': 'Email',
    'signup_email_hint': 'you@example.com',
    'signup_password_label': 'Password',
    'signup_password_hint': '••••••••',
    'signup_confirm_label': 'Confirm Password',
    'signup_confirm_hint': '••••••••',
    'signup_forgot': 'Forgot password?',
    'signup_button': 'Log In',
    'signup_login': "Don't have an account? Sign up",
    'home_services_title': 'Services',
    'finance_heading': 'Finance',
    'finance_subtitle': 'Track your balance and spending',
    'finance_plan_title': 'Current Plan',
    'finance_transactions_title': 'Recent Transactions',
    'profile_heading': 'Profile',
  };
  final Map<String, Color> _elementColors = {};
  final Map<String, Color> _containerBackgrounds = {};
  final Map<int, Color> _screenBackgrounds = {};

  // Element classification helpers
  bool _isImageElement(String id) => id == 'intro_icon' || id == 'login_logo' || id == 'signup_logo';
  bool _isTextElement(String id) => id.contains('title') || id.contains('heading') || id.contains('subtitle') ||
      id.contains('description') || id.contains('label') || id.contains('hint') || id.contains('forgot') ||
      id.contains('button') || id.contains('signup') || id.contains('login') && !id.contains('logo') ||
      id == 'home_services_title' || id == 'finance_heading' || id == 'finance_subtitle' ||
      id == 'finance_plan_title' || id == 'finance_transactions_title' || id == 'profile_heading' ||
      id == 'home_wallet' || id == 'finance_plan_card' || id == 'finance_summary' ||
      id == 'profile_personal' || id == 'profile_payment' || id == 'profile_security' ||
      id == 'profile_notifications' || id == 'profile_help' || id == 'profile_logout' ||
      id.contains('_text') || id.contains('_icon') || id.contains('_amount') ||
      id.contains('_subtitle') || id.contains('_renew') || id.contains('_label');
  bool _isContainerElement(String id) => id.contains('wallet') || id.contains('plan_card') ||
      id.contains('button') || id.contains('services_grid') || id.contains('summary') ||
      id.contains('transactions_list') || id.startsWith('screen_') || id.contains('service_') ||
      id.contains('profile_') || id.contains('email') || id.contains('password') || id.contains('confirm');

  String? _getTextForElement(String id) {
    if (_elementTexts.containsKey(id)) return _elementTexts[id];
    return null;
  }

  void _onElementTap(String id) {
    setState(() => _selectedElementId = _selectedElementId == id ? null : id);
  }

  // ================================================================
  // TOOLBAR ACTIONS
  // ================================================================

  void _onToolbarTap(String action) {
    if (_selectedElementId == null || !_isEditMode) return;
    final id = _selectedElementId!;

    switch (action) {
      case 'Color':
        if (_isTextElement(id)) {
          _showColorPicker(forText: true);
        } else if (_isContainerElement(id)) {
          _showColorPicker(forText: false);
        }
        break;
      case 'Text':
        if (_isTextElement(id)) {
          _showTextEditor(id);
        }
        break;
      case 'Background':
        if (_isContainerElement(id)) _showBackgroundColorPicker(id);
        break;
      case 'Object':
        if (_isImageElement(id)) _showObjectDropdown(id);
        break;
    }
  }

  void _showColorPicker({required bool forText}) {
    final id = _selectedElementId!;
    final currentColor = forText
        ? (_elementColors[id] ?? _getDefaultTextColor(id))
        : (_containerBackgrounds[id] ?? const Color(0xFFF7F7F7));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(forText ? 'Text Color' : 'Container Color', style: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 16)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                if (forText) {
                  _elementColors[id] = color;
                } else {
                  _containerBackgrounds[id] = color;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: false,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'DMSans'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(fontFamily: 'DMSans')),
          ),
        ],
      ),
    );
  }

  Color _getDefaultTextColor(String id) {
    if (id == 'home_wallet' || id == 'finance_plan_card') {
      return const Color(0xFFAAAAAA);
    }
    if (id == 'finance_summary') {
      return const Color(0xFF777777);
    }
    if (id.contains('subtitle') || id.contains('description') || id.contains('hint') || id.contains('forgot')) {
      return const Color(0xFFAAAAAA);
    }
    return const Color(0xFF444444);
  }

  void _showTextEditor(String id) {
    final controller = TextEditingController(text: _getTextForElement(id) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Text', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter new text',
            hintStyle: const TextStyle(fontFamily: 'DMSans', color: AppColors.textHint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'DMSans'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              setState(() => _elementTexts[id] = controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(fontFamily: 'DMSans')),
          ),
        ],
      ),
    );
  }

  void _showBackgroundColorPicker(String id) {
    final isScreen = id.startsWith('screen_');
    final currentColor = isScreen
        ? (_screenBackgrounds[int.parse(id.split('_')[1])] ?? const Color(0xFFF7F7F7))
        : (_containerBackgrounds[id] ?? const Color(0xFFF7F7F7));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isScreen ? 'Screen Background' : 'Background Color', style: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 16)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                if (isScreen) {
                  _screenBackgrounds[int.parse(id.split('_')[1])] = color;
                } else {
                  _containerBackgrounds[id] = color;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: false,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'DMSans'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(fontFamily: 'DMSans')),
          ),
        ],
      ),
    );
  }

  void _showObjectDropdown(String id) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Object', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 16)),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final bytes = await picked.readAsBytes();
                setState(() {
                  _appIconImage = bytes;
                  _appIcon = Icons.image;
                });
              }
            },
            child: Row(children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              const Text('Add Image', style: TextStyle(fontFamily: 'DMSans', fontSize: 14)),
            ]),
          ),
          if (_appIconImage != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _appIconImage = null;
                  _appIcon = Icons.image_outlined;
                });
              },
              child: Row(children: [
                Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 12),
                const Text('Remove Image', style: TextStyle(fontFamily: 'DMSans', fontSize: 14)),
              ]),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // APP ICON WIDGET (synced across intro, login, signup)
  // ================================================================

  Widget _buildAppIcon({double size = 28, double borderRadius = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: _appIconImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.memory(_appIconImage!, fit: BoxFit.cover),
            )
          : Icon(_appIcon, size: size * 0.5, color: const Color(0xFFB0B0B0)),
    );
  }

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
                    const SizedBox(width: 12),
                    // View / Edit toggle
                    GestureDetector(
                      onTap: () => setState(() => _isEditMode = !_isEditMode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isEditMode ? AppColors.primary : const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isEditMode ? Icons.edit_rounded : Icons.visibility_rounded,
                              size: 14,
                              color: _isEditMode ? Colors.white : const Color(0xFF777777),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isEditMode ? 'Edit' : 'View',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isEditMode ? Colors.white : const Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Toolbar options
                    Expanded(
                      child: Builder(
                        builder: (ctx) {
                          final id = _selectedElementId;
                          final hasSelection = id != null && _isEditMode;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildToolbarOption(
                                icon: Icons.palette_outlined,
                                label: 'Color',
                                isActive: _isEditMode,
                                isAvailable: hasSelection && (_isTextElement(id) || _isContainerElement(id)) && !id.startsWith('screen_'),
                                onTap: () => _onToolbarTap('Color'),
                              ),
                              _buildToolbarOption(
                                icon: Icons.text_fields_rounded,
                                label: 'Text',
                                isActive: _isEditMode,
                                isAvailable: hasSelection && _isTextElement(id),
                                onTap: () => _onToolbarTap('Text'),
                              ),
                              _buildToolbarOption(
                                icon: Icons.wallpaper_outlined,
                                label: 'Background',
                                isActive: _isEditMode,
                                isAvailable: hasSelection && _isContainerElement(id),
                                onTap: () => _onToolbarTap('Background'),
                              ),
                              _buildToolbarOption(
                                icon: Icons.category_outlined,
                                label: 'Object',
                                isActive: _isEditMode,
                                isAvailable: hasSelection && _isImageElement(id),
                                onTap: () => _onToolbarTap('Object'),
                              ),
                              _buildToolbarOption(
                                icon: Icons.dashboard_outlined,
                                label: 'Templates',
                                isActive: _isEditMode,
                                isAvailable: false,
                                onTap: () {},
                              ),
                            ],
                          );
                        },
                      ),
                    ),
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
  // TOOLBAR OPTION
  // ================================================================

  Widget _buildToolbarOption({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    final color = !isActive
        ? const Color(0xFFBBBBBB)
        : isAvailable
            ? AppColors.primary
            : const Color(0xFFCCCCCC);
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SELECTABLE WRAPPER
  // ================================================================

  Widget _selectable({
    required String id,
    required Widget child,
    bool fullWidth = false,
  }) {
    final isSelected = _selectedElementId == id;
    return GestureDetector(
      onTap: _isEditMode ? () => _onElementTap(id) : null,
      child: Container(
        width: fullWidth ? double.infinity : null,
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              )
            : _isEditMode
                ? BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
        child: child,
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
              Expanded(
                child: _selectable(
                  id: 'screen_$index',
                  fullWidth: true,
                  child: Container(
                    color: _screenBackgrounds[index] ?? const Color(0xFFF7F7F7),
                    child: _buildScreenContent(index),
                  ),
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
        return _buildCreateAccountScreen();
      case 3:
        return _buildVtuHomeScreen();
      case 4:
        return _buildVtuFinanceScreen();
      case 5:
        return _buildVtuProfileScreen();
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
    final titleColor = _elementColors['intro_title'] ?? const Color(0xFF444444);
    final descColor = _elementColors['intro_description'] ?? const Color(0xFFAAAAAA);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon placeholder
            _selectable(
              id: 'intro_icon',
              child: _buildAppIcon(size: 72, borderRadius: 18),
            ),
            const SizedBox(height: 16),

            // App name placeholder
            _selectable(
              id: 'intro_title',
              child: Text(
                _getTextForElement('intro_title') ?? 'App Name',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // App description placeholder
            _selectable(
              id: 'intro_description',
              child: Text(
                _getTextForElement('intro_description') ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: descColor,
                ),
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
          _selectable(
            id: 'login_logo',
            child: Row(
              children: [
                _buildAppIcon(size: 28, borderRadius: 8),
                const SizedBox(width: 8),
                Text(
                  _getTextForElement('intro_title') ?? 'App Name',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _elementColors['intro_title'] ?? const Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // "Login" heading
          _selectable(
            id: 'login_heading',
            child: Text(
              _getTextForElement('login_heading') ?? 'Login',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _elementColors['login_heading'] ?? const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _selectable(
            id: 'login_subtitle',
            child: Text(
              _getTextForElement('login_subtitle') ?? '',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: _elementColors['login_subtitle'] ?? const Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Email field
          _selectable(id: 'login_email', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('login_email_label') ?? 'Email',
            hint: _getTextForElement('login_email_hint') ?? '',
            elementId: 'login_email',
          )),
          const SizedBox(height: 12),

          // Password field
          _selectable(id: 'login_password', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('login_password_label') ?? 'Password',
            hint: _getTextForElement('login_password_hint') ?? '',
            elementId: 'login_password',
          )),
          const SizedBox(height: 8),

          // Forgot password
          _selectable(
            id: 'login_forgot',
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getTextForElement('login_forgot') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: _elementColors['login_forgot'] ?? const Color(0xFFB0B0B0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Login button
          _selectable(
            id: 'login_button',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _containerBackgrounds['login_button'] ?? const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getTextForElement('login_button') ?? 'Log In',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _elementColors['login_button'] ?? const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign up prompt
          _selectable(
            id: 'login_signup',
            child: Center(
              child: Text(
                _getTextForElement('login_signup') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  color: _elementColors['login_signup'] ?? const Color(0xFFAAAAAA),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildCreateAccountScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + app name row
          _selectable(
            id: 'signup_logo',
            child: Row(
              children: [
                _buildAppIcon(size: 28, borderRadius: 8),
                const SizedBox(width: 8),
                Text(
                  _getTextForElement('intro_title') ?? 'App Name',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _elementColors['intro_title'] ?? const Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // "Create Account" heading
          _selectable(
            id: 'signup_heading',
            child: Text(
              _getTextForElement('signup_heading') ?? 'Create Account',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _elementColors['signup_heading'] ?? const Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _selectable(
            id: 'signup_subtitle',
            child: Text(
              _getTextForElement('signup_subtitle') ?? '',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: _elementColors['signup_subtitle'] ?? const Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Email field
          _selectable(id: 'signup_email', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_email_label') ?? 'Email',
            hint: _getTextForElement('signup_email_hint') ?? '',
            elementId: 'signup_email',
          )),
          const SizedBox(height: 12),

          // Password field
          _selectable(id: 'signup_password', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_password_label') ?? 'Password',
            hint: _getTextForElement('signup_password_hint') ?? '',
            elementId: 'signup_password',
          )),
          const SizedBox(height: 8),

          // Confirm Password field
          _selectable(id: 'signup_confirm', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_confirm_label') ?? 'Confirm Password',
            hint: _getTextForElement('signup_confirm_hint') ?? '',
            elementId: 'signup_confirm',
          )),
          const SizedBox(height: 8),

          // Forgot password
          _selectable(
            id: 'signup_forgot',
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getTextForElement('signup_forgot') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: _elementColors['signup_forgot'] ?? const Color(0xFFB0B0B0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sign up button
          _selectable(
            id: 'signup_button',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _containerBackgrounds['signup_button'] ?? const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getTextForElement('signup_button') ?? 'Log In',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _elementColors['signup_button'] ?? const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign up prompt
          _selectable(
            id: 'signup_login',
            child: Center(
              child: Text(
                _getTextForElement('signup_login') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  color: _elementColors['signup_login'] ?? const Color(0xFFAAAAAA),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginField({required String label, required String hint, String? elementId}) {
    final labelColor = elementId != null ? (_elementColors['${elementId}_label'] ?? const Color(0xFF888888)) : const Color(0xFF888888);
    final bgColor = elementId != null ? (_containerBackgrounds[elementId] ?? Colors.white) : Colors.white;
    final borderColor = elementId != null ? (_containerBackgrounds['${elementId}_border'] ?? const Color(0xFFE0E0E0)) : const Color(0xFFE0E0E0);
    final hintColor = elementId != null ? (_elementColors['${elementId}_hint'] ?? const Color(0xFFC0C0C0)) : const Color(0xFFC0C0C0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            hint,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10.5,
              color: hintColor,
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
          _selectable(
            id: 'home_greeting',
            child: Row(
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
          ),
          const SizedBox(height: 18),

          // Wallet banner
          _selectable(
            id: 'home_wallet',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _containerBackgrounds['home_wallet'] ?? const Color.fromARGB(255, 89, 88, 88),
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
                            Text(
                              'Account No ',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 8.5,
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              ':',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 8.5,
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              ' 0123456789',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 8.5,
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '₦0.00',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _elementColors['home_wallet_amount'] ?? Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 8.5,
                            color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: BoxDecoration(
                      color: _containerBackgrounds['home_wallet_button'] ?? Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                          color: _elementColors['home_wallet_button_text'] ?? const Color(0xFF2E2E2E),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add money',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: _elementColors['home_wallet_button_text'] ?? const Color(0xFF2E2E2E),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // VTU services list
          _selectable(
            id: 'home_services_title',
            child: const Text(
              'Services',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            children: [
              _selectable(
                id: 'service_airtime',
                child: _VtuServiceItem(icon: Icons.phone_android_rounded, label: 'Airtime',
                  iconColor: _elementColors['service_airtime_icon'], bgColor: _containerBackgrounds['service_airtime'],
                  textColor: _elementColors['service_airtime_text']),
              ),
              _selectable(
                id: 'service_data',
                child: _VtuServiceItem(icon: Icons.wifi_rounded, label: 'Data',
                  iconColor: _elementColors['service_data_icon'], bgColor: _containerBackgrounds['service_data'],
                  textColor: _elementColors['service_data_text']),
              ),
              _selectable(
                id: 'service_electricity',
                child: _VtuServiceItem(icon: Icons.bolt_rounded, label: 'Electricity',
                  iconColor: _elementColors['service_electricity_icon'], bgColor: _containerBackgrounds['service_electricity'],
                  textColor: _elementColors['service_electricity_text']),
              ),
              _selectable(
                id: 'service_cable',
                child: _VtuServiceItem(icon: Icons.tv_rounded, label: 'Cable TV',
                  iconColor: _elementColors['service_cable_icon'], bgColor: _containerBackgrounds['service_cable'],
                  textColor: _elementColors['service_cable_text']),
              ),
              _selectable(
                id: 'service_education',
                child: _VtuServiceItem(icon: Icons.school_rounded, label: 'Education',
                  iconColor: _elementColors['service_education_icon'], bgColor: _containerBackgrounds['service_education'],
                  textColor: _elementColors['service_education_text']),
              ),
              _selectable(
                id: 'service_betting',
                child: _VtuServiceItem(icon: Icons.sports_soccer_rounded, label: 'Betting',
                  iconColor: _elementColors['service_betting_icon'], bgColor: _containerBackgrounds['service_betting'],
                  textColor: _elementColors['service_betting_text']),
              ),
              _selectable(
                id: 'service_water',
                child: _VtuServiceItem(icon: Icons.water_drop_rounded, label: 'Water',
                  iconColor: _elementColors['service_water_icon'], bgColor: _containerBackgrounds['service_water'],
                  textColor: _elementColors['service_water_text']),
              ),
              _selectable(
                id: 'service_more',
                child: _VtuServiceItem(icon: Icons.more_horiz_rounded, label: 'More',
                  iconColor: _elementColors['service_more_icon'], bgColor: _containerBackgrounds['service_more'],
                  textColor: _elementColors['service_more_text']),
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildVtuFinanceScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectable(
            id: 'finance_heading',
            child: const Text(
              'Finance',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 2),
          _selectable(
            id: 'finance_subtitle',
            child: const Text(
              'Track your balance and spending',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 8.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Balance summary row
          _selectable(
            id: 'finance_summary',
            fullWidth: true,
            child: Row(
              children: [
                Expanded(
                  child: _FinanceSummaryTile(
                    label: 'Balance',
                    value: '₦0.00',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: _elementColors['finance_summary'],
                    textColor: _elementColors['finance_summary'],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FinanceSummaryTile(
                    label: 'This Month',
                    value: '₦0.00',
                    icon: Icons.trending_down_rounded,
                    iconColor: _elementColors['finance_summary'],
                    textColor: _elementColors['finance_summary'],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Current plan card
          _selectable(
            id: 'finance_plan_title',
            child: const Text(
              'Current Plan',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _selectable(
            id: 'finance_plan_card',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _containerBackgrounds['finance_plan_card'] ?? const Color.fromARGB(255, 89, 88, 88),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'No Active Plan',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_title'] ?? Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Subscribe to a data or cable plan',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 8,
                            color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_subtitle'] ?? const Color(0xFFAAAAAA),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Renews: —',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 7.5,
                            color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_renew'] ?? const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _containerBackgrounds['finance_plan_card_button'] ?? Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _elementColors['finance_plan_card_button_text'] ?? const Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Transactions
          _selectable(
            id: 'finance_transactions_title',
            child: const Text(
              'Recent Transactions',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _selectable(
            id: 'finance_transactions_list',
            fullWidth: true,
            child: const _TransactionItem(
              icon: Icons.wifi_rounded,
              title: 'Data Purchase',
              subtitle: 'No transactions yet',
              amount: '',
              isCredit: false,
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildVtuProfileScreen() {
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
          _selectable(
            id: 'profile_heading',
            child: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Avatar + name + email
          _selectable(
            id: 'profile_avatar',
            fullWidth: true,
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE5E5E5),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    fullName,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'user@example.com',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 8.5,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Menu items
          _selectable(id: 'profile_personal', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.person_outline_rounded, label: 'Personal Information',
            bgColor: _containerBackgrounds['profile_personal'], iconColor: _elementColors['profile_personal'],
            textColor: _elementColors['profile_personal'],
          )),
          _selectable(id: 'profile_payment', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.credit_card_rounded, label: 'Payment Methods',
            bgColor: _containerBackgrounds['profile_payment'], iconColor: _elementColors['profile_payment'],
            textColor: _elementColors['profile_payment'],
          )),
          _selectable(id: 'profile_security', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.lock_outline_rounded, label: 'Security',
            bgColor: _containerBackgrounds['profile_security'], iconColor: _elementColors['profile_security'],
            textColor: _elementColors['profile_security'],
          )),
          _selectable(id: 'profile_notifications', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.notifications_none_rounded, label: 'Notifications',
            bgColor: _containerBackgrounds['profile_notifications'], iconColor: _elementColors['profile_notifications'],
            textColor: _elementColors['profile_notifications'],
          )),
          _selectable(id: 'profile_help', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.help_outline_rounded, label: 'Help & Support',
            bgColor: _containerBackgrounds['profile_help'], iconColor: _elementColors['profile_help'],
            textColor: _elementColors['profile_help'],
          )),
          const SizedBox(height: 10),
          _selectable(id: 'profile_logout', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.logout_rounded, label: 'Log Out', isDestructive: true,
            bgColor: _containerBackgrounds['profile_logout'], iconColor: _elementColors['profile_logout'],
            textColor: _elementColors['profile_logout'],
          )),
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
  final Color? iconColor;
  final Color? bgColor;
  final Color? textColor;

  const _VtuServiceItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor ?? const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Icon(icon, size: 16, color: iconColor ?? const Color(0xFF777777)),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 50,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 6,
              fontWeight: FontWeight.w500,
              color: textColor ?? const Color(0xFF888888),
            ),
          ),
        ),
      ],
    );
  }
}

class _FinanceSummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;

  const _FinanceSummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor ?? const Color(0xFF777777)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 7.5,
              color: textColor ?? const Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;

  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF777777)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 7.5,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          if (amount.isNotEmpty)
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isCredit ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final Color? bgColor;
  final Color? iconColor;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.bgColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg = isDestructive ? const Color(0xFFFDEDED) : const Color(0xFFF7F7F7);
    final defaultBorder = isDestructive ? const Color(0xFFF5C6C6) : const Color(0xFFE5E5E5);
    final defaultIcon = isDestructive ? const Color(0xFFC62828) : const Color(0xFF777777);
    final defaultText = isDestructive ? const Color(0xFFC62828) : const Color(0xFF444444);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor ?? defaultBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: defaultBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColor ?? defaultIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: textColor ?? defaultText,
              ),
            ),
          ),
          if (!isDestructive)
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFBBBBBB)),
        ],
      ),
    );
  }
}