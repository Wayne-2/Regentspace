#!/usr/bin/env dart
///
/// Regentspace Builder — Code Generator
///
/// Reads a build JSON file and generates a complete Flutter project.
/// Usage: dart generator/generate.dart <input.json> <output_dir>
///
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Usage: dart generate.dart <input.json> <output_dir>');
    exit(1);
  }

  final jsonPath = args[0];
  final outputDir = args[1];

  final jsonStr = File(jsonPath).readAsStringSync();
  final config = jsonDecode(jsonStr) as Map<String, dynamic>;

  // Resolve template dir — generator lives at regentspace-builder/generator/
  // so template root is one level up
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final templateDir = p.dirname(scriptDir);

  final generator = BuildGenerator(config, jsonStr: jsonStr, templateDir: templateDir);
  generator.generate(outputDir);

  stdout.writeln('Build generated successfully in $outputDir');
}

class BuildGenerator {
  final Map<String, dynamic> config;
  final String jsonStr;
  final String templateDir;
  late final Map<String, dynamic> app;
  late final Map<String, dynamic> firebase;
  late final Map<String, dynamic> theme;
  late final List<dynamic> screens;
  late final Map<String, dynamic> navigation;

  BuildGenerator(this.config, {required this.jsonStr, required this.templateDir}) {
    app = config['app'] as Map<String, dynamic>? ?? {};
    firebase = config['firebase'] as Map<String, dynamic>? ?? {};
    theme = config['theme'] as Map<String, dynamic>? ?? {};
    screens = config['screens'] as List<dynamic>? ?? [];
    navigation = config['navigation'] as Map<String, dynamic>? ?? {};
  }

  void generate(String outputDir) {
    final out = Directory(outputDir);
    if (!out.existsSync()) out.createSync(recursive: true);

    // Create subdirectories
    Directory('$outputDir/lib').createSync(recursive: true);
    Directory('$outputDir/lib/config').createSync(recursive: true);
    Directory('$outputDir/lib/screens').createSync(recursive: true);
    Directory('$outputDir/lib/service').createSync(recursive: true);
    Directory('$outputDir/lib/theme').createSync(recursive: true);
    Directory('$outputDir/assets/fonts').createSync(recursive: true);
    Directory('$outputDir/android/app/src/main').createSync(recursive: true);

    _generatePubspec('$outputDir/pubspec.yaml');
    _generateMain('$outputDir/lib/main.dart');
    _generateBuildConfig('$outputDir/lib/config/build_config.dart');
    _generateFirebaseOptions('$outputDir/lib/firebase_options.dart');
    _generateAndroidManifest('$outputDir/android/app/src/main/AndroidManifest.xml');
    _generateBuildGradle('$outputDir/android/app/build.gradle.kts');
    _generateSettingsGradle('$outputDir/android/settings.gradle.kts');
    _generateMainActivity('$outputDir/android/app/src/main/kotlin');
    _generateGoogleServices('$outputDir/android/app/google-services.json');

    // Copy service files from template
    _copyDirectory('$templateDir/lib/service', '$outputDir/lib/service');

    // Copy theme files from template
    _copyDirectory('$templateDir/lib/theme', '$outputDir/lib/theme');

    // Copy VTPass screens from template
    _copyVtpassScreens('$outputDir/lib/screens');

    // Copy fonts from template
    _copyDirectory('$templateDir/assets/fonts', '$outputDir/assets/fonts');

    // Copy Android resources from template (launcher icons, styles, etc.)
    _copyIfExist('$templateDir/android/app/src/main/res', '$outputDir/android/app/src/main/res');

    // Copy Gradle wrapper from template
    _copyIfExist('$templateDir/android/gradle', '$outputDir/android/gradle');
    _copyIfExist('$templateDir/android/gradlew', '$outputDir/android/gradlew');
    _copyIfExist('$templateDir/android/gradlew.bat', '$outputDir/android/gradlew.bat');

    // Generate screens from canva JSON
    for (final screen in screens) {
      _generateScreen('$outputDir/lib/screens', screen as Map<String, dynamic>);
    }

    // Bake the canva JSON into build_config.dart
    _bakeJson('$outputDir/lib/config/build_config.dart');
  }

  void _copyDirectory(String from, String to) {
    final src = Directory(from);
    if (!src.existsSync()) return;
    final dest = Directory(to);
    if (!dest.existsSync()) dest.createSync(recursive: true);
    for (final entity in src.listSync(recursive: true)) {
      final relative = p.relative(entity.path, from: from);
      final destPath = p.join(to, relative);
      if (entity is File) {
        File(destPath).parent.createSync(recursive: true);
        entity.copySync(destPath);
      } else if (entity is Directory) {
        Directory(destPath).createSync(recursive: true);
      }
    }
  }

  void _copyIfExist(String from, String to) {
    final src = Directory(from);
    if (src.existsSync()) _copyDirectory(from, to);
    final srcFile = File(from);
    if (srcFile.existsSync()) {
      final destFile = File(to);
      destFile.parent.createSync(recursive: true);
      srcFile.copySync(to);
    }
  }

  /// Copy VTPass service screens from template to output
  void _copyVtpassScreens(String screensDir) {
    final vtpassScreens = [
      'airtime_screen.dart',
      'data_screen.dart',
      'cable_tv_screen.dart',
      'electricity_screen.dart',
    ];
    for (final file in vtpassScreens) {
      final src = File('$templateDir/lib/screens/$file');
      if (src.existsSync()) {
        src.copySync('$screensDir/$file');
      }
    }
  }

  /// Replace {{BAKED_JSON}} placeholder in build_config.dart with actual JSON
  void _bakeJson(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    var content = file.readAsStringSync();
    // Escape the JSON for embedding in a Dart string
    final escaped = jsonStr
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
    content = content.replaceAll('{{BAKED_JSON}}', escaped);
    file.writeAsStringSync(content);
  }

  // ---------------------------------------------------------------
  // pubspec.yaml
  // ---------------------------------------------------------------
  void _generatePubspec(String path) {
    final appName = _slugify(app['name'] as String? ?? 'my_app');
    final description = app['description'] as String? ?? 'A Regentspace-built app';
    final version = app['version'] as String? ?? '1.0.0+1';

    final buffer = StringBuffer()
      ..writeln('name: $appName')
      ..writeln('description: $description')
      ..writeln('publish_to: \'none\'')
      ..writeln('version: $version')
      ..writeln()
      ..writeln('environment:')
      ..writeln('  sdk: ^3.12.0')
      ..writeln()
      ..writeln('dependencies:')
      ..writeln('  flutter:')
      ..writeln('    sdk: flutter')
      ..writeln('  firebase_core: ^3.12.1')
      ..writeln('  firebase_auth: ^5.5.4')
      ..writeln('  cloud_firestore: ^5.6.5')
      ..writeln('  cloud_functions: ^5.4.2')
      ..writeln('  firebase_messaging: ^15.2.4')
      ..writeln('  flutter_local_notifications: ^18.0.1')
      ..writeln('  google_sign_in: ^6.2.2')
      ..writeln('  http: ^1.3.0')
      ..writeln('  hive_flutter: ^1.1.0')
      ..writeln('  intl: ^0.20.3')
      ..writeln()
      ..writeln('dev_dependencies:')
      ..writeln('  flutter_test:')
      ..writeln('    sdk: flutter')
      ..writeln('  flutter_lints: ^5.0.0')
      ..writeln()
      ..writeln('flutter:')
      ..writeln('  uses-material-design: true')
      ..writeln('  fonts:')
      ..writeln('    - family: DMSans')
      ..writeln('      fonts:')
      ..writeln('        - asset: assets/fonts/DMSans-Regular.ttf')
      ..writeln('        - asset: assets/fonts/DMSans-Medium.ttf')
      ..writeln('          weight: 500')
      ..writeln('        - asset: assets/fonts/DMSans-SemiBold.ttf')
      ..writeln('          weight: 600')
      ..writeln('        - asset: assets/fonts/DMSans-Bold.ttf')
      ..writeln('          weight: 700');

    File(path).writeAsStringSync(buffer.toString());
  }

