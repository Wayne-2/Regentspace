import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'push_notification_service.dart';
import '../pages/dashboard/newusertab.dart';

const String kBuildServerUrl = 'https://regentspace-builder-production.up.railway.app';

class BuildInfo {
  final String buildId;
  final String appName;
  final String appId;
  String status;
  int? apkSize;
  String? downloadUrl;
  String? error;
  final DateTime createdAt;

  BuildInfo({
    required this.buildId,
    required this.appName,
    required this.appId,
    this.status = 'building',
    this.apkSize,
    this.downloadUrl,
    this.error,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'buildId': buildId,
    'appName': appName,
    'appId': appId,
    'status': status,
    'apkSize': apkSize,
    'downloadUrl': downloadUrl,
    'error': error,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BuildInfo.fromMap(Map<String, dynamic> m) => BuildInfo(
    buildId: m['buildId'],
    appName: m['appName'],
    appId: m['appId'],
    status: m['status'] ?? 'building',
    apkSize: m['apkSize'],
    downloadUrl: m['downloadUrl'],
    error: m['error'],
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class BuildTracker {
  BuildTracker._();
  static final instance = BuildTracker._();

  static const String _boxName = 'builds';
  Box? _box;

  final ValueNotifier<List<BuildInfo>> builds = ValueNotifier([]);

  Timer? _pollTimer;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _loadBuilds();
  }

  void _loadBuilds() {
    final list = <BuildInfo>[];
    for (var i = 0; i < (_box?.length ?? 0); i++) {
      final raw = _box!.getAt(i);
      if (raw is Map) {
        list.add(BuildInfo.fromMap(Map<String, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    builds.value = list;
  }

  Future<void> _saveBuilds() async {
    await _box?.clear();
    for (final b in builds.value) {
      await _box?.add(b.toMap());
    }
  }

  Future<void> submitBuild(Map<String, dynamic> buildJson) async {
    final appName = buildJson['app']['name'] ?? 'App';
    final appId = buildJson['app']['id'] ?? 'default';
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final response = await http.post(
      Uri.parse('$kBuildServerUrl/build'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(buildJson),
    );

    if (response.statusCode != 200) {
      throw Exception('Build server error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final buildId = data['buildId'] as String;

    // Write app metadata to builder Firestore so dashboard can query it
    if (uid != null) {
      try {
        final builderDb = await BuilderFirestore.instance;
        await builderDb
            .collection('apps')
            .doc('regentspace-builder')
            .collection('apps')
            .doc(appId)
            .set({
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'appName': appName,
          'appId': appId,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[BuildTracker] Builder Firestore write failed: $e');
      }
    }

    final info = BuildInfo(
      buildId: buildId,
      appName: appName,
      appId: appId,
      status: 'building',
      downloadUrl: data['downloadUrl'],
    );

    builds.value = [info, ...builds.value];
    await _saveBuilds();

    // Show initial build progress notification
    try {
      await PushNotificationService.instance.showBuildProgressNotification(
        buildId: buildId,
        appName: appName,
        status: 'Build submitted, waiting for server...',
      );
    } catch (_) {}

    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollAll());
    _pollAll();
  }

  /// Map server phase names to client status names.
  /// Server uses: queued, running, completed, failed, cancelled
  /// Client uses: preparing, building, completed, failed, cancelled
  String _normalizeStatus(String? serverStatus) {
    switch (serverStatus) {
      case 'queued': return 'preparing';
      case 'running': return 'building';
      case 'completed': return 'completed';
      case 'failed': return 'failed';
      case 'cancelled': return 'cancelled';
      case 'building':
      case 'preparing':
        return serverStatus!;
      default: return serverStatus ?? 'building';
    }
  }

  Future<void> _pollAll() async {
    final active = builds.value.where((b) => b.status == 'building' || b.status == 'preparing').toList();
    if (active.isEmpty) {
      _pollTimer?.cancel();
      return;
    }

    for (final build in active) {
      try {
        final response = await http.get(Uri.parse('$kBuildServerUrl/status/${build.buildId}'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final normalized = _normalizeStatus(data['status'] as String?);

          if (normalized != build.status) {
            build.status = normalized;
            build.apkSize = data['apkSize'];
            build.downloadUrl = data['downloadUrl'] ?? '/download/${build.buildId}';
            build.error = data['error'];
          }

          if (normalized == 'completed' || normalized == 'failed' || normalized == 'cancelled') {
            await _saveBuilds();
            builds.value = List<BuildInfo>.from(builds.value);

            // Dismiss progress notification, show result notification
            try {
              await PushNotificationService.instance.dismissBuildProgressNotification(build.buildId);
            } catch (_) {}

            if (normalized == 'completed') {
              _showNotification(build);
            }
          } else {
            // Still building — show/update persistent progress notification
            try {
              final displayStatus = _statusToDisplayText(build.status);
              await PushNotificationService.instance.showBuildProgressNotification(
                buildId: build.buildId,
                appName: build.appName,
                status: displayStatus,
              );
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
  }

  String _statusToDisplayText(String status) {
    switch (status) {
      case 'preparing': return 'Preparing build environment...';
      case 'building': return 'Building APK...';
      case 'completed': return 'Build complete!';
      case 'failed': return 'Build failed';
      case 'cancelled': return 'Build cancelled';
      default: return 'Processing...';
    }
  }

  /// Re-poll all active builds immediately (called on app resume)
  Future<void> refreshActiveBuilds() async {
    final active = builds.value.where((b) => b.status == 'building' || b.status == 'preparing').toList();
    if (active.isEmpty) return;
    _startPolling();
  }

  Future<void> _showNotification(BuildInfo build) async {
    try {
      await PushNotificationService.instance.showBuildNotification(
        appName: build.appName,
        buildId: build.buildId,
      );
    } catch (_) {}
  }

  Future<void> dismissBuild(int index) async {
    try {
      final list = List<BuildInfo>.from(builds.value);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        builds.value = list;
        await _saveBuilds();
        debugPrint('[BuildTracker] Dismissed build at index $index');
      }
    } catch (e) {
      debugPrint('[BuildTracker] Dismiss failed: $e');
    }
  }

  Future<void> cancelBuild(String buildId) async {
    try {
      final response = await http.post(Uri.parse('$kBuildServerUrl/cancel/$buildId'));
      debugPrint('[BuildTracker] Cancel response: ${response.statusCode} ${response.body}');
      
      // Find and update the build regardless of server response
      final build = builds.value.cast<BuildInfo?>().firstWhere(
        (b) => b!.buildId == buildId,
        orElse: () => null,
      );
      
      if (build != null) {
        build.status = 'cancelled';
        build.error = 'Build cancelled by user';
        await _saveBuilds();
        builds.value = List<BuildInfo>.from(builds.value);

        // Dismiss progress notification
        try {
          await PushNotificationService.instance.dismissBuildProgressNotification(buildId);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[BuildTracker] Cancel failed: $e');
    }
  }
}
