import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../theme/app_theme.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  static const _boxName = 'appearance';
  String _selectedTheme = 'System Default';
  bool _compactMode = false;
  double _fontSizeScale = 1.0;

  final List<Map<String, dynamic>> _themes = [
    {'name': 'System Default', 'icon': Icons.brightness_auto_rounded},
    {'name': 'Light', 'icon': Icons.light_mode_rounded},
    {'name': 'Dark', 'icon': Icons.dark_mode_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);
    setState(() {
      _selectedTheme = box.get('theme', defaultValue: 'System Default');
      _compactMode = box.get('compactMode', defaultValue: false);
      _fontSizeScale = box.get('fontSizeScale', defaultValue: 1.0);
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Appearance", style: AppTextStyles.headline(color: AppColors.textPrimary)),
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
            // ── Theme Selection ──
            Text("Theme", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _themes.map((theme) {
                  final isSelected = _selectedTheme == theme['name'];
                  final isFirst = theme == _themes.first;
                  return Column(
                    children: [
                      if (!isFirst) const Divider(height: 1, thickness: 0.5, indent: 52, color: AppColors.border),
                      _ThemeOption(
                        icon: theme['icon'],
                        title: theme['name'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedTheme = theme['name']);
                          _saveSetting('theme', theme['name']);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Display Settings ──
            Text("Display", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: _SwitchTile(
                icon: Icons.view_compact_rounded,
                title: 'Compact Mode',
                subtitle: 'Show more content on screen',
                value: _compactMode,
                onChanged: (v) {
                  setState(() => _compactMode = v);
                  _saveSetting('compactMode', v);
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Font Size ──
            Text("Font Size", style: AppTextStyles.titleSmall(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("A", style: AppTextStyles.caption(color: AppColors.textPrimary)),
                      Expanded(
                        child: Slider(
                          value: _fontSizeScale,
                          min: 0.8,
                          max: 1.2,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() => _fontSizeScale = v);
                            _saveSetting('fontSizeScale', v);
                          },
                        ),
                      ),
                      Text("A", style: AppTextStyles.headline(color: AppColors.textPrimary)),
                    ],
                  ),
                  Text(_fontSizeScale == 1.0 ? 'Default' : '${(_fontSizeScale * 100).round()}%', style: AppTextStyles.caption(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
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
                  color: isSelected ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: AppTextStyles.body(color: AppColors.textPrimary)),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
              else
                Icon(Icons.circle_outlined, color: AppColors.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
