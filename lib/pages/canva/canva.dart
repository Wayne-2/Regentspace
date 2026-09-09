import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/app_notifications.dart';
import '../../service/build_tracker.dart';
import '../../navigator.dart';
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
  bool _appIconCrop = true; // true = cover (crop), false = contain (full image)
  bool _appIconRoundBorder = true; // true = rounded corners, false = square
  final List<Color> _recentColors = []; // recently used colors for picker
  double _phoneScale = 1.0; // responsive scale factor for phone previews

  double sc(double v) => v * _phoneScale;
  final Map<String, String> _elementTexts = {
    'intro_title': 'App Name',
    'intro_description': 'A short description of what this app does goes here.',
    'login_app_name': 'RegentSpace',
    'login_heading': 'Login',
    'login_subtitle': 'Welcome back, please sign in',
    'login_email_label': 'Email',
    'login_email_hint': 'you@example.com',
    'login_password_label': 'Password',
    'login_password_hint': '••••••••',
    'login_forgot': 'Forgot password?',
    'login_button': 'Log In',
    'login_signup': "Don't have an account? Sign up",
    'signup_app_name': 'RegentSpace',
    'signup_heading': 'Create Account',
    'signup_subtitle': 'Welcome user, fill the follow',
    'signup_username_label': 'Username',
    'signup_username_hint': 'e.g. John',
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

  // Undo / Redo history
  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];
  static const int _maxHistory = 50;

  Map<String, dynamic> _snapshot() => {
    'elementColors': Map<String, Color>.from(_elementColors),
    'containerBackgrounds': Map<String, Color>.from(_containerBackgrounds),
    'screenBackgrounds': Map<int, Color>.from(_screenBackgrounds),
    'elementTexts': Map<String, String>.from(_elementTexts),
    'appIconImage': _appIconImage != null ? Uint8List.fromList(_appIconImage!) : null,
  };

  void _restoreSnapshot(Map<String, dynamic> s) {
    _elementColors
      ..clear()
      ..addAll(Map<String, Color>.from(s['elementColors']));
    _containerBackgrounds
      ..clear()
      ..addAll(Map<String, Color>.from(s['containerBackgrounds']));
    _screenBackgrounds
      ..clear()
      ..addAll(Map<int, Color>.from(s['screenBackgrounds']));
    _elementTexts
      ..clear()
      ..addAll(Map<String, String>.from(s['elementTexts']));
    _appIconImage = s['appIconImage'] as Uint8List?;
  }

  void _pushUndo() {
    if (_undoStack.length >= _maxHistory) _undoStack.removeAt(0);
    _undoStack.add(_snapshot());
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_snapshot());
    _restoreSnapshot(_undoStack.removeLast());
    setState(() {});
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_snapshot());
    _restoreSnapshot(_redoStack.removeLast());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Element classification helpers
  bool _isImageElement(String id) => id == 'intro_icon' || id == 'login_logo' || id == 'signup_logo';
  bool _isTextElement(String id) => id.contains('title') || id.contains('heading') || id.contains('subtitle') ||
      id.contains('description') || id.contains('label') || id.contains('hint') || id.contains('forgot') ||
      id.contains('button') ||
      (id.contains('signup') && !id.contains('logo') && !id.contains('email') && !id.contains('password') && !id.contains('confirm') && !id.contains('username')) ||
      (id.contains('login') && !id.contains('logo') && !id.contains('email') && !id.contains('password')) ||
      id == 'home_services_title' || id == 'finance_heading' || id == 'finance_subtitle' ||
      id == 'finance_plan_title' || id == 'finance_transactions_title' || id == 'profile_heading' ||
      id == 'finance_summary' ||
      id.contains('_text') || id.contains('_icon') || id.contains('_amount') ||
      id.contains('_subtitle') || id.contains('_renew') || id.contains('_label') ||
      id == 'login_app_name' || id == 'signup_app_name';
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
        if (_isTextElement(id) || id == 'home_wallet' || id == 'finance_plan_card' || id == 'profile_personal' || id == 'profile_payment' || id == 'profile_security' || id == 'profile_notifications' || id == 'profile_help' || id == 'profile_logout') {
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

    _pushUndo();
    Color lastPicked = currentColor;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(forText ? 'Text Color' : 'Container Color', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recentColors.isNotEmpty) ...[
                  Text('Recent', style: AppTextStyles.caption(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentColors.map((c) {
                      final isSelected = c.toARGB32() == lastPicked.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (forText) { _elementColors[id] = c; }
                            else { _containerBackgrounds[id] = c; }
                          });
                          lastPicked = c;
                          setDialogState(() {});
                        },
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (color) {
                    setState(() {
                      if (forText) { _elementColors[id] = color; }
                      else { _containerBackgrounds[id] = color; }
                    });
                    lastPicked = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: false,
                  paletteType: PaletteType.hsvWithHue,
                ),
              ],
            ),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Cancel', style: AppTextStyles.body(color: AppColors.textSecondary)),
                ),
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () {
                    _addRecentColor(lastPicked);
                    Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Done', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
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
    _pushUndo();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text('Edit Text', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter new text',
            hintStyle: const TextStyle(fontFamily: 'DMSans', color: AppColors.textHint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Cancel', style: AppTextStyles.body(color: AppColors.textSecondary)),
              ),
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
              TextButton(
                onPressed: () {
                  setState(() => _elementTexts[id] = controller.text);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text('Save', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
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
    _pushUndo();
    Color lastPicked = currentColor;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(isScreen ? 'Screen Background' : 'Background Color', textAlign: TextAlign.center, style: AppTextStyles.title(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recentColors.isNotEmpty) ...[
                  Text('Recent', style: AppTextStyles.caption(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentColors.map((c) {
                      final isSelected = c.toARGB32() == lastPicked.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isScreen) { _screenBackgrounds[int.parse(id.split('_')[1])] = c; }
                            else { _containerBackgrounds[id] = c; }
                          });
                          lastPicked = c;
                          setDialogState(() {});
                        },
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (color) {
                    setState(() {
                      if (isScreen) { _screenBackgrounds[int.parse(id.split('_')[1])] = color; }
                      else { _containerBackgrounds[id] = color; }
                    });
                    lastPicked = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: false,
                  paletteType: PaletteType.hsvWithHue,
                ),
              ],
            ),
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Cancel', style: AppTextStyles.body(color: AppColors.textSecondary)),
                ),
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                TextButton(
                  onPressed: () {
                    _addRecentColor(lastPicked);
                    Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Done', style: AppTextStyles.body(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showObjectDropdown(String id) {
    _pushUndo();
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
          if (_appIconImage != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() { _appIconCrop = !_appIconCrop; });
              },
              child: Row(children: [
                Icon(_appIconCrop ? Icons.crop : Icons.fit_screen, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(_appIconCrop ? 'Show Full Image' : 'Crop to Fit',
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 14)),
              ]),
            ),
          if (_appIconImage != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() { _appIconRoundBorder = !_appIconRoundBorder; });
              },
              child: Row(children: [
                Icon(_appIconRoundBorder ? Icons.square : Icons.rounded_corner, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(_appIconRoundBorder ? 'Square corners' : 'Rounded corners',
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 14)),
              ]),
            ),
        ],
      ),
    );
  }

  void _addRecentColor(Color color) {
    _recentColors.removeWhere((c) => c.toARGB32() == color.toARGB32());
    _recentColors.insert(0, color);
    if (_recentColors.length > 10) _recentColors.removeLast();
  }

  // ================================================================
  // HIVE PERSISTENCE
  // ================================================================

  static const String _boxName = 'canva_progress';

  Future<void> _saveProgress() async {
    final box = await Hive.openBox(_boxName);

    // Save element colors (convert Color to int)
    final colorMap = <String, int>{};
    _elementColors.forEach((key, value) {
      colorMap[key] = value.toARGB32();
    });
    await box.put('elementColors', colorMap);

    // Save container backgrounds
    final bgMap = <String, int>{};
    _containerBackgrounds.forEach((key, value) {
      bgMap[key] = value.toARGB32();
    });
    await box.put('containerBackgrounds', bgMap);

    // Save screen backgrounds (convert int key to string for Hive)
    final screenMap = <String, int>{};
    _screenBackgrounds.forEach((key, value) {
      screenMap[key.toString()] = value.toARGB32();
    });
    await box.put('screenBackgrounds', screenMap);

    // Save element texts
    await box.put('elementTexts', _elementTexts);

    // Save app icon image (Uint8List)
    if (_appIconImage != null) {
      await box.put('appIconImage', _appIconImage);
    } else {
      await box.delete('appIconImage');
    }
    await box.put('appIconCrop', _appIconCrop);
    await box.put('appIconRoundBorder', _appIconRoundBorder);
    await box.put('recentColors', _recentColors.map((c) => c.toARGB32()).toList());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress saved successfully'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF0D9229),
        ),
      );
      AppNotifications.canvaProjectSaved(projectName: 'Your Design');
    }
  }

  Future<void> _revertProgress() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();

    _pushUndo();
    setState(() {
      _elementColors.clear();
      _containerBackgrounds.clear();
      _screenBackgrounds.clear();
      _appIconImage = null;
      _appIcon = Icons.image_outlined;
      _appIconCrop = true;
      _appIconRoundBorder = true;

      // Restore default texts
      _elementTexts
        ..clear()
        ..addAll({
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
          'signup_username_label': 'Username',
          'signup_username_hint': 'e.g. John',
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
        });
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress reverted to default'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFE53935),
        ),
      );
    }
  }

  Future<void> _loadProgress() async {
    final box = await Hive.openBox(_boxName);

    // Load element colors
    final colorMap = box.get('elementColors');
    if (colorMap != null) {
      final map = Map<String, int>.from(colorMap);
      map.forEach((key, value) {
        _elementColors[key] = Color(value);
      });
    }

    // Load container backgrounds
    final bgMap = box.get('containerBackgrounds');
    if (bgMap != null) {
      final map = Map<String, int>.from(bgMap);
      map.forEach((key, value) {
        _containerBackgrounds[key] = Color(value);
      });
    }

    // Load screen backgrounds
    final screenMap = box.get('screenBackgrounds');
    if (screenMap != null) {
      final map = Map<String, int>.from(screenMap);
      map.forEach((key, value) {
        _screenBackgrounds[int.parse(key)] = Color(value);
      });
    }

    // Load element texts
    final texts = box.get('elementTexts');
    if (texts != null) {
      _elementTexts
        ..clear()
        ..addAll(Map<String, String>.from(texts));
    }

    // Load app icon image
    final imageData = box.get('appIconImage');
    if (imageData != null) {
      _appIconImage = Uint8List.fromList(List<int>.from(imageData));
      _appIcon = Icons.image;
    }
    _appIconCrop = box.get('appIconCrop', defaultValue: true);
    _appIconRoundBorder = box.get('appIconRoundBorder', defaultValue: true);
    final recentColorInts = box.get('recentColors');
    if (recentColorInts != null) {
      _recentColors
        ..clear()
        ..addAll((recentColorInts as List).map((v) => Color(v as int)));
    }

    if (mounted) setState(() {});
  }

  // ================================================================
  // APP ICON WIDGET (synced across intro, login, signup)
  // ================================================================

  Widget _buildAppIcon({double size = 28, double borderRadius = 8}) {
    final hasImage = _appIconImage != null;
    final radius = hasImage && !_appIconRoundBorder ? 0.0 : borderRadius;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasImage ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.memory(_appIconImage!,
                fit: _appIconCrop ? BoxFit.cover : BoxFit.contain),
            )
          : Icon(_appIcon, size: size * 0.5, color: const Color(0xFFB0B0B0)),
    );
  }

  // ================================================================
  // BUILD SERVER INTEGRATION
  // ================================================================

  String _colorToHex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  Map<String, dynamic> _generateBuildJson() {
    final screenTypes = ['intro', 'login', 'signup', 'home', 'finance', 'profile'];

    // Collect ALL element IDs from all maps so nothing is missed
    final allElementIds = <String>{};
    allElementIds.addAll(_elementTexts.keys);
    allElementIds.addAll(_elementColors.keys);
    allElementIds.addAll(_containerBackgrounds.keys);

    final screens = <Map<String, dynamic>>[];
    for (var i = 0; i < screenTypes.length; i++) {
      final type = screenTypes[i];
      final bg = _screenBackgrounds[i];
      final elements = <String, dynamic>{};

      for (final id in allElementIds) {
        if (id.startsWith('${type}_') || (type == 'intro' && id.startsWith('intro_'))) {
          final el = <String, dynamic>{};
          if (_elementTexts.containsKey(id)) el['text'] = _elementTexts[id];
          if (_elementColors.containsKey(id)) el['color'] = _colorToHex(_elementColors[id]!);
          if (_containerBackgrounds.containsKey(id)) el['bg'] = _colorToHex(_containerBackgrounds[id]!);
          if (el.isNotEmpty) elements[id] = el;
        }
      }

      screens.add({
        'type': type,
        if (bg != null) 'bg': _colorToHex(bg),
        'elements': elements,
      });
    }

    // App icon as base64
    String? iconBase64;
    if (_appIconImage != null && _appIconImage!.isNotEmpty) {
      iconBase64 = base64Encode(_appIconImage!);
    }

    final appName = _getTextForElement('intro_title') ?? 'My App';
    final sanitizedName = appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return {
      'app': {
        'id': sanitizedName.toLowerCase(),
        'name': appName,
        'description': _getTextForElement('intro_description') ?? '',
        'packageName': 'com.regent.${sanitizedName.toLowerCase()}',
        'version': '1.0.0',
        'versionCode': 1,
        'fcmChannel': '${sanitizedName.toLowerCase()}_channel',
        if (iconBase64 != null) 'iconBase64': iconBase64,
        if (iconBase64 != null) 'iconFit': _appIconCrop ? 'cover' : 'contain',
        if (iconBase64 != null) 'iconRoundBorder': _appIconRoundBorder,
      },
      'firebase': {
        'projectId': 'regentspace-builder',
        'projectNumber': '540697819834',
        'storageBucket': 'regentspace-builder.firebasestorage.app',
        'appId': '1:540697819834:android:fea3c4853d6afb31c82083',
        'apiKey': 'AIzaSyDKvRGEE-9HcPtrJqrAlR0ZD4020BKa9NQ',
      },
      'theme': {
        'primaryColor': _colorToHex(_containerBackgrounds['login_button'] ?? const Color(0xFF6C0090)),
        'accentColor': _colorToHex(_containerBackgrounds['signup_button'] ?? const Color(0xFF740690)),
        'background': '#F5F5F7',
      },
      'screens': screens,
    };
  }

  Future<void> _startBuild() async {
    final json = _generateBuildJson();
    final appName = json['app']['name'] ?? 'App';

    // Show pending snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pending build request...'),
        backgroundColor: Color(0xFF6C0090),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await BuildTracker.instance.submitBuild(json);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Building $appName... You\'ll be notified when ready.'),
          backgroundColor: const Color(0xFF00875A),
          duration: const Duration(seconds: 3),
        ),
      );
      // Switch to dashboard tab
      currentTabNotifier.value = 0;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Build failed to start: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
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
                      onTap: () => setState(() {
                        _isEditMode = !_isEditMode;
                        if (!_isEditMode) _selectedElementId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isEditMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isEditMode ? Colors.white : const Color(0xFF777777),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: !_isEditMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: !_isEditMode ? Colors.white : const Color(0xFF777777),
                                ),
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
                                isAvailable: hasSelection && ((_isTextElement(id) && !_isImageElement(id)) || _isContainerElement(id) || id == 'home_wallet' || id == 'finance_plan_card' || id == 'profile_personal' || id == 'profile_payment' || id == 'profile_security' || id == 'profile_notifications' || id == 'profile_help' || id == 'profile_logout') && !id.startsWith('screen_') && !_isImageElement(id),
                                onTap: () => _onToolbarTap('Color'),
                              ),
                              _buildToolbarOption(
                                icon: Icons.text_fields_rounded,
                                label: 'Text',
                                isActive: _isEditMode,
                                isAvailable: hasSelection && _isTextElement(id) && !_isImageElement(id),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final previewH = constraints.maxHeight;
                  _phoneScale = (previewH / 480).clamp(0.5, 1.5);
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: sc(24),
                      vertical: sc(24),
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: sc(24)),
                        child: _buildDevicePreview(index),
                      );
                    },
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionHeader(
                            title: 'Regentspace Canvas',
                            subtitle: 'Design and generate your app',
                          ),
                        ),
                        _buildUndoRedoButton(
                          icon: Icons.undo_rounded,
                          isEnabled: _undoStack.isNotEmpty,
                          onTap: _undo,
                        ),
                        const SizedBox(width: 6),
                        _buildUndoRedoButton(
                          icon: Icons.redo_rounded,
                          isEnabled: _redoStack.isNotEmpty,
                          onTap: _redo,
                        ),
                      ],
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
                            onTap: _saveProgress,
                            isDestructive: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCompactButton(
                            icon: Icons.undo_rounded,
                            label: 'Revert',
                            onTap: _revertProgress,
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
                _startBuild();
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sc(32)),
          border: Border.all(
            color: const Color.fromARGB(157, 69, 69, 69),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: sc(10),
              offset: Offset(0, sc(8)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(sc(30)),
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
                height: sc(24),
                color: const Color(0xFFF9F9F9),
                child: Center(
                  child: Container(
                    width: sc(55),
                    height: sc(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(sc(10)),
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
        padding: EdgeInsets.symmetric(horizontal: sc(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon placeholder
            _selectable(
              id: 'intro_icon',
              child: _buildAppIcon(size: sc(72), borderRadius: sc(18)),
            ),
            SizedBox(height: sc(16)),

            // App name placeholder
            _selectable(
              id: 'intro_title',
              child: Text(
                _getTextForElement('intro_title') ?? 'App Name',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(16),
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            SizedBox(height: sc(6)),

            // App description placeholder
            _selectable(
              id: 'intro_description',
              child: Text(
                _getTextForElement('intro_description') ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(11.5),
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
      padding: EdgeInsets.symmetric(horizontal: sc(18), vertical: sc(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + app name row
          Row(
            children: [
              _selectable(
                id: 'login_logo',
                child: _buildAppIcon(size: sc(28), borderRadius: sc(8)),
              ),
              SizedBox(width: sc(8)),
              _selectable(
                id: 'login_app_name',
                child: Text(
                  _getTextForElement('login_app_name') ?? 'RegentSpace',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(12),
                    fontWeight: FontWeight.w600,
                    color: _elementColors['login_app_name'] ?? const Color(0xFF444444),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sc(28)),

          // "Login" heading
          _selectable(
            id: 'login_heading',
            child: Text(
              _getTextForElement('login_heading') ?? 'Login',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(18),
                fontWeight: FontWeight.w700,
                color: _elementColors['login_heading'] ?? const Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(height: sc(4)),
          _selectable(
            id: 'login_subtitle',
            child: Text(
              _getTextForElement('login_subtitle') ?? '',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(10),
                fontWeight: FontWeight.w400,
                color: _elementColors['login_subtitle'] ?? const Color(0xFFAAAAAA),
              ),
            ),
          ),
          SizedBox(height: sc(20)),

          // Email field
          _selectable(id: 'login_email', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('login_email_label') ?? 'Email',
            hint: _getTextForElement('login_email_hint') ?? '',
            elementId: 'login_email',
          )),
          SizedBox(height: sc(12)),

          // Password field
          _selectable(id: 'login_password', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('login_password_label') ?? 'Password',
            hint: _getTextForElement('login_password_hint') ?? '',
            elementId: 'login_password',
          )),
          SizedBox(height: sc(8)),

          // Forgot password
          _selectable(
            id: 'login_forgot',
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getTextForElement('login_forgot') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(9.5),
                  fontWeight: FontWeight.w500,
                  color: _elementColors['login_forgot'] ?? const Color(0xFFB0B0B0),
                ),
              ),
            ),
          ),
          SizedBox(height: sc(20)),

          // Login button
          _selectable(
            id: 'login_button',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sc(12)),
              decoration: BoxDecoration(
                color: _containerBackgrounds['login_button'] ?? const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(sc(10)),
              ),
              child: Center(
                child: Text(
                  _getTextForElement('login_button') ?? 'Log In',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(12),
                    fontWeight: FontWeight.w600,
                    color: _elementColors['login_button'] ?? const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: sc(16)),

          // Sign up prompt
          _selectable(
            id: 'login_signup',
            child: Center(
              child: Text(
                _getTextForElement('login_signup') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(10),
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
      padding: EdgeInsets.symmetric(horizontal: sc(18), vertical: sc(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + app name row
          Row(
            children: [
              _selectable(
                id: 'signup_logo',
                child: _buildAppIcon(size: sc(28), borderRadius: sc(8)),
              ),
              SizedBox(width: sc(8)),
              _selectable(
                id: 'signup_app_name',
                child: Text(
                  _getTextForElement('signup_app_name') ?? 'RegentSpace',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(12),
                    fontWeight: FontWeight.w600,
                    color: _elementColors['signup_app_name'] ?? const Color(0xFF444444),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sc(28)),

          // "Create Account" heading
          _selectable(
            id: 'signup_heading',
            child: Text(
              _getTextForElement('signup_heading') ?? 'Create Account',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(18),
                fontWeight: FontWeight.w700,
                color: _elementColors['signup_heading'] ?? const Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(height: sc(4)),
          _selectable(
            id: 'signup_subtitle',
            child: Text(
              _getTextForElement('signup_subtitle') ?? '',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(10),
                fontWeight: FontWeight.w400,
                color: _elementColors['signup_subtitle'] ?? const Color(0xFFAAAAAA),
              ),
            ),
          ),
          SizedBox(height: sc(20)),

          // Username field
          _selectable(id: 'signup_username', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_username_label') ?? 'Username',
            hint: _getTextForElement('signup_username_hint') ?? '',
            elementId: 'signup_username',
          )),
          SizedBox(height: sc(12)),

          // Email field
          _selectable(id: 'signup_email', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_email_label') ?? 'Email',
            hint: _getTextForElement('signup_email_hint') ?? '',
            elementId: 'signup_email',
          )),
          SizedBox(height: sc(12)),

          // Password field
          _selectable(id: 'signup_password', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_password_label') ?? 'Password',
            hint: _getTextForElement('signup_password_hint') ?? '',
            elementId: 'signup_password',
          )),
          SizedBox(height: sc(8)),

          // Confirm Password field
          _selectable(id: 'signup_confirm', fullWidth: true, child: _buildLoginField(
            label: _getTextForElement('signup_confirm_label') ?? 'Confirm Password',
            hint: _getTextForElement('signup_confirm_hint') ?? '',
            elementId: 'signup_confirm',
          )),
          SizedBox(height: sc(8)),

          // Forgot password
          _selectable(
            id: 'signup_forgot',
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getTextForElement('signup_forgot') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(9.5),
                  fontWeight: FontWeight.w500,
                  color: _elementColors['signup_forgot'] ?? const Color(0xFFB0B0B0),
                ),
              ),
            ),
          ),
          SizedBox(height: sc(20)),

          // Sign up button
          _selectable(
            id: 'signup_button',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sc(12)),
              decoration: BoxDecoration(
                color: _containerBackgrounds['signup_button'] ?? const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(sc(10)),
              ),
              child: Center(
                child: Text(
                  _getTextForElement('signup_button') ?? 'Log In',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(12),
                    fontWeight: FontWeight.w600,
                    color: _elementColors['signup_button'] ?? const Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: sc(16)),

          // Sign up prompt
          _selectable(
            id: 'signup_login',
            child: Center(
              child: Text(
                _getTextForElement('signup_login') ?? '',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: sc(10),
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
            fontSize: sc(10),
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        SizedBox(height: sc(4)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: sc(10), vertical: sc(9)),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(sc(8)),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            hint,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: sc(10.5),
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
      padding: EdgeInsets.symmetric(horizontal: sc(16), vertical: sc(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting row: avatar + hello/name column
          _selectable(
            id: 'home_greeting',
            child: Row(
              children: [
                CircleAvatar(
                  radius: sc(18),
                  backgroundColor: const Color(0xFFE5E5E5),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: sc(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ),
                SizedBox(width: sc(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello again',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: sc(7),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                    SizedBox(height: sc(2)),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: sc(10),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: sc(18)),

          // Wallet banner
          _selectable(
            id: 'home_wallet',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(sc(14)),
              decoration: BoxDecoration(
                color: _containerBackgrounds['home_wallet'] ?? const Color.fromARGB(255, 89, 88, 88),
                borderRadius: BorderRadius.circular(sc(14)),
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
                                fontSize: sc(8.5),
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                            SizedBox(width: sc(1)),
                            Text(
                              ':',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: sc(8.5),
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                            SizedBox(width: sc(1)),
                            Text(
                              ' 0123456789',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: sc(8.5),
                                color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sc(5)),
                        Text(
                          '₦0.00',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: sc(13),
                            fontWeight: FontWeight.w700,
                            color: _elementColors['home_wallet_amount'] ?? Colors.white,
                          ),
                        ),
                        SizedBox(height: sc(1)),
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: sc(8.5),
                            color: _elementColors['home_wallet'] ?? _elementColors['home_wallet_label'] ?? const Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: sc(8)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sc(5), vertical: sc(4)),
                    decoration: BoxDecoration(
                      color: _containerBackgrounds['home_wallet_button'] ?? Colors.white,
                      borderRadius: BorderRadius.circular(sc(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: sc(16),
                          color: _elementColors['home_wallet_button_text'] ?? const Color(0xFF2E2E2E),
                        ),
                        SizedBox(width: sc(4)),
                        Text(
                          'Add money',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: sc(8.5),
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
          SizedBox(height: sc(18)),

          // VTU services list
          _selectable(
            id: 'home_services_title',
            child: Text(
              'Services',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(11.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          SizedBox(height: sc(10)),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: sc(12),
            crossAxisSpacing: sc(8),
            children: [
              _selectable(
                id: 'service_airtime',
                child: _VtuServiceItem(icon: Icons.phone_android_rounded, label: 'Airtime',
                  iconColor: _elementColors['service_airtime_icon'], bgColor: _containerBackgrounds['service_airtime'],
                  textColor: _elementColors['service_airtime_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_data',
                child: _VtuServiceItem(icon: Icons.wifi_rounded, label: 'Data',
                  iconColor: _elementColors['service_data_icon'], bgColor: _containerBackgrounds['service_data'],
                  textColor: _elementColors['service_data_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_electricity',
                child: _VtuServiceItem(icon: Icons.bolt_rounded, label: 'Electricity',
                  iconColor: _elementColors['service_electricity_icon'], bgColor: _containerBackgrounds['service_electricity'],
                  textColor: _elementColors['service_electricity_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_cable',
                child: _VtuServiceItem(icon: Icons.tv_rounded, label: 'Cable TV',
                  iconColor: _elementColors['service_cable_icon'], bgColor: _containerBackgrounds['service_cable'],
                  textColor: _elementColors['service_cable_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_education',
                child: _VtuServiceItem(icon: Icons.school_rounded, label: 'Education',
                  iconColor: _elementColors['service_education_icon'], bgColor: _containerBackgrounds['service_education'],
                  textColor: _elementColors['service_education_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_betting',
                child: _VtuServiceItem(icon: Icons.sports_soccer_rounded, label: 'Betting',
                  iconColor: _elementColors['service_betting_icon'], bgColor: _containerBackgrounds['service_betting'],
                  textColor: _elementColors['service_betting_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_water',
                child: _VtuServiceItem(icon: Icons.water_drop_rounded, label: 'Water',
                  iconColor: _elementColors['service_water_icon'], bgColor: _containerBackgrounds['service_water'],
                  textColor: _elementColors['service_water_text'], scale: _phoneScale),
              ),
              _selectable(
                id: 'service_more',
                child: _VtuServiceItem(icon: Icons.more_horiz_rounded, label: 'More',
                  iconColor: _elementColors['service_more_icon'], bgColor: _containerBackgrounds['service_more'],
                  textColor: _elementColors['service_more_text'], scale: _phoneScale),
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildVtuFinanceScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sc(16), vertical: sc(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectable(
            id: 'finance_heading',
            child: Text(
              'Finance',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(height: sc(2)),
          _selectable(
            id: 'finance_subtitle',
            child: Text(
              'Track your balance and spending',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(8.5),
                fontWeight: FontWeight.w400,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ),
          SizedBox(height: sc(16)),

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
                    scale: _phoneScale,
                  ),
                ),
                SizedBox(width: sc(10)),
                Expanded(
                  child: _FinanceSummaryTile(
                    label: 'This Month',
                    value: '₦0.00',
                    icon: Icons.trending_down_rounded,
                    iconColor: _elementColors['finance_summary'],
                    textColor: _elementColors['finance_summary'],
                    scale: _phoneScale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sc(18)),

          // Current plan card
          _selectable(
            id: 'finance_plan_title',
            child: Text(
              'Current Plan',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(11.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          SizedBox(height: sc(10)),
          _selectable(
            id: 'finance_plan_card',
            fullWidth: true,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(sc(14)),
              decoration: BoxDecoration(
                color: _containerBackgrounds['finance_plan_card'] ?? const Color.fromARGB(255, 89, 88, 88),
                borderRadius: BorderRadius.circular(sc(14)),
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
                                fontSize: sc(11),
                                fontWeight: FontWeight.w700,
                                color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_title'] ?? Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sc(4)),
                        Text(
                          'Subscribe to a data or cable plan',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: sc(8),
                            color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_subtitle'] ?? const Color(0xFFAAAAAA),
                          ),
                        ),
                        SizedBox(height: sc(8)),
                        Text(
                          'Renews: —',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: sc(7.5),
                            color: _elementColors['finance_plan_card'] ?? _elementColors['finance_plan_card_renew'] ?? const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sc(8), vertical: sc(4)),
                    decoration: BoxDecoration(
                      color: _containerBackgrounds['finance_plan_card_button'] ?? Colors.white,
                      borderRadius: BorderRadius.circular(sc(10)),
                    ),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: sc(8),
                        fontWeight: FontWeight.w600,
                        color: _elementColors['finance_plan_card_button_text'] ?? const Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sc(18)),

          // Transactions
          _selectable(
            id: 'finance_transactions_title',
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(11.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF444444),
              ),
            ),
          ),
          SizedBox(height: sc(10)),
          _selectable(
            id: 'finance_transactions_list',
            fullWidth: true,
            child: _TransactionItem(
              icon: Icons.wifi_rounded,
              title: 'Data Purchase',
              subtitle: 'No transactions yet',
              amount: '',
              isCredit: false,
              iconColor: _elementColors['finance_transactions_list_icon'],
              bgColor: _containerBackgrounds['finance_transactions_list'],
              textColor: _elementColors['finance_transactions_list_text'],
              scale: _phoneScale,
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
      padding: EdgeInsets.symmetric(horizontal: sc(16), vertical: sc(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectable(
            id: 'profile_heading',
            child: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          SizedBox(height: sc(16)),

          // Avatar + name + email
          _selectable(
            id: 'profile_avatar',
            fullWidth: true,
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: sc(26),
                    backgroundColor: const Color(0xFFE5E5E5),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: sc(15),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ),
                  SizedBox(height: sc(8)),
                  Text(
                    fullName,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: sc(11.5),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: sc(2)),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: sc(8.5),
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sc(20)),

          // Menu items
          _selectable(id: 'profile_personal', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.person_outline_rounded, label: 'Personal Information',
            bgColor: _containerBackgrounds['profile_personal'], iconColor: _elementColors['profile_personal'],
            textColor: _elementColors['profile_personal'], scale: _phoneScale,
          )),
          _selectable(id: 'profile_payment', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.credit_card_rounded, label: 'Payment Methods',
            bgColor: _containerBackgrounds['profile_payment'], iconColor: _elementColors['profile_payment'],
            textColor: _elementColors['profile_payment'], scale: _phoneScale,
          )),
          _selectable(id: 'profile_security', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.lock_outline_rounded, label: 'Security',
            bgColor: _containerBackgrounds['profile_security'], iconColor: _elementColors['profile_security'],
            textColor: _elementColors['profile_security'], scale: _phoneScale,
          )),
          _selectable(id: 'profile_notifications', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.notifications_none_rounded, label: 'Notifications',
            bgColor: _containerBackgrounds['profile_notifications'], iconColor: _elementColors['profile_notifications'],
            textColor: _elementColors['profile_notifications'], scale: _phoneScale,
          )),
          _selectable(id: 'profile_help', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.help_outline_rounded, label: 'Help & Support',
            bgColor: _containerBackgrounds['profile_help'], iconColor: _elementColors['profile_help'],
            textColor: _elementColors['profile_help'], scale: _phoneScale,
          )),
          SizedBox(height: sc(10)),
          _selectable(id: 'profile_logout', fullWidth: true, child: _ProfileMenuItem(
            icon: Icons.logout_rounded, label: 'Log Out', isDestructive: true,
            bgColor: _containerBackgrounds['profile_logout'], iconColor: _elementColors['profile_logout'],
            textColor: _elementColors['profile_logout'], scale: _phoneScale,
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

  Widget _buildUndoRedoButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF7F7F7) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEnabled ? AppColors.border : const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.textSecondary : const Color(0xFFCCCCCC),
        ),
      ),
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
  final double scale;

  const _VtuServiceItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.bgColor,
    this.textColor,
    this.scale = 1.0,
  });

  double sc(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: sc(36),
          height: sc(36),
          decoration: BoxDecoration(
            color: bgColor ?? const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(sc(10)),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Icon(icon, size: sc(16), color: iconColor ?? const Color(0xFF777777)),
        ),
        SizedBox(height: sc(5)),
        SizedBox(
          width: sc(50),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: sc(6),
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
  final double scale;

  const _FinanceSummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.textColor,
    this.scale = 1.0,
  });

  double sc(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sc(12)),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(sc(12)),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: sc(16), color: iconColor ?? const Color(0xFF777777)),
          SizedBox(height: sc(8)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: sc(12),
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF333333),
            ),
          ),
          SizedBox(height: sc(2)),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: sc(7.5),
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
  final Color? iconColor;
  final Color? bgColor;
  final Color? textColor;
  final double scale;

  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    this.iconColor,
    this.bgColor,
    this.textColor,
    this.scale = 1.0,
  });

  double sc(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sc(8)),
      padding: EdgeInsets.symmetric(horizontal: sc(12), vertical: sc(10)),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(sc(12)),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: sc(30),
            height: sc(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sc(9)),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            ),
            child: Icon(icon, size: sc(14), color: iconColor ?? const Color(0xFF777777)),
          ),
          SizedBox(width: sc(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(9.5),
                    fontWeight: FontWeight.w600,
                    color: textColor ?? const Color(0xFF444444),
                  ),
                ),
                SizedBox(height: sc(2)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: sc(7.5),
                    color: textColor ?? const Color(0xFFAAAAAA),
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
                fontSize: sc(9.5),
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
  final double scale;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.bgColor,
    this.iconColor,
    this.textColor,
    this.scale = 1.0,
  });

  double sc(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    final defaultBg = isDestructive ? const Color(0xFFFDEDED) : const Color(0xFFF7F7F7);
    final defaultBorder = isDestructive ? const Color(0xFFF5C6C6) : const Color(0xFFE5E5E5);
    final defaultIcon = isDestructive ? const Color(0xFFC62828) : const Color(0xFF777777);
    final defaultText = isDestructive ? const Color(0xFFC62828) : const Color(0xFF444444);
    return Container(
      margin: EdgeInsets.only(bottom: sc(8)),
      padding: EdgeInsets.symmetric(horizontal: sc(12), vertical: sc(10)),
      decoration: BoxDecoration(
        color: bgColor ?? defaultBg,
        borderRadius: BorderRadius.circular(sc(12)),
        border: Border.all(color: defaultBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: sc(15), color: iconColor ?? defaultIcon),
          SizedBox(width: sc(10)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: sc(9.5),
                fontWeight: FontWeight.w600,
                color: textColor ?? defaultText,
              ),
            ),
          ),
          if (!isDestructive)
            Icon(Icons.arrow_forward_ios_rounded, size: sc(12), color: const Color(0xFFBBBBBB)),
        ],
      ),
    );
  }
}