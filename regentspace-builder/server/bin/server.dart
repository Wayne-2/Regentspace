import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Regentspace Build Server
/// Accepts JSON from the canva, runs the build pipeline, returns APK.
///
/// Endpoints:
///   POST /build         — Accept JSON, build APK, return download URL
///   GET  /health        — Health check
///   GET  /status/{id}   — Check build status
///   GET  /download/{id} — Download APK
///
/// Usage:
///   cd server && dart run bin/server.dart [--port 8080]

void main(List<String> args) async {
  var port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.parse(args[i + 1]);
    }
  }

  // The builder project is one level up from server/
  final serverDir = Directory.current;
  final builderDir = Directory(p.join(serverDir.path, '..'));
  final buildScript = File(p.join(builderDir.path, 'build.sh'));

  if (!buildScript.existsSync()) {
    print('[Server] ERROR: build.sh not found at ${buildScript.path}');
    exit(1);
  }

  print('[Server] Builder dir: ${builderDir.path}');
  print('[Server] Listening on http://0.0.0.0:$port');
  print('');

  final builds = <String, BuildStatus>{};

  final server = await HttpServer.bind(InternetAddress('0.0.0.0'), port);

  await for (final request in server) {
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 204;
      await request.response.close();
      continue;
    }

    try {
      await handleRequest(request, builderDir, builds);
    } catch (e, st) {
      print('[Server] Error: $e\n$st');
      _jsonResponse(request.response, 500, {'error': _sanitize(e.toString())});
      await request.response.close();
    }
  }
}

Future<void> handleRequest(
  HttpRequest request,
  Directory builderDir,
  Map<String, BuildStatus> builds,
) async {
  final path = request.uri.path;

  // Health check
  if (path == '/health' && request.method == 'GET') {
    _jsonResponse(request.response, 200, {
      'status': 'ok',
      'buildId': Platform.environment['BUILD_ID'] ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
    await request.response.close();
    return;
  }

  // Download APK
  if (path.startsWith('/download/') && request.method == 'GET') {
    final id = path.substring('/download/'.length);
    final build = builds[id];

    if (build == null || build.apkPath == null) {
      _jsonResponse(request.response, 404, {'error': 'Build not found or APK not ready'});
      await request.response.close();
      return;
    }

    final apkFile = File(build.apkPath!);
    if (!apkFile.existsSync()) {
      _jsonResponse(request.response, 404, {'error': 'APK file no longer exists'});
      await request.response.close();
      return;
    }

    final filename = '${build.appName.replaceAll(' ', '_')}-1.0.0.apk';
    request.response.headers.set('Content-Type', 'application/vnd.android.package-archive');
    request.response.headers.set('Content-Disposition', 'attachment; filename="$filename"');
    request.response.headers.set('Content-Length', '${apkFile.lengthSync()}');
    await apkFile.openRead().pipe(request.response);
    return;
  }

  // Cancel build
  if (path.startsWith('/cancel/') && request.method == 'POST') {
    final id = path.substring('/cancel/'.length);
    final build = builds[id];

    if (build == null) {
      _jsonResponse(request.response, 404, {'error': 'Build not found'});
      await request.response.close();
      return;
    }

    if (build.status != 'building' && build.status != 'queued' && build.status != 'preparing') {
      _jsonResponse(request.response, 400, {'error': 'Build is not active', 'status': build.status});
      await request.response.close();
      return;
    }

    build.status = 'cancelled';
    build.error = 'Build cancelled by user';
    build.process?.kill(ProcessSignal.sigterm);
    print('[$id] Cancelled by user');

    _jsonResponse(request.response, 200, {'status': 'cancelled', 'buildId': id});
    await request.response.close();
    return;
  }

  // Build status
  if (path.startsWith('/status/') && request.method == 'GET') {
    final id = path.substring('/status/'.length);
    final build = builds[id];

    if (build == null) {
      _jsonResponse(request.response, 404, {'error': 'Build not found'});
    } else {
      _jsonResponse(request.response, 200, build.toJson());
    }
    await request.response.close();
    return;
  }

  // Submit build
  if (path == '/build' && request.method == 'POST') {
    final body = await utf8.decoder.bind(request).join();

    Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      _jsonResponse(request.response, 400, {'error': 'Invalid JSON: $e'});
      await request.response.close();
      return;
    }

    if (!json.containsKey('app')) {
      _jsonResponse(request.response, 400, {'error': 'Missing "app" field'});
      await request.response.close();
      return;
    }

    final appId = (json['app']['id'] as String?) ?? 'default';
    final appName = (json['app']['name'] as String?) ?? 'App';
    final buildId = '${appId}_${DateTime.now().millisecondsSinceEpoch}';
    final status = BuildStatus(id: buildId, appId: appId, appName: appName);
    builds[buildId] = status;

    print('');
    print('[Build] $buildId — $appName');
    unawaited(runBuild(status, json, builderDir, builds));

    _jsonResponse(request.response, 200, {
      'buildId': buildId,
      'status': 'building',
      'statusUrl': '/status/$buildId',
      'downloadUrl': '/download/$buildId',
    });
    await request.response.close();
    return;
  }

  // Unknown
  _jsonResponse(request.response, 404, {
    'error': 'Not found',
    'endpoints': {
      'POST /build': 'Submit build JSON',
      'POST /cancel/{id}': 'Cancel a build',
      'GET /health': 'Health check',
      'GET /status/{id}': 'Check build progress',
      'GET /download/{id}': 'Download APK',
    },
  });
  await request.response.close();
}

Future<void> runBuild(
  BuildStatus status,
  Map<String, dynamic> json,
  Directory builderDir,
  Map<String, BuildStatus> builds,
) async {
  final buildId = status.id;
  final tempDir = Directory('/tmp/rs-build-$buildId');

  try {
    status.status = 'preparing';

    // Write JSON to temp file
    tempDir.createSync(recursive: true);
    final jsonFile = File(p.join(tempDir.path, 'build.json'));
    jsonFile.writeAsStringSync(jsonEncode(json));

    // Output dir inside builderDir/builds/{buildId}
    final outputDir = Directory(p.join(builderDir.path, 'builds', buildId));
    outputDir.createSync(recursive: true);

    status.status = 'building';
    print('[$buildId] Building...');

    final process = await Process.start(
      'bash',
      [p.join(builderDir.path, 'build.sh'), jsonFile.path, outputDir.path],
      workingDirectory: builderDir.path,
      environment: {
        'HOME': Platform.environment['HOME'] ?? '/home/wayne',
        'PATH': Platform.environment['PATH'] ?? '',
      },
    );
    status.process = process;

    // Check if cancelled before we started listening
    if (status.status == 'cancelled') {
      process.kill(ProcessSignal.sigterm);
      return;
    }

    // Collect output (must consume streams to avoid zombie processes)
    await process.stdout.drain<void>();
    final stderrChunks = await process.stderr.toList();
    final stderrBytes = stderrChunks.expand((c) => c).toList();
    final exitCode = await process.exitCode;

    if (status.status == 'cancelled') return;

    if (exitCode != 0) {
      status.status = 'failed';
      status.error = _sanitize(utf8.decode(stderrBytes, allowMalformed: true));
      print('[$buildId] FAILED (exit $exitCode): ${status.error}');
      return;
    }

    // Find APK in output
    final apkFiles = outputDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.apk'))
        .toList();

    if (apkFiles.isEmpty) {
      status.status = 'failed';
      status.error = 'Build succeeded but no APK found';
      print('[$buildId] No APK found');
      return;
    }

    final apk = apkFiles.first;
    final sizeMB = (apk.lengthSync() / 1024 / 1024).toStringAsFixed(1);

    status.status = 'completed';
    status.apkPath = apk.path;
    status.apkSize = apk.lengthSync();
    print('[$buildId] Done — ${p.basename(apk.path)} (${sizeMB}MB)');
  } catch (e) {
    status.status = 'failed';
    status.error = _sanitize(e.toString());
    print('[$buildId] ERROR: $e');
  } finally {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  }
}

/// Strip control characters (ANSI escapes, null bytes, etc.) that break JSON encoding
String _sanitize(String s) {
  return s.replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '').trim();
}

/// Write a JSON response with proper UTF-8 encoding
void _jsonResponse(HttpResponse response, int statusCode, Map<String, dynamic> body) {
  response.statusCode = statusCode;
  final encoded = utf8.encode(jsonEncode(body));
  response.headers.set('Content-Type', 'application/json; charset=utf-8');
  response.headers.set('Content-Length', '${encoded.length}');
  response.add(encoded);
}

class BuildStatus {
  final String id;
  final String appId;
  final String appName;
  String status = 'queued';
  String? error;
  String? apkPath;
  int? apkSize;
  Process? process;
  final DateTime createdAt = DateTime.now();

  BuildStatus({
    required this.id,
    required this.appId,
    required this.appName,
  });

  Map<String, dynamic> toJson() => {
    'buildId': id,
    'appId': appId,
    'appName': appName,
    'status': status,
    if (error != null) 'error': error,
    if (apkPath != null) 'apkPath': apkPath,
    if (apkSize != null) 'apkSize': apkSize,
    'createdAt': createdAt.toIso8601String(),
  };
}