  // ---------------------------------------------------------------
  // lib/main.dart
  // ---------------------------------------------------------------
  void _generateMain(String path) {
    final navType = navigation['type'] as String? ?? 'bottom_nav';
    final tabs = (navigation['tabs'] as List<dynamic>?)?.cast<String>() ?? ['home', 'finance', 'profile'];

    final buffer = StringBuffer()
      ..writeln('import \'package:flutter/material.dart\';')
      ..writeln('import \'package:firebase_core/firebase_core.dart\';')
      ..writeln('import \'package:hive_flutter/hive_flutter.dart\';')
      ..writeln('import \'firebase_options.dart\';')
      ..writeln('import \'theme/app_theme.dart\';')
      ..writeln('import \'config/build_config.dart\';')
      ..writeln('import \'service/app_tenant.dart\';')
      ..writeln('import \'service/monnify_config.dart\';')
      ..writeln('import \'service/vtpass_config.dart\';')
      ..writeln('import \'service/notification_store.dart\';')
      ..writeln('import \'service/app_notifications.dart\';')
      ..writeln();

    // Import all screens
    for (final screen in screens) {
      final s = screen as Map<String, dynamic>;
      final type = s['type'] as String;
      final file = _screenFileName(type);
      buffer.writeln('import \'screens/$file\';');
    }
    buffer.writeln();

    // main()
    buffer
      ..writeln('void main() async {')
      ..writeln('  WidgetsFlutterBinding.ensureInitialized();')
      ..writeln()
      ..writeln('  await Firebase.initializeApp(')
      ..writeln('    options: DefaultFirebaseOptions.currentPlatform,')
      ..writeln('  );')
      ..writeln()
      ..writeln('  await Hive.initFlutter();')
      ..writeln('  await NotificationStore.initLocal();')
      ..writeln()
      ..writeln('  final config = BuildConfig.load();')
      ..writeln('  AppTenant.init(config.appId);')
      ..writeln()
      ..writeln('  await Future.wait([')
      ..writeln('    MonnifyConfig.loadFromFirestore(),')
      ..writeln('    VtpassConfig.loadFromFirestore(),')
      ..writeln('  ]);')
      ..writeln()
      ..writeln('  AppNotifications.setAppName(config.appName);')
      ..writeln()
      ..writeln('  runApp(MyApp(appName: config.appName));')
      ..writeln('}')
      ..writeln();

    // MyApp widget
    buffer
      ..writeln('class MyApp extends StatelessWidget {')
      ..writeln('  final String appName;')
      ..writeln('  const MyApp({super.key, required this.appName});')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Widget build(BuildContext context) {')
      ..writeln('    return MaterialApp(')
      ..writeln('      title: appName,')
      ..writeln('      debugShowCheckedModeBanner: false,')
      ..writeln('      theme: buildAppTheme(),')
      ..writeln('      home: const IntroScreen(),')
      ..writeln('      routes: {')
      ..writeln('        \'/\': (_) => const IntroScreen(),')
      ..writeln('        \'/login\': (_) => const LoginScreen(),')
      ..writeln('        \'/signup\': (_) => const SignupScreen(),')
      ..writeln('        \'/home\': (_) => const MainAppShell(),')
      ..writeln('      },')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();

    // MainAppShell (bottom nav)
    if (navType == 'bottom_nav') {
      buffer
        ..writeln('class MainAppShell extends StatefulWidget {')
        ..writeln('  const MainAppShell({super.key});')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  State<MainAppShell> createState() => _MainAppShellState();')
        ..writeln('}')
        ..writeln()
        ..writeln('class _MainAppShellState extends State<MainAppShell> {')
        ..writeln('  int _currentTab = 0;')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln('    final pages = <Widget>[');

      for (final tab in tabs) {
        final className = _screenClassName(tab);
        buffer.writeln('      const $className(),');
      }

      buffer
        ..writeln('    ];')
        ..writeln()
        ..writeln('    return Scaffold(')
        ..writeln('      body: SafeArea(child: pages[_currentTab]),')
        ..writeln('      bottomNavigationBar: BottomNavigationBar(')
        ..writeln('        currentIndex: _currentTab,')
        ..writeln('        onTap: (i) => setState(() => _currentTab = i),')
        ..writeln('        items: const [');

      for (final tab in tabs) {
        final label = tab[0].toUpperCase() + tab.substring(1);
        final icon = _tabIcon(tab);
        buffer
          ..writeln('          BottomNavigationBarItem(')
          ..writeln('            icon: Icon($icon),')
          ..writeln('            label: \'$label\',')
          ..writeln('          ),');
      }

      buffer
      ..writeln('        ],')
        ..writeln('      ),')
        ..writeln('    );')
        ..writeln('  }')
        ..writeln('}');
    }

    File(path).writeAsStringSync(buffer.toString());
  }

  // ---------------------------------------------------------------
  // lib/config/build_config.dart — Simple JSON loader
  // ---------------------------------------------------------------
  void _generateBuildConfig(String path) {
    final buffer = StringBuffer()
      ..writeln('import \'dart:convert\';')
      ..writeln('import \'dart:typed_data\';')
      ..writeln('import \'package:flutter/material.dart\';')
      ..writeln()
      ..writeln('/// Auto-generated build configuration.')
      ..writeln('/// Loads the baked-in JSON config at startup.')
      ..writeln('class BuildConfig {')
      ..writeln('  final String appId;')
      ..writeln('  final String appName;')
      ..writeln('  final String appDescription;')
      ..writeln('  final Uint8List? appIconBytes;')
      ..writeln('  final Map<String, String> elementTexts;')
      ..writeln('  final Map<String, Color> elementColors;')
      ..writeln('  final Map<String, Color> containerBackgrounds;')
      ..writeln('  final Map<int, Color> screenBackgrounds;')
      ..writeln('  final Map<String, dynamic> _theme;')
      ..writeln()
      ..writeln('  const BuildConfig({')
      ..writeln('    required this.appId,')
      ..writeln('    required this.appName,')
      ..writeln('    required this.appDescription,')
      ..writeln('    this.appIconBytes,')
      ..writeln('    required this.elementTexts,')
      ..writeln('    required this.elementColors,')
      ..writeln('    required this.containerBackgrounds,')
      ..writeln('    required this.screenBackgrounds,')
      ..writeln('    Map<String, dynamic> theme = const {},')
      ..writeln('  }) : _theme = theme;')
      ..writeln()
      ..writeln('  /// The baked-in JSON string. Replaced by the generator.')
      ..writeln('  static const String _jsonString = \'{{BAKED_JSON}}\';')
      ..writeln()
      ..writeln('  static BuildConfig? _instance;')
      ..writeln()
      ..writeln('  static BuildConfig load() {')
      ..writeln('    if (_instance != null) return _instance!;')
      ..writeln('    final map = jsonDecode(_jsonString) as Map<String, dynamic>;')
      ..writeln('    return _instance = _fromMap(map);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static BuildConfig _fromMap(Map<String, dynamic> m) {')
      ..writeln('    final app = m[\'app\'] as Map<String, dynamic>? ?? {};')
      ..writeln('    final screens = m[\'screens\'] as List<dynamic>? ?? [];')
      ..writeln()
      ..writeln('    final elementTexts = <String, String>{};')
      ..writeln('    final elementColors = <String, Color>{};')
      ..writeln('    final containerBackgrounds = <String, Color>{};')
      ..writeln('    final screenBackgrounds = <int, Color>{};')
      ..writeln()
      ..writeln('    for (var i = 0; i < screens.length; i++) {')
      ..writeln('      final screen = screens[i] as Map<String, dynamic>;')
      ..writeln('      final bg = screen[\'bg\'] as String?;')
      ..writeln('      if (bg != null) screenBackgrounds[i] = _parseColor(bg);')
      ..writeln()
      ..writeln('      final elements = screen[\'elements\'] as Map<String, dynamic>? ?? {};')
      ..writeln('      for (final entry in elements.entries) {')
      ..writeln('        final el = entry.value as Map<String, dynamic>;')
      ..writeln('        if (el.containsKey(\'text\')) elementTexts[entry.key] = el[\'text\'] as String;')
      ..writeln('        if (el.containsKey(\'color\')) elementColors[entry.key] = _parseColor(el[\'color\'] as String);')
      ..writeln('        if (el.containsKey(\'bg\')) containerBackgrounds[entry.key] = _parseColor(el[\'bg\'] as String);')
      ..writeln('      }')
      ..writeln('    }')
      ..writeln()
      ..writeln('    Uint8List? iconBytes;')
      ..writeln('    final iconBase64 = app[\'iconBase64\'] as String?;')
      ..writeln('    if (iconBase64 != null && iconBase64.isNotEmpty) {')
      ..writeln('      iconBytes = base64Decode(iconBase64);')
      ..writeln('    }')
      ..writeln()
      ..writeln('    return BuildConfig(')
      ..writeln('      appId: app[\'id\'] as String? ?? \'default\',')
      ..writeln('      appName: app[\'name\'] as String? ?? \'App\',')
      ..writeln('      appDescription: app[\'description\'] as String? ?? \'\',')
      ..writeln('      appIconBytes: iconBytes,')
      ..writeln('      elementTexts: elementTexts,')
      ..writeln('      elementColors: elementColors,')
      ..writeln('      containerBackgrounds: containerBackgrounds,')
      ..writeln('      screenBackgrounds: screenBackgrounds,')
      ..writeln('      theme: m[\'theme\'] as Map<String, dynamic>? ?? {},')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static Color _parseColor(String hex) {')
      ..writeln('    hex = hex.replaceFirst(\'#\', \'\');')
      ..writeln('    if (hex.length == 6) hex = \'FF\$hex\';')
      ..writeln('    return Color(int.parse(hex, radix: 16));')
      ..writeln('  }')
      ..writeln()
      ..writeln('  String getText(String id, {String fallback = \'\'}) {')
      ..writeln('    return elementTexts[id] ?? fallback;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Color getElementColor(String id, {Color? fallback}) {')
      ..writeln('    return elementColors[id] ?? fallback ?? const Color(0xFF444444);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Color getContainerBg(String id, {Color? fallback}) {')
      ..writeln('    return containerBackgrounds[id] ?? fallback ?? const Color(0xFFF7F7F7);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Color getScreenBg(int index, {Color? fallback}) {')
      ..writeln('    return screenBackgrounds[index] ?? fallback ?? const Color(0xFFF7F7F7);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  /// Returns Image widget for the app icon, or fallback icon.')
      ..writeln('  Widget appIcon({double size = 48, Color? color}) {')
      ..writeln('    if (appIconBytes != null) {')
      ..writeln('      return Image.memory(appIconBytes!, width: size, height: size, fit: BoxFit.contain);')
      ..writeln('    }')
      ..writeln('    return Icon(Icons.account_circle, size: size, color: color ?? getElementColor(\'intro_icon\'));')
      ..writeln('  }')
      ..writeln()
      ..writeln('  /// Returns theme color from the theme block.')
      ..writeln('  Color getThemeColor(String key, {Color? fallback}) {')
      ..writeln('    try {')
      ..writeln('      final hex = _theme[key] as String?;')
      ..writeln('      if (hex != null && hex.isNotEmpty) {')
      ..writeln('        return Color(int.parse(hex.replaceFirst(\'#\', \'0xFF\'), radix: 16));')
      ..writeln('      }')
      ..writeln('    } catch (_) {}')
      ..writeln('    return fallback ?? const Color(0xFF6C0090);')
      ..writeln('  }')
      ..writeln('}');

    File(path).writeAsStringSync(buffer.toString());
  }

  // ---------------------------------------------------------------
  // Screen generation
  // ---------------------------------------------------------------
  void _generateScreen(String dir, Map<String, dynamic> screen) {
    final type = screen['type'] as String;
    final className = _screenClassName(type);
    final fileName = _screenFileName(type);
    final elements = screen['elements'] as Map<String, dynamic>? ?? {};

    // Intro, login, signup screens are generated as proper Dart files from templates
    if (type == 'intro') {
      _generateIntroScreen(dir, className, fileName, elements);
      return;
    }
    if (type == 'login') {
      _copyVtpassScreens(dir); // ensure dir exists
      File('$dir/$fileName').writeAsStringSync(_loginScreenDart);
      return;
    }
    if (type == 'signup') {
      _copyVtpassScreens(dir); // ensure dir exists
      File('$dir/$fileName').writeAsStringSync(_signupScreenDart);
      return;
    }

    final buffer = StringBuffer()
      ..writeln('import \'package:flutter/material.dart\';')
      ..writeln('import \'../config/build_config.dart\';');

    // Add VTPass screen imports for home screen
    if (type == 'home') {
      buffer
        ..writeln('import \'airtime_screen.dart\';')
        ..writeln('import \'data_screen.dart\';')
        ..writeln('import \'cable_tv_screen.dart\';')
        ..writeln('import \'electricity_screen.dart\';')
        ..writeln('import \'notifications_page.dart\';')
        ..writeln('import \'../service/auth_service.dart\';')
        ..writeln('import \'../service/user_repository.dart\';')
        ..writeln('import \'../service/notification_store.dart\';')
        ..writeln('import \'../service/monnify_service.dart\';')
        ..writeln('import \'../service/monnify_config.dart\';')
        ..writeln('import \'../service/app_tenant.dart\';')
        ..writeln('import \'package:cloud_firestore/cloud_firestore.dart\';');
    }

    // Add imports for profile screen
    if (type == 'profile') {
      buffer
        ..writeln('import \'../service/auth_service.dart\';')
        ..writeln('import \'../service/user_repository.dart\';')
        ..writeln('import \'personal_info_page.dart\';')
        ..writeln('import \'notifications_page.dart\';')
        ..writeln('import \'package:cloud_firestore/cloud_firestore.dart\';');
    }

    // Add imports for finance screen
    if (type == 'finance') {
      buffer
        ..writeln('import \'../service/auth_service.dart\';')
        ..writeln('import \'../service/user_repository.dart\';')
        ..writeln('import \'../service/vtpass_service.dart\';')
        ..writeln('import \'package:cloud_firestore/cloud_firestore.dart\';');
    }

    buffer
      ..writeln()
      ..writeln('class $className extends StatelessWidget {')
      ..writeln('  const $className({super.key});')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Widget build(BuildContext context) {')
      ..writeln('    final config = BuildConfig.load();')
      ..writeln()
      ..writeln('    return Scaffold(')
      ..writeln('      backgroundColor: config.getScreenBg(${_screenIndex(type)}),')
      ..writeln('      body: ${_buildScreenBody(type, elements)}')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      // Add helper methods for screens that need them
      ..writeln(_screenHelpers(type))
      ..writeln('}');

    // Ensure directory exists
    final screenDir = Directory(dir);
    if (!screenDir.existsSync()) screenDir.createSync(recursive: true);

    File('$dir/$fileName').writeAsStringSync(buffer.toString());
  }

  void _generateIntroScreen(String dir, String className, String fileName, Map<String, dynamic> elements) {
    final appName = app['name'] as String? ?? 'App';
    final title = _esc(elements['intro_title']?['text'] as String? ?? appName);
    final desc = _esc(elements['intro_description']?['text'] as String? ?? '');

    final buffer = StringBuffer()
      ..writeln('import \'dart:async\';')
      ..writeln('import \'package:flutter/material.dart\';')
      ..writeln('import \'../config/build_config.dart\';')
      ..writeln('import \'login_screen.dart\';')
      ..writeln('import \'signup_screen.dart\';')
      ..writeln()
      ..writeln('class $className extends StatefulWidget {')
      ..writeln('  const $className({super.key});')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  State<$className> createState() => _${className}State();')
      ..writeln('}')
      ..writeln()
      ..writeln('class _${className}State extends State<$className> {')
      ..writeln('  @override')
      ..writeln('  void initState() {')
      ..writeln('    super.initState();')
      ..writeln('    Timer(const Duration(seconds: 5), () {')
      ..writeln('      if (mounted) {')
      ..writeln('        Navigator.pushReplacement(')
      ..writeln('          context,')
      ..writeln('          MaterialPageRoute(builder: (_) => const LoginScreen()),')
      ..writeln('        );')
      ..writeln('      }')
      ..writeln('    });')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Widget build(BuildContext context) {')
      ..writeln('    final config = BuildConfig.load();')
      ..writeln()
      ..writeln('    return Scaffold(')
      ..writeln('      backgroundColor: config.getScreenBg(0),')
      ..writeln('      body: SafeArea(')
      ..writeln('        child: Center(')
      ..writeln('          child: Padding(')
      ..writeln('            padding: const EdgeInsets.symmetric(horizontal: 24),')
      ..writeln('            child: Column(')
      ..writeln('              mainAxisAlignment: MainAxisAlignment.center,')
      ..writeln('              children: [')
      ..writeln('                Container(')
      ..writeln('                  width: 80, height: 80,')
      ..writeln('                  decoration: BoxDecoration(')
      ..writeln('                    color: Colors.white,')
      ..writeln('                    borderRadius: BorderRadius.circular(20),')
      ..writeln('                    border: Border.all(color: const Color(0xFFE0E0E0)),')
      ..writeln('                  ),')
      ..writeln('                  child: config.appIconBytes != null')
      ..writeln('                      ? ClipRRect(')
      ..writeln('                          borderRadius: BorderRadius.circular(20),')
      ..writeln('                          child: Image.memory(config.appIconBytes!, width: 80, height: 80, fit: BoxFit.cover),')
      ..writeln('                        )')
      ..writeln('                      : const Icon(Icons.image_outlined, size: 36, color: Color(0xFFB0B0B0)),')
      ..writeln('                ),')
      ..writeln('                const SizedBox(height: 20),')
      ..writeln('                Text(')
      ..writeln('                  \'$title\',')
      ..writeln('                  textAlign: TextAlign.center,')
      ..writeln('                  style: TextStyle(')
      ..writeln('                    fontFamily: \'DMSans\', fontSize: 20, fontWeight: FontWeight.w600,')
      ..writeln('                    color: config.getElementColor(\'intro_title\'),')
      ..writeln('                  ),')
      ..writeln('                ),')
      ..writeln('                const SizedBox(height: 8),')
      ..writeln('                Text(')
      ..writeln('                  \'$desc\',')
      ..writeln('                  textAlign: TextAlign.center,')
      ..writeln('                  style: TextStyle(')
      ..writeln('                    fontFamily: \'DMSans\', fontSize: 14,')
      ..writeln('                    color: config.getElementColor(\'intro_description\', fallback: const Color(0xFFAAAAAA)),')
      ..writeln('                  ),')
      ..writeln('                ),')
      ..writeln('                const SizedBox(height: 40),')
      ..writeln('                const CircularProgressIndicator(')
      ..writeln('                  strokeWidth: 2,')
      ..writeln('                  color: Color(0xFF666666),')
      ..writeln('                ),')
      ..writeln('                const SizedBox(height: 12),')
      ..writeln('                Text(')
      ..writeln('                  \'Loading...\',')
      ..writeln('                  style: TextStyle(fontFamily: \'DMSans\', fontSize: 13, color: Color(0xFFAAAAAA)),')
      ..writeln('                ),')
      ..writeln('              ],')
      ..writeln('            ),')
      ..writeln('          ),')
      ..writeln('        ),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');

    final screenDir = Directory(dir);
    if (!screenDir.existsSync()) screenDir.createSync(recursive: true);
    File('$dir/$fileName').writeAsStringSync(buffer.toString());
  }

  String _screenHelpers(String type) {
    switch (type) {
      case 'home':
        return '''
  Widget _serviceItem(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF555555)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF555555))),
          ],
        ),
      ),
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF999999))),
          Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        ],
      ),
    );
  }''';
      case 'profile':
        return '''
  Widget _menuItem(IconData icon, String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF555555)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF333333))),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }''';
      default:
        return '';
    }
  }

  String _buildScreenBody(String type, Map<String, dynamic> elements) {
    switch (type) {
      case 'intro':
        return _buildIntroBody(elements);
      case 'home':
        return _buildHomeBody(elements);
      case 'finance':
        return _buildFinanceBody(elements);
      case 'profile':
        return _buildProfileBody(elements);
      default:
        return 'Center(child: Text(\'${type}Screen\'))';
    }
  }

  String _buildIntroBody(Map<String, dynamic> elements) {
    // Return a placeholder — the actual intro is generated as a StatefulWidget in _generateScreen
    return 'const SizedBox()';
  }

  String _buildHomeBody(Map<String, dynamic> elements) {
    return '''StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserRepository.instance.watchUser(AuthService().currentUser?.uid ?? ''),
        builder: (context, snap) {
          final data = snap.data?.data();
          final username = (data?['username'] as String?)?.trim();
          final displayName = (data?['displayName'] as String?)?.trim();
          final name = (username?.isNotEmpty == true ? username : displayName) ?? 'User';
          final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(radius: 20, backgroundColor: const Color(0xFFE5E5E5),
                    child: Text(initials, style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF777777)))),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hello again', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Color(0xFFAAAAAA))),
                    const SizedBox(height: 2),
                    Text(name, style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  ]),
                  const Spacer(),
                  StreamBuilder<int>(
                    stream: NotificationStore.watchUnreadCount(AuthService().currentUser?.uid ?? ''),
                    builder: (context, snap) {
                      final count = snap.data ?? 0;
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
                        child: Stack(
                          children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8E8E8)),
                              ),
                              child: Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF555555)),
                            ),
                            if (count > 0)
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: config.getThemeColor('primaryColor'),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(count > 9 ? '9+' : '\x24count',
                                    style: TextStyle(fontFamily: 'DMSans', fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 18),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: UserRepository.instance.watchUser(AuthService().currentUser?.uid ?? ''),
                  builder: (context, userSnap) {
                    final userData = userSnap.data?.data();
                    final primaryAcct = userData?['primaryVirtualAccount'] as Map<String, dynamic>?;
                    final accountNo = (primaryAcct?['accountNumber'] as String?) ?? '';
                    final bankName = (primaryAcct?['bankName'] as String?) ?? '';
                    final acctRef = (primaryAcct?['accountReference'] as String?) ?? '';
                    final hasAccount = userData?['hasVirtualAccount'] == true && accountNo.isNotEmpty;

                    if (!hasAccount) {
                      return GestureDetector(
                        onTap: () async {
                          final user = AuthService().currentUser;
                          if (user == null) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Setting up your virtual account...'), duration: Duration(seconds: 2)));
                          try {
                            if (!MonnifyConfig.isConfigured) await MonnifyConfig.ensureConfigured();
                            print('[Home] MonnifyConfig.isConfigured=\x24{MonnifyConfig.isConfigured}');
                            print('[Home] \x24{MonnifyConfig.debugStatus}');
                            if (MonnifyConfig.isConfigured) {
                              await MonnifyService.instance.createReservedAccount();
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Account created!'), backgroundColor: Color(0xFF4CAF50)));
                            } else {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Monnify not configured. Check Firestore config/monnify doc.')));
                            }
                          } catch (e) {
                            print('[Home] Monnify creation FAILED: \x24e');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: \x24e'), duration: Duration(seconds: 8)));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: config.getContainerBg('home_wallet', fallback: const Color(0xFF595858)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.white70),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Tap to set up your virtual account', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: Colors.white70))),
                            Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white54),
                          ]),
                        ),
                      );
                    }

                    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: AppTenant.current.monnifyReservedAccounts.doc(acctRef).snapshots(),
                      builder: (context, acctSnap) {
                        final acctData = acctSnap.data?.data();
                        final totalReceived = (acctData?['totalReceived'] as num?)?.toDouble() ?? 0.0;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: config.getContainerBg('home_wallet', fallback: const Color(0xFF595858)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text('Account No : \x24accountNo', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, color: config.getElementColor('home_wallet', fallback: const Color(0xFFAAAAAA)))),
                              if (bankName.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text('(\x24bankName)', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: config.getElementColor('home_wallet', fallback: const Color(0xFF999999)))),
                              ],
                            ]),
                            const SizedBox(height: 5),
                            Text('\\u20A6\x24{totalReceived.toStringAsFixed(2)}',
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w700,
                                color: config.getElementColor('home_wallet_amount', fallback: Colors.white))),
                            const SizedBox(height: 1),
                            Text('Available Balance', style: TextStyle(fontFamily: 'DMSans', fontSize: 11,
                              color: config.getElementColor('home_wallet', fallback: const Color(0xFFAAAAAA)))),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(context: context, isScrollControlled: true,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                                  builder: (ctx) => DraggableScrollableSheet(
                                    initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8, expand: false,
                                    builder: (ctx, scrollCtrl) => SingleChildScrollView(controller: scrollCtrl, padding: const EdgeInsets.all(20),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
                                        const SizedBox(height: 20),
                                        Text('Add Money', style: TextStyle(fontFamily: 'DMSans', fontSize: 16, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Text('Transfer to this account from your bank app', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF999999))),
                                        const SizedBox(height: 20),
                                        _bankInfoRow('Bank Name', bankName),
                                        _bankInfoRow('Account Number', accountNo),
                                        _bankInfoRow('Account Name', (primaryAcct?['accountName'] as String?) ?? ''),
                                        const SizedBox(height: 20),
                                        SizedBox(width: double.infinity, height: 46,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account number copied')));
                                              Navigator.pop(ctx);
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: config.getThemeColor('primaryColor'), foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                            child: Text('Copy Account Number', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600)),
                                          )),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: config.getContainerBg('home_wallet_button', fallback: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.add_circle_outline_rounded, size: 16,
                                    color: config.getElementColor('home_wallet_button_text', fallback: const Color(0xFF2E2E2E))),
                                  const SizedBox(width: 4),
                                  Text('Add money', style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w600,
                                    color: config.getElementColor('home_wallet_button_text', fallback: const Color(0xFF2E2E2E)))),
                                ]),
                              ),
                            ),
                          ]),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(config.getText('home_services_title', fallback: 'Services'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600, color: config.getElementColor('home_services_title', fallback: const Color(0xFF444444)))),
                const SizedBox(height: 16),
                GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 12,
                  children: [
                    _serviceItem(Icons.phone_android_rounded, 'Airtime', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AirtimeScreen()))),
                    _serviceItem(Icons.wifi_rounded, 'Data', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataScreen()))),
                    _serviceItem(Icons.bolt_rounded, 'Electricity', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricityScreen()))),
                    _serviceItem(Icons.tv_rounded, 'Cable TV', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CableTvScreen()))),
                    _serviceItem(Icons.school_rounded, 'Education', null),
                    _serviceItem(Icons.sports_soccer_rounded, 'Betting', null),
                    _serviceItem(Icons.water_drop_rounded, 'Water', null),
                    _serviceItem(Icons.more_horiz_rounded, 'More', null),
                  ]),
              ],
            ),
          );
        },
      )''';
  }

  String _buildFinanceBody(Map<String, dynamic> elements) {
    return '''StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserRepository.instance.watchUser(AuthService().currentUser?.uid ?? ''),
        builder: (context, snap) {
          final data = snap.data?.data();
          final username = (data?['username'] as String?)?.trim();
          final displayName = (data?['displayName'] as String?)?.trim();
          final name = (username?.isNotEmpty == true ? username : displayName) ?? 'User';
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.getText('finance_heading', fallback: 'Finance'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w700, color: config.getElementColor('finance_heading', fallback: const Color(0xFF333333)))),
                const SizedBox(height: 4),
                Text(config.getText('finance_subtitle', fallback: 'Track your balance and spending'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: config.getElementColor('finance_subtitle', fallback: const Color(0xFFAAAAAA)))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E5))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.account_balance_wallet_rounded, size: 18, color: config.getElementColor('finance_summary', fallback: const Color(0xFF777777))),
                      const SizedBox(height: 10),
                      Text('\\u20A60.00', style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: config.getElementColor('finance_summary', fallback: const Color(0xFF333333)))),
                      const SizedBox(height: 2),
                      Text('Balance', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: config.getElementColor('finance_summary', fallback: const Color(0xFFAAAAAA)))),
                    ]),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5E5))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.trending_down_rounded, size: 18, color: config.getElementColor('finance_summary', fallback: const Color(0xFF777777))),
                      const SizedBox(height: 10),
                      Text('\\u20A60.00', style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: config.getElementColor('finance_summary', fallback: const Color(0xFF333333)))),
                      const SizedBox(height: 2),
                      Text('This Month', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: config.getElementColor('finance_summary', fallback: const Color(0xFFAAAAAA)))),
                    ]),
                  )),
                ]),
                const SizedBox(height: 20),
                Text(config.getText('finance_plan_title', fallback: 'Current Plan'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600, color: config.getElementColor('finance_plan_title', fallback: const Color(0xFF444444)))),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: config.getContainerBg('finance_plan_card', fallback: const Color(0xFF595858)),
                    borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('No Active Plan', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: config.getElementColor('finance_plan_card', fallback: Colors.white))),
                      const SizedBox(height: 4),
                      Text('Subscribe to a data or cable plan', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: config.getElementColor('finance_plan_card', fallback: const Color(0xFFAAAAAA)))),
                      const SizedBox(height: 8),
                      Text('Renews: \\u2014', style: TextStyle(fontFamily: 'DMSans', fontSize: 9, color: config.getElementColor('finance_plan_card', fallback: const Color(0xFF999999)))),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('Manage', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: config.getElementColor('finance_plan_card_button_text', fallback: const Color(0xFF2E2E2E)))),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                Text(config.getText('finance_transactions_title', fallback: 'Recent Transactions'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600, color: config.getElementColor('finance_transactions_title', fallback: const Color(0xFF444444)))),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: VtpassService.instance.watchTransactions(uid: AuthService().currentUser?.uid, limit: 10),
                  builder: (context, txSnap) {
                    final docs = txSnap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E5E5))),
                        child: Column(children: [
                          Icon(Icons.receipt_long_rounded, size: 28, color: Color(0xFFCCCCCC)),
                          const SizedBox(height: 8),
                          Text('No transactions yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF999999))),
                        ]),
                      );
                    }
                    return Column(
                      children: docs.map((doc) {
                        final d = doc.data();
                        final type = (d['type'] ?? '') as String;
                        final status = (d['status'] ?? 'pending') as String;
                        final amount = d['amount'];
                        final serviceID = (d['serviceID'] ?? '') as String;
                        final createdAt = d['createdAt'];
                        String title;
                        IconData icon;
                        switch (type) {
                          case 'airtime': title = 'Airtime Purchase'; icon = Icons.phone_android_rounded; break;
                          case 'data': title = 'Data Purchase'; icon = Icons.wifi_rounded; break;
                          case 'tv': title = 'Cable TV'; icon = Icons.tv_rounded; break;
                          case 'electricity': title = 'Electricity'; icon = Icons.bolt_rounded; break;
                          default: title = serviceID.isNotEmpty ? serviceID.toUpperCase() : 'Purchase'; icon = Icons.receipt_rounded;
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E8E8))),
                          child: Row(children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: status == 'delivered'
                                    ? const Color(0xFF00A651).withOpacity(0.1)
                                    : const Color(0xFFFFCC00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, size: 16,
                                color: status == 'delivered' ? const Color(0xFF00A651) : const Color(0xFFCC8800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(title, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                              const SizedBox(height: 2),
                              Text(status.toUpperCase(), style: TextStyle(fontFamily: 'DMSans', fontSize: 10,
                                color: status == 'delivered' ? Color(0xFF00A651) : Color(0xFFCC8800))),
                            ])),
                            Text(amount != null ? '\\u20A6\x24amount' : '--',
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                          ]),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      )''';
  }

  String _buildProfileBody(Map<String, dynamic> elements) {
    return '''StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserRepository.instance.watchUser(AuthService().currentUser?.uid ?? ''),
        builder: (context, snap) {
          final data = snap.data?.data();
          final username = (data?['username'] as String?)?.trim();
          final displayName = (data?['displayName'] as String?)?.trim();
          final phone = (data?['phone'] as String?)?.trim() ?? '';
          final name = (username?.isNotEmpty == true ? username : displayName) ?? 'User';
          final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.getText('profile_heading', fallback: 'Profile'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 20, fontWeight: FontWeight.w700, color: config.getElementColor('profile_heading', fallback: const Color(0xFF333333)))),
                const SizedBox(height: 24),
                Center(child: Column(children: [
                  CircleAvatar(radius: 32, backgroundColor: const Color(0xFFE5E5E5),
                    child: Text(initials, style: TextStyle(fontFamily: 'DMSans', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF777777)))),
                  const SizedBox(height: 10),
                  Text(name, style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  if (phone.isNotEmpty)
                    Text(phone, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFFAAAAAA))),
                ])),
                const SizedBox(height: 28),
                _menuItem(Icons.person_outline_rounded, 'Personal Information', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoPage()))),
                _menuItem(Icons.credit_card_rounded, 'Payment Methods', () {}),
                _menuItem(Icons.lock_outline_rounded, 'Security', () {}),
                _menuItem(Icons.notifications_none_rounded, 'Notifications', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
                _menuItem(Icons.help_outline_rounded, 'Help & Support', () {}),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign out?'),
                        content: const Text('You will be returned to the login screen.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await AuthService().signOut();
                      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(children: [
                      Icon(Icons.logout_rounded, size: 20, color: Color(0xFFE53935)),
                      const SizedBox(width: 12),
                      Text('Sign Out', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFFE53935))),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      )''';
  }

  // ---------------------------------------------------------------
  // Firebase options (template)
  // ---------------------------------------------------------------
  void _generateFirebaseOptions(String path) {
    final projectId = firebase['projectId'] as String? ?? 'your-project-id';
    final storageBucket = firebase['storageBucket'] as String? ?? 'your-project.appspot.com';
    final appId = firebase['appId'] as String? ?? '1:000000000000:android:0000000000000000';
    final messagingSenderId = firebase['projectNumber'] as String? ?? '000000000000';
    final apiKey = firebase['apiKey'] as String? ?? 'AIzaSyD placeholder';

    final buffer = StringBuffer()
      ..writeln('import \'package:firebase_core/firebase_core.dart\' show FirebaseOptions;')
      ..writeln('import \'package:flutter/foundation.dart\'')
      ..writeln('    show defaultTargetPlatform, TargetPlatform;')
      ..writeln()
      ..writeln('class DefaultFirebaseOptions {')
      ..writeln('  static FirebaseOptions get currentPlatform {')
      ..writeln('    switch (defaultTargetPlatform) {')
      ..writeln('      case TargetPlatform.android:')
      ..writeln('        return android;')
      ..writeln('      default:')
      ..writeln('        throw UnsupportedError(')
      ..writeln('          \'DefaultFirebaseOptions are not supported for this platform.\',')
      ..writeln('        );')
      ..writeln('    }')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static const FirebaseOptions android = FirebaseOptions(')
      ..writeln('    apiKey: \'$apiKey\',')
      ..writeln('    appId: \'$appId\',')
      ..writeln('    messagingSenderId: \'$messagingSenderId\',')
      ..writeln('    projectId: \'$projectId\',')
      ..writeln('    storageBucket: \'$storageBucket\',')
      ..writeln('  );')
      ..writeln('}');

    File(path).writeAsStringSync(buffer.toString());
  }

  // ---------------------------------------------------------------
  // Android files
  // ---------------------------------------------------------------
  void _generateAndroidManifest(String path) {
    final appName = app['name'] as String? ?? 'My App';
    final fcmChannel = app['fcmChannel'] as String? ?? 'default_channel';

    final buffer = StringBuffer()
      ..writeln('<manifest xmlns:android="http://schemas.android.com/apk/res/android">')
      ..writeln('    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />')
      ..writeln('    <application')
      ..writeln('        android:label="$appName"')
      ..writeln('        android:name="\${applicationName}"')
      ..writeln('        android:icon="@mipmap/ic_launcher">')
      ..writeln('        <activity')
      ..writeln('            android:name=".MainActivity"')
      ..writeln('            android:exported="true"')
      ..writeln('            android:launchMode="singleTop"')
      ..writeln('            android:taskAffinity=""')
      ..writeln('            android:theme="@style/LaunchTheme"')
      ..writeln('            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"')
      ..writeln('            android:hardwareAccelerated="true"')
      ..writeln('            android:windowSoftInputMode="adjustResize">')
      ..writeln('            <meta-data')
      ..writeln('              android:name="io.flutter.embedding.android.NormalTheme"')
      ..writeln('              android:resource="@style/NormalTheme"')
      ..writeln('            />')
      ..writeln('            <intent-filter>')
      ..writeln('                <action android:name="android.intent.action.MAIN"/>')
      ..writeln('                <category android:name="android.intent.category.LAUNCHER"/>')
      ..writeln('            </intent-filter>')
      ..writeln('        </activity>')
      ..writeln('        <meta-data')
      ..writeln('            android:name="com.google.firebase.messaging.default_notification_channel_id"')
      ..writeln('            android:value="$fcmChannel" />')
      ..writeln('        <meta-data')
      ..writeln('            android:name="flutterEmbedding"')
      ..writeln('            android:value="2" />')
      ..writeln('    </application>')
      ..writeln('    <queries>')
      ..writeln('        <intent>')
      ..writeln('            <action android:name="android.intent.action.PROCESS_TEXT"/>')
      ..writeln('            <data android:mimeType="text/plain"/>')
      ..writeln('        </intent>')
      ..writeln('    </queries>')
      ..writeln('</manifest>');

    File(path).writeAsStringSync(buffer.toString());
  }

  void _generateBuildGradle(String path) {
    final packageName = app['packageName'] as String? ?? 'com.example.myapp';
    final versionCode = app['versionCode'] as int? ?? 1;
    final versionName = app['version'] as String? ?? '1.0.0';

    final buffer = StringBuffer()
      ..writeln('plugins {')
      ..writeln('    id("com.android.application")')
      ..writeln('    id("com.google.gms.google-services")')
      ..writeln('    id("dev.flutter.flutter-gradle-plugin")')
      ..writeln('}')
      ..writeln()
      ..writeln('android {')
      ..writeln('    namespace = "$packageName"')
      ..writeln('    compileSdk = flutter.compileSdkVersion')
      ..writeln('    ndkVersion = flutter.ndkVersion')
      ..writeln()
      ..writeln('    compileOptions {')
      ..writeln('        isCoreLibraryDesugaringEnabled = true')
      ..writeln('        sourceCompatibility = JavaVersion.VERSION_17')
      ..writeln('        targetCompatibility = JavaVersion.VERSION_17')
      ..writeln('    }')
      ..writeln()
      ..writeln('    defaultConfig {')
      ..writeln('        applicationId = "$packageName"')
      ..writeln('        minSdk = flutter.minSdkVersion')
      ..writeln('        targetSdk = flutter.targetSdkVersion')
      ..writeln('        versionCode = $versionCode')
      ..writeln('        versionName = "$versionName"')
      ..writeln('    }')
      ..writeln()
      ..writeln('    buildTypes {')
      ..writeln('        release {')
      ..writeln('            signingConfig = signingConfigs.getByName("debug")')
      ..writeln('        }')
      ..writeln('    }')
      ..writeln('}')
      ..writeln()
      ..writeln('kotlin {')
      ..writeln('    compilerOptions {')
      ..writeln('        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17')
      ..writeln('    }')
      ..writeln('}')
      ..writeln()
      ..writeln('flutter {')
      ..writeln('    source = "../.."')
      ..writeln('}')
      ..writeln()
      ..writeln('dependencies {')
      ..writeln('    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")')
      ..writeln('}');

    File(path).writeAsStringSync(buffer.toString());
  }

  void _generateSettingsGradle(String path) {
    final buffer = StringBuffer()
      ..writeln('pluginManagement {')
      ..writeln('    val flutterSdkPath =')
      ..writeln('        run {')
      ..writeln('            val properties = java.util.Properties()')
      ..writeln('            file("local.properties").inputStream().use { properties.load(it) }')
      ..writeln('            val flutterSdkPath = properties.getProperty("flutter.sdk")')
      ..writeln('            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }')
      ..writeln('            flutterSdkPath')
      ..writeln('        }')
      ..writeln()
      ..writeln('    includeBuild("\$flutterSdkPath/packages/flutter_tools/gradle")')
      ..writeln()
      ..writeln('    repositories {')
      ..writeln('        google()')
      ..writeln('        mavenCentral()')
      ..writeln('        gradlePluginPortal()')
      ..writeln('    }')
      ..writeln('}')
      ..writeln()
      ..writeln('plugins {')
      ..writeln('    id("dev.flutter.flutter-plugin-loader") version "1.0.0"')
      ..writeln('    id("com.android.application") version "9.0.1" apply false')
      ..writeln('    id("com.google.gms.google-services") version("4.4.4") apply false')
      ..writeln('    id("org.jetbrains.kotlin.android") version "2.3.20" apply false')
      ..writeln('}')
      ..writeln()
      ..writeln('include(":app")');

    File(path).writeAsStringSync(buffer.toString());
  }

  void _generateMainActivity(String kotlinDir) {
    final packageName = app['packageName'] as String? ?? 'com.example.myapp';
    final packagePath = packageName.replaceAll('.', '/');

    final dir = Directory('$kotlinDir/$packagePath');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final buffer = StringBuffer()
      ..writeln('package $packageName')
      ..writeln()
      ..writeln('import io.flutter.embedding.android.FlutterActivity')
      ..writeln()
      ..writeln('class MainActivity : FlutterActivity()');

    File('${dir.path}/MainActivity.kt').writeAsStringSync(buffer.toString());
  }

  void _generateGoogleServices(String path) {
    final projectId = firebase['projectId'] as String? ?? 'your-project-id';
    final projectNumber = firebase['projectNumber'] as String? ?? '000000000000';
    final storageBucket = firebase['storageBucket'] as String? ?? 'your-project.appspot.com';
    final appId = firebase['appId'] as String? ?? '1:000000000000:android:0000000000000000';
    final packageName = app['packageName'] as String? ?? 'com.example.myapp';
    final apiKey = firebase['apiKey'] as String? ?? 'AIzaSyD placeholder';

    final map = {
      'project_info': {
        'project_number': projectNumber,
        'project_id': projectId,
        'storage_bucket': storageBucket,
      },
      'client': [
        {
          'client_info': {
            'mobilesdk_app_id': appId,
            'android_client_info': {'package_name': packageName},
          },
          'api_key': [
            {'current_key': apiKey},
          ],
          'services': {
            'appinvite_service': {
              'other_platform_oauth_client': [],
            },
          },
        },
      ],
      'configuration_version': '1',
    };

    File(path).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(map),
    );
  }

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------
  String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _screenClassName(String type) {
    final map = {
      'intro': 'IntroScreen',
      'login': 'LoginScreen',
      'signup': 'SignupScreen',
      'home': 'HomeScreen',
      'finance': 'FinanceScreen',
      'profile': 'ProfileScreen',
    };
    return map[type] ?? '${type[0].toUpperCase()}${type.substring(1)}Screen';
  }

  String _screenFileName(String type) {
    return '${type}_screen.dart';
  }

  int _screenIndex(String type) {
    const map = {
      'intro': 0,
      'login': 1,
      'signup': 2,
      'home': 3,
      'finance': 4,
      'profile': 5,
    };
    return map[type] ?? 0;
  }

  String _tabIcon(String tab) {
    const map = {
      'home': 'Icons.home_rounded',
      'finance': 'Icons.account_balance_wallet',
      'profile': 'Icons.person',
    };
    return map[tab] ?? 'Icons.circle';
  }

  String _esc(String s) => s.replaceAll("'", "\\'");

  static const _loginScreenDart = r'''
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/build_config.dart';
import '../service/auth_service.dart';
import '../service/user_repository.dart';
import '../service/app_notifications.dart';
import '../service/push_notification_service.dart';
import '../service/monnify_service.dart';
import '../service/monnify_config.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await _auth.signIn(email: email, password: pass);
      await UserRepository.instance.ensureUserDoc(cred.user!);
      try { await AppNotifications.loginSuccess(user: cred.user!); } catch (_) {}
      try { await PushNotificationService.instance.ensurePermissionAndToken(); } catch (_) {}
      try { await AppNotifications.ensureSubscriptions(user: cred.user!); } catch (_) {}
      // Auto-create Monnify virtual account if needed
      try {
        final existing = await MonnifyService.instance.getUserAccountsOnce(cred.user!.uid);
        if (existing.docs.isEmpty) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Setting up your virtual account...'), backgroundColor: config.getThemeColor('primaryColor'), duration: const Duration(seconds: 3)),
          );
          if (!MonnifyConfig.isConfigured) await MonnifyConfig.ensureConfigured();
          if (MonnifyConfig.isConfigured) {
            final doc = await MonnifyService.instance.createReservedAccount(getAllAvailableBanks: true);
            if (mounted) {
              final bank = (doc['primaryBankName'] ?? 'your bank').toString();
              final acct = (doc['primaryAccountNumber'] ?? '').toString();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(acct.isEmpty ? 'Virtual account ready at $bank' : 'Virtual account ready: $bank \u2022 $acct'), backgroundColor: config.getThemeColor('primaryColor')),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Auto virtual account failed: $e');
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message ?? 'Login failed'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Login failed: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();
    return Scaffold(
      backgroundColor: config.getScreenBg(1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: config.appIconBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(config.appIconBytes!, width: 32, height: 32, fit: BoxFit.cover),
                          )
                        : Icon(Icons.apps_rounded, size: 18, color: Color(0xFFB0B0B0)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    config.appName,
                    style: TextStyle(
                      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600,
                      color: config.getElementColor('intro_title', fallback: const Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(config.getText('login_heading', fallback: 'Login'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700,
                  color: config.getElementColor('login_heading', fallback: const Color(0xFF333333)))),
              const SizedBox(height: 4),
              Text(config.getText('login_subtitle', fallback: 'Welcome back, please sign in'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 13,
                  color: config.getElementColor('login_subtitle', fallback: const Color(0xFFAAAAAA)))),
              const SizedBox(height: 28),
              _buildField('Email', 'you@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, elementId: 'login_email'),
              const SizedBox(height: 16),
              _buildField('Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _passCtrl, obscure: true, elementId: 'login_password'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(config.getText('login_forgot', fallback: 'Forgot password?'),
                  style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w500,
                    color: config.getElementColor('login_forgot', fallback: const Color(0xFFB0B0B0)))),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _login,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _loading
                          ? const Color(0xFFCCCCCC)
                          : config.getContainerBg('login_button', fallback: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              config.getText('login_button', fallback: 'Log In'),
                              style: TextStyle(
                                fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600,
                                color: config.getElementColor('login_button', fallback: const Color(0xFF666666)),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  child: Text(
                    config.getText('login_signup', fallback: "Don't have an account? Sign up"),
                    style: TextStyle(
                      fontFamily: 'DMSans', fontSize: 11,
                      color: config.getElementColor('login_signup', fallback: const Color(0xFFAAAAAA)),
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

  Widget _buildField(String label, String hint, {TextEditingController? controller, bool obscure = false, TextInputType? keyboardType, String? elementId}) {
    final labelColor = elementId != null ? config.getElementColor('${elementId}_label', fallback: const Color(0xFF888888)) : const Color(0xFF888888);
    final bgColor = elementId != null ? config.getContainerBg(elementId, fallback: Colors.white) : Colors.white;
    final borderColor = elementId != null ? config.getContainerBg('${elementId}_border', fallback: const Color(0xFFE0E0E0)) : const Color(0xFFE0E0E0);
    final hintColor = elementId != null ? config.getElementColor('${elementId}_hint', fallback: const Color(0xFFC0C0C0)) : const Color(0xFFC0C0C0);
    final displayLabel = elementId != null ? config.getText('${elementId}_label', fallback: label) : label;
    final displayHint = elementId != null ? config.getText('${elementId}_hint', fallback: hint) : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayLabel, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: labelColor)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: displayHint,
            hintStyle: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: hintColor),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: TextStyle(fontFamily: 'DMSans', fontSize: 13),
        ),
      ],
    );
  }
}
''';

  static const _signupScreenDart = r'''
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/build_config.dart';
import '../service/auth_service.dart';
import '../service/user_repository.dart';
import '../service/app_notifications.dart';
import '../service/push_notification_service.dart';
import '../service/monnify_service.dart';
import '../service/monnify_config.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (username.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await _auth.signUp(email: email, password: pass);
      await UserRepository.instance.saveEmailUser(
        user: cred.user!,
        username: username,
        phone: '',
      );
      try { await AppNotifications.welcomeFirstTime(user: cred.user!, fallbackName: username); } catch (_) {}
      try { await PushNotificationService.instance.ensurePermissionAndToken(); } catch (_) {}
      try { await AppNotifications.ensureSubscriptions(user: cred.user!); } catch (_) {}
      // Auto-create Monnify virtual account
      try {
        final existing = await MonnifyService.instance.getUserAccountsOnce(cred.user!.uid);
        if (existing.docs.isEmpty) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Virtual account is being created...'), backgroundColor: config.getThemeColor('primaryColor'), duration: const Duration(seconds: 3)),
          );
          if (!MonnifyConfig.isConfigured) await MonnifyConfig.ensureConfigured();
          if (MonnifyConfig.isConfigured) {
            final doc = await MonnifyService.instance.createReservedAccount(getAllAvailableBanks: true);
            if (mounted) {
              final bank = (doc['primaryBankName'] ?? 'your bank').toString();
              final acct = (doc['primaryAccountNumber'] ?? '').toString();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(acct.isEmpty ? 'Virtual account ready at $bank' : 'Virtual account ready: $bank \u2022 $acct'), backgroundColor: config.getThemeColor('primaryColor')),
              );
            }
          }
        }
      } catch (e) {
        print('[Signup] Auto virtual account FAILED: \x24e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Virtual account failed: \x24e'), backgroundColor: Colors.orange.shade700, duration: Duration(seconds: 6)),
        );
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message ?? 'Signup failed'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Signup failed: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = BuildConfig.load();
    return Scaffold(
      backgroundColor: config.getScreenBg(2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: config.appIconBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(config.appIconBytes!, width: 32, height: 32, fit: BoxFit.cover),
                          )
                        : Icon(Icons.apps_rounded, size: 18, color: Color(0xFFB0B0B0)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    config.appName,
                    style: TextStyle(
                      fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w600,
                      color: config.getElementColor('intro_title', fallback: const Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(config.getText('signup_heading', fallback: 'Create Account'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 22, fontWeight: FontWeight.w700,
                  color: config.getElementColor('signup_heading', fallback: const Color(0xFF333333)))),
              const SizedBox(height: 4),
              Text(config.getText('signup_subtitle', fallback: 'Join us today'),
                style: TextStyle(fontFamily: 'DMSans', fontSize: 13,
                  color: config.getElementColor('signup_subtitle', fallback: const Color(0xFFAAAAAA)))),
              const SizedBox(height: 28),
              _buildField('Username', 'e.g. John', controller: _usernameCtrl, elementId: 'signup_username'),
              const SizedBox(height: 16),
              _buildField('Email', 'you@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, elementId: 'signup_email'),
              const SizedBox(height: 16),
              _buildField('Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _passCtrl, obscure: true, elementId: 'signup_password'),
              const SizedBox(height: 16),
              _buildField('Confirm Password', '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', controller: _confirmCtrl, obscure: true, elementId: 'signup_confirm'),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _signup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _loading
                          ? const Color(0xFFCCCCCC)
                          : config.getContainerBg('signup_button', fallback: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              config.getText('signup_button', fallback: 'Create Account'),
                              style: TextStyle(
                                fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600,
                                color: config.getElementColor('signup_button', fallback: const Color(0xFF666666)),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text(
                    config.getText('signup_login', fallback: 'Already have an account? Sign in'),
                    style: TextStyle(
                      fontFamily: 'DMSans', fontSize: 11,
                      color: config.getElementColor('signup_login', fallback: const Color(0xFFAAAAAA)),
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

  Widget _buildField(String label, String hint, {TextEditingController? controller, bool obscure = false, TextInputType? keyboardType, String? elementId}) {
    final labelColor = elementId != null ? config.getElementColor('${elementId}_label', fallback: const Color(0xFF888888)) : const Color(0xFF888888);
    final bgColor = elementId != null ? config.getContainerBg(elementId, fallback: Colors.white) : Colors.white;
    final borderColor = elementId != null ? config.getContainerBg('${elementId}_border', fallback: const Color(0xFFE0E0E0)) : const Color(0xFFE0E0E0);
    final hintColor = elementId != null ? config.getElementColor('${elementId}_hint', fallback: const Color(0xFFC0C0C0)) : const Color(0xFFC0C0C0);
    final displayLabel = elementId != null ? config.getText('${elementId}_label', fallback: label) : label;
    final displayHint = elementId != null ? config.getText('${elementId}_hint', fallback: hint) : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayLabel, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, color: labelColor)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: displayHint,
            hintStyle: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: hintColor),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: TextStyle(fontFamily: 'DMSans', fontSize: 13),
        ),
      ],
    );
  }
}
''';
}
