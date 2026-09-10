import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Regentspace Build Server
///
/// Endpoints:
///   GET  /health        — Health check
///   POST /build         — Submit build JSON, start APK build
///   GET  /status/{id}   — Check build status
///   POST /cancel/{id}   — Cancel a running build
///   GET  /download/{id} — Download completed APK

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final serverDir = Directory.current;
  final builderDir = Directory(p.join(serverDir.path, '..'));
  final buildScript = File(p.join(builderDir.path, 'build.sh'));

  if (!buildScript.existsSync()) {
    stderr.writeln('[FATAL] build.sh not found at ${buildScript.path}');
    exit(1);
  }

  // Clean up old build artifacts on startup
  final buildsDir = Directory(p.join(builderDir.path, 'builds'));
  if (buildsDir.existsSync()) {
    for (final entity in buildsDir.listSync()) {
      entity.deleteSync(recursive: true);
    }
  }

  final builds = <String, _Build>{};

  stdout.writeln('[Server] Builder: ${builderDir.path}');
  stdout.writeln('[Server] Listening on http://0.0.0.0:$port');

  final server = await HttpServer.bind(InternetAddress('0.0.0.0'), port);

  await for (final request in server) {
    _setCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 204;
      await request.response.close();
      continue;
    }

    try {
      await _handleRequest(request, builderDir, builds);
    } catch (e, st) {
      stderr.writeln('[ERROR] $e\n$st');
      _json(request.response, 500, {'error': '$e'});
      await request.response.close();
    }
  }
}

// ─── Request Router ───────────────────────────────────────────────

