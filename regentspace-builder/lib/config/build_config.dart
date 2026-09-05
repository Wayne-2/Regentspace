import 'dart:convert';
import 'package:flutter/material.dart';

/// Auto-generated build configuration.
/// Loads the baked-in JSON config at startup.
class BuildConfig {
  final String appId;
  final String appName;
  final String appDescription;
  final Map<String, String> elementTexts;
  final Map<String, Color> elementColors;
  final Map<String, Color> containerBackgrounds;
  final Map<int, Color> screenBackgrounds;

  const BuildConfig({
    required this.appId,
    required this.appName,
    required this.appDescription,
    required this.elementTexts,
    required this.elementColors,
    required this.containerBackgrounds,
    required this.screenBackgrounds,
  });

  /// The baked-in JSON string. Replaced by the generator.
  /// This default is for testing only — the generator replaces it.
  static const String _jsonString = '{"app":{"name":"Regentspace Builder","description":"Test build"},"screens":[{"type":"intro","bg":"#F7F7F7","elements":{"intro_title":{"text":"App Name","color":"#444444"}}}]}';

  static BuildConfig? _instance;

  static BuildConfig load() {
    if (_instance != null) return _instance!;
    final map = jsonDecode(_jsonString) as Map<String, dynamic>;
    return _instance = _fromMap(map);
  }

  static BuildConfig _fromMap(Map<String, dynamic> m) {
    final app = m['app'] as Map<String, dynamic>? ?? {};
    final screens = m['screens'] as List<dynamic>? ?? [];

    final elementTexts = <String, String>{};
    final elementColors = <String, Color>{};
    final containerBackgrounds = <String, Color>{};
    final screenBackgrounds = <int, Color>{};

    for (var i = 0; i < screens.length; i++) {
      final screen = screens[i] as Map<String, dynamic>;
      final bg = screen['bg'] as String?;
      if (bg != null) screenBackgrounds[i] = _parseColor(bg);

      final elements = screen['elements'] as Map<String, dynamic>? ?? {};
      for (final entry in elements.entries) {
        final el = entry.value as Map<String, dynamic>;
        if (el.containsKey('text')) {
          elementTexts[entry.key] = el['text'] as String;
        }
        if (el.containsKey('color')) {
          elementColors[entry.key] = _parseColor(el['color'] as String);
        }
        if (el.containsKey('bg')) {
          containerBackgrounds[entry.key] = _parseColor(el['bg'] as String);
        }
      }
    }

    return BuildConfig(
      appId: app['id'] as String? ?? 'default',
      appName: app['name'] as String? ?? 'App',
      appDescription: app['description'] as String? ?? '',
      elementTexts: elementTexts,
      elementColors: elementColors,
      containerBackgrounds: containerBackgrounds,
      screenBackgrounds: screenBackgrounds,
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String getText(String id, {String fallback = ''}) {
    return elementTexts[id] ?? fallback;
  }

  Color getElementColor(String id, {Color? fallback}) {
    return elementColors[id] ?? fallback ?? const Color(0xFF444444);
  }

  Color getContainerBg(String id, {Color? fallback}) {
    return containerBackgrounds[id] ?? fallback ?? const Color(0xFFF7F7F7);
  }

  Color getScreenBg(int index, {Color? fallback}) {
    return screenBackgrounds[index] ?? fallback ?? const Color(0xFFF7F7F7);
  }
}
