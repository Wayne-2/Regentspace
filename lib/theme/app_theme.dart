import 'package:flutter/material.dart';

/// Professional design tokens — DM Sans local font (no google_fonts).
class AppColors {
  // Primary
  static const primary = Color(0xFF6C0090);
  static const primaryLight = Color(0xFFEAC5F7);
  static const primarySoft = Color(0xFFFDF4FF);
  static const primaryDark = Color(0xFF4E0666);
  static const accent = Color(0xFF740690);

  // Text
  static const textPrimary = Color(0xFF1A1A1E);
  static const textSecondary = Color(0xFF5A5A64);
  static const textTertiary = Color(0xFF8E8E96);
  static const textHint = Color(0xFF9FA0A8);
  static const textOnPrimary = Colors.white;

  // Surface / Border
  static const surface = Colors.white;
  static const background = Color(0xFFFDf4FF);
  static const border = Color(0xFFE8E8EA);
  static const borderStrong = Color(0xFFD9D9DE);

  static const success = Color(0xFF0D9229);
  static const error = Color(0xFFE53935);
}

const String _font = 'DMSans';

class AppTextStyles {
  // Display — balances, hero numbers
  static TextStyle display({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
        color: color,
      );

  // Headline — page titles (Login, Canva Studio, Hello Again)
  static TextStyle headline({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
        color: color,
      );

  // Title — card / section titles
  static TextStyle title({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleSmall({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.1,
        color: color,
      );

  // Body — primary reading
  static TextStyle body({Color color = AppColors.textSecondary}) => TextStyle(
        fontFamily: _font,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyStrong({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  // Label — inputs, buttons, tabs
  static TextStyle label({Color color = AppColors.textPrimary}) => TextStyle(
        fontFamily: _font,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textTertiary}) => TextStyle(
        fontFamily: _font,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0.15,
        color: color,
      );

  // Caption — timestamps, helper text
  static TextStyle caption({Color color = AppColors.textTertiary}) => TextStyle(
        fontFamily: _font,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle captionStrong({Color color = AppColors.textSecondary}) => TextStyle(
        fontFamily: _font,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: color,
      );

  // Button
  static TextStyle button({Color color = Colors.white}) => TextStyle(
        fontFamily: _font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.15,
        color: color,
      );

  // Brand (RegentSpace wordmark)
  static TextStyle brand({Color color = AppColors.primaryDark}) => TextStyle(
        fontFamily: _font,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
        color: color,
      );

  static TextStyle brandSub({Color color = AppColors.primaryDark}) => TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 1.2,
        color: color,
      );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: _font,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: AppTextStyles.display(),
    headlineLarge: AppTextStyles.headline(),
    headlineMedium: const TextStyle(fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.3, color: AppColors.textPrimary),
    titleLarge: AppTextStyles.title(),
    titleMedium: AppTextStyles.titleSmall(),
    titleSmall: AppTextStyles.label(),
    bodyLarge: AppTextStyles.body(),
    bodyMedium: AppTextStyles.body(),
    bodySmall: AppTextStyles.caption(),
    labelLarge: AppTextStyles.button(color: AppColors.textPrimary),
    labelSmall: AppTextStyles.caption(),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.2),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.button(color: AppColors.primary),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Color(0xFF9A9AA2),
      selectedLabelStyle: TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
      elevation: 6,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