Future<void> _handleRequest(
  HttpRequest request,
  Directory builderDir,
  Map<String, _Build> builds,
) async {
  final path = request.uri.path;

  // GET /health
  if (path == '/health' && request.method == 'GET') {
    _json(request.response, 200, {
      'status': 'ok',
      'buildId': Platform.environment['BUILD_ID'] ?? 'unknown',
      'activeBuilds': builds.values.where((b) => b.phase == _Phase.running).length,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await request.response.close();
    return;
  }

  // POST /build
  if (path == '/build' && request.method == 'POST') {
    await _handleBuild(request, builderDir, builds);
    return;
  }

  // GET /status/{id}
  if (path.startsWith('/status/') && request.method == 'GET') {
    final id = path.substring('/status/'.length);
    final build = builds[id];
    if (build == null) {
      _json(request.response, 404, {'error': 'Build not found'});
    } else {
      _json(request.response, 200, build.toJson());
    }
    await request.response.close();
    return;
  }

  // POST /cancel/{id}
  if (path.startsWith('/cancel/') && request.method == 'POST') {
    final id = path.substring('/cancel/'.length);
    final build = builds[id];
    if (build == null) {
      _json(request.response, 404, {'error': 'Build not found'});
    } else if (build.phase != _Phase.running) {
      _json(request.response, 400, {'error': 'Build is not active', 'status': build.phase.name});
    } else {
      build.cancel();
      _json(request.response, 200, {'status': 'cancelled', 'buildId': id});
    }
    await request.response.close();
    return;
  }

  // GET /download/{id}
  if (path.startsWith('/download/') && request.method == 'GET') {
    final id = path.substring('/download/'.length);
    final build = builds[id];
    if (build == null || build.apkPath == null) {
      _json(request.response, 404, {'error': 'Build not found or APK not ready'});
      await request.response.close();
      return;
    }
    final apkFile = File(build.apkPath!);
    if (!apkFile.existsSync()) {
      _json(request.response, 404, {'error': 'APK file no longer exists on server'});
      await request.response.close();
      return;
    }
    final filename = '${build.appId}-v${build.version}.apk';
    request.response.headers.set('Content-Type', 'application/vnd.android.package-archive');
    request.response.headers.set('Content-Disposition', 'attachment; filename="$filename"');
    request.response.headers.set('Content-Length', '${apkFile.lengthSync()}');
    await apkFile.openRead().pipe(request.response);
    return;
  }

  _json(request.response, 404, {
    'error': 'Not found',
    'endpoints': {
      'GET /health': 'Health check',
      'POST /build': 'Submit build JSON',
      'GET /status/{id}': 'Check build progress',
      'POST /cancel/{id}': 'Cancel a build',
      'GET /download/{id}': 'Download APK',
    },
  });
  await request.response.close();
}

// ─── Build Handler ────────────────────────────────────────────────

Future<void> _handleBuild(
  HttpRequest request,
  Directory builderDir,
  Map<String, _Build> builds,
) async {
  final body = await utf8.decoder.bind(request).join();

  Map<String, dynamic> json;
  try {
    json = jsonDecode(body) as Map<String, dynamic>;
  } catch (e) {
    _json(request.response, 400, {'error': 'Invalid JSON: $e'});
    await request.response.close();
    return;
  }

  if (!json.containsKey('app')) {
    _json(request.response, 400, {'error': 'Missing "app" field in JSON'});
    await request.response.close();
    return;
  }

  final appId = (json['app']['id'] as String?) ?? 'app';
  final appName = (json['app']['name'] as String?) ?? 'App';
  final version = (json['app']['version'] as String?) ?? '1.0.0';
  final buildId = '${appId}_${DateTime.now().millisecondsSinceEpoch}';

  final build = _Build(
    id: buildId,
    appId: appId,
    appName: appName,
    version: version,
    json: json,
    builderDir: builderDir,
  );
  builds[buildId] = build;

  stdout.writeln('');
  stdout.writeln('[Build] $buildId — $appName v$version');
  build.start();

  _json(request.response, 200, {
    'buildId': buildId,
    'status': 'building',
    'statusUrl': '/status/$buildId',
    'downloadUrl': '/download/$buildId',
  });
  await request.response.close();
}

// ─── Build Model ──────────────────────────────────────────────────

enum _Phase { queued, running, completed, failed, cancelled }

class _Build {
  final String id;
  final String appId;
  final String appName;
  final String version;
  final Map<String, dynamic> json;
  final Directory builderDir;
  final DateTime createdAt = DateTime.now();

  _Phase phase = _Phase.queued;
  String? error;
  String? apkPath;
  int? apkSize;
  Process? _process;

  _Build({
    required this.id,
    required this.appId,
    required this.appName,
    required this.version,
    required this.json,
    required this.builderDir,
  });

  void start() {
    phase = _Phase.running;
    _run();
  }

  void cancel() {
    phase = _Phase.cancelled;
    error = 'Cancelled by user';
    _process?.kill(ProcessSignal.sigterm);
    stdout.writeln('[$id] Cancelled');
  }

  Future<void> _run() async {
    final tempDir = Directory('/tmp/rs-build-$id');

    try {
      // Write build JSON to temp file
      tempDir.createSync(recursive: true);
      final jsonFile = File(p.join(tempDir.path, 'build.json'));
      jsonFile.writeAsStringSync(jsonEncode(json));

      // Output dir for APK
      final outputDir = Directory(p.join(builderDir.path, 'builds', id));
      outputDir.createSync(recursive: true);

      stdout.writeln('[$id] Starting build.sh...');

      // Run build script
      _process = await Process.start(
        'bash',
        [p.join(builderDir.path, 'build.sh'), jsonFile.path, outputDir.path],
        workingDirectory: builderDir.path,
        environment: {
          'HOME': '/root',
          'PATH': Platform.environment['PATH'] ?? '/usr/local/bin:/usr/bin:/bin',
          'FLUTTER_ROOT': '/opt/flutter',
          'ANDROID_HOME': '/opt/android-sdk',
        },
      );

      // Stream stdout to server logs (build progress)
      _process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (line) => stdout.writeln('[$id] $line'),
        onError: (e) => stderr.writeln('[$id] stdout error: $e'),
      );

      // Collect stderr (error output) — capped at 50KB
      final stderrBuf = StringBuffer();
      final stderrSub = _process!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (line) {
          stdout.writeln('[$id] STDERR: $line');
          if (stderrBuf.length < 51200) {
            stderrBuf.writeln(line);
          }
        },
      );

      final exitCode = await _process!.exitCode;
      await stderrSub.cancel();

      if (phase == _Phase.cancelled) return;

      if (exitCode != 0) {
        phase = _Phase.failed;
        final err = stderrBuf.toString().trim();
        // Extract just the useful part (skip pub get noise)
        error = _extractError(err);
        stdout.writeln('[$id] FAILED (exit $exitCode)');
        stdout.writeln('[$id] Error: ${error!.substring(0, error!.length.clamp(0, 500))}');
        return;
      }

      // Find APK
      final apkFiles = outputDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.apk'))
          .toList();

      if (apkFiles.isEmpty) {
        phase = _Phase.failed;
        error = 'Build succeeded but no APK file found';
        stdout.writeln('[$id] No APK found');
        return;
      }

      final apk = apkFiles.first;
      apkPath = apk.path;
      apkSize = apk.lengthSync();
      phase = _Phase.completed;

      final sizeMB = (apkSize! / 1024 / 1024).toStringAsFixed(1);
      stdout.writeln('[$id] DONE — ${p.basename(apk.path)} ($sizeMB MB)');
    } catch (e) {
      phase = _Phase.failed;
      error = '$e';
      stdout.writeln('[$id] ERROR: $e');
    } finally {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    }
  }

  /// Extract the meaningful error from build output, skipping pub get noise
  String _extractError(String stderr) {
    // Look for Gradle/build failure markers
    final markers = ['FAILURE:', 'BUILD FAILED', 'What went wrong:', 'Execution failed'];
    for (final marker in markers) {
      final idx = stderr.lastIndexOf(marker);
      if (idx >= 0) {
        return stderr.substring(idx).trim();
      }
    }
    // Fallback: last 5KB
    if (stderr.length > 5120) {
      return '...${stderr.substring(stderr.length - 5120)}';
    }
    return stderr;
  }

  Map<String, dynamic> toJson() => {
    'buildId': id,
    'appId': appId,
    'appName': appName,
    'version': version,
    'status': phase.name,
    if (error != null) 'error': error,
    if (apkPath != null) 'downloadUrl': '/download/$id',
    if (apkSize != null) 'apkSize': apkSize,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ─── Helpers ──────────────────────────────────────────────────────

void _setCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
}

void _json(HttpResponse response, int statusCode, Map<String, dynamic> body) {
  response.statusCode = statusCode;
  final encoded = utf8.encode(jsonEncode(body));
  response.headers.set('Content-Type', 'application/json; charset=utf-8');
  response.headers.set('Content-Length', '${encoded.length}');
  response.add(encoded);
}
