import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'app_tenant.dart';

/// Rate configuration loaded from Firestore.
/// Stores commission rates, profit margins, service toggles, and transaction limits.
/// Document path: apps/regentspace-builder/rates
class RateConfig {
  static RateConfig? _instance;
  static RateConfig get instance => _instance ??= RateConfig._();
  RateConfig._();

  // ── Airtime commission (% of VTPass price, added on top) ──
  Map<String, double> airtimeRates = {
    'MTN': 3.5,
    'GLO': 3.0,
    'Airtel': 3.0,
    '9mobile': 3.0,
  };

  // ── Data profit margin (₦ per GB, added on top of VTPass price) ──
  Map<String, Map<String, double>> dataRates = {
    'MTN': {'SME': 280, 'Gifting': 260, 'Corporate': 250},
    'GLO': {'SME': 270, 'Gifting': 250, 'Corporate': 240},
    'Airtel': {'SME': 285, 'Gifting': 265, 'Corporate': 255},
    '9mobile': {'SME': 300, 'Gifting': 280, 'Corporate': 270},
  };

  // ── Cable TV commission (% of VTPass price, added on top) ──
  Map<String, double> cableTvRates = {
    'DSTV': 2.5,
    'GOTV': 2.0,
    'Startimes': 1.5,
  };

  // ── Electricity processing fee (% of VTPass price, added on top) ──
  Map<String, double> electricityRates = {
    'IKEDC': 1.0,
    'EKEDC': 1.0,
    'AEDC': 1.0,
    'IBEDC': 1.0,
    'PHED': 1.0,
    'KEDCO': 1.0,
    'JED': 1.0,
    'CEEDC': 1.0,
    'AEDC-Prepaid': 1.0,
  };

  // ── Service toggles ──
  Map<String, bool> serviceToggles = {
    'Airtime': true,
    'Data': true,
    'Cable TV': true,
    'Electricity': true,
    'Education': false,
  };

  // ── Transaction limits ──
  double minTransaction = 100;
  double maxTransaction = 500000;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ─── Firestore path ───

  static DocumentReference<Map<String, dynamic>> _doc(FirebaseFirestore db) =>
      db.collection('apps').doc(AppTenant.platformAppId).collection('config').doc('rates');

  // ─── Load from Firestore ───

  Future<void> loadFromFirestore(FirebaseFirestore db) async {
    try {
      final snap = await _doc(db).get();
      if (!snap.exists || snap.data() == null) {
        _loaded = true;
        return;
      }
      final d = snap.data()!;
      _applyMap(d, 'airtimeRates', airtimeRates);
      _applyNestedMap(d, 'dataRates', dataRates);
      _applyMap(d, 'cableTvRates', cableTvRates);
      _applyMap(d, 'electricityRates', electricityRates);

      final toggles = d['serviceToggles'];
      if (toggles is Map) {
        toggles.forEach((k, v) {
          if (v is bool) serviceToggles[k.toString()] = v;
        });
      }

      minTransaction = (d['minTransaction'] as num?)?.toDouble() ?? 100;
      maxTransaction = (d['maxTransaction'] as num?)?.toDouble() ?? 500000;

      _loaded = true;
      if (kDebugMode) debugPrint('[RateConfig] Loaded from Firestore');
    } catch (e) {
      if (kDebugMode) debugPrint('[RateConfig] Load failed: $e');
      _loaded = true; // Use defaults
    }
  }

  // ─── Save to Firestore (admin only) ───

  Future<void> saveToFirestore(FirebaseFirestore db) async {
    try {
      await _doc(db).set({
        'airtimeRates': airtimeRates,
        'dataRates': dataRates,
        'cableTvRates': cableTvRates,
        'electricityRates': electricityRates,
        'serviceToggles': serviceToggles,
        'minTransaction': minTransaction,
        'maxTransaction': maxTransaction,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (kDebugMode) debugPrint('[RateConfig] Saved to Firestore');
    } catch (e) {
      if (kDebugMode) debugPrint('[RateConfig] Save failed: $e');
      rethrow;
    }
  }

  // ─── Price calculation helpers ───

  /// Calculate the user-facing price for airtime.
  /// [vtpassPrice] is the amount the user wants to buy (sent to VTPass).
  /// Returns vtpassPrice + commission.
  double airtimeUserPrice(String network, double vtpassPrice) {
    final rate = airtimeRates[_normalizeNetwork(network)] ?? 0;
    return vtpassPrice * (1 + rate / 100);
  }

  /// Calculate the user-facing price for a data plan.
  /// [vtpassPrice] is the plan's variation_amount from VTPass.
  /// Returns vtpassPrice + margin.
  double dataUserPrice(String network, String type, double vtpassPrice) {
    final key = _normalizeNetwork(network);
    final margin = dataRates[key]?[type] ?? 0;
    return vtpassPrice + margin;
  }

  /// Calculate the user-facing price for cable TV.
  /// [vtpassPrice] is the plan's variation_amount from VTPass.
  /// Returns vtpassPrice + commission.
  double cableTvUserPrice(String provider, double vtpassPrice) {
    final rate = cableTvRates[_normalizeCableProvider(provider)] ?? 0;
    return vtpassPrice * (1 + rate / 100);
  }

  /// Calculate the user-facing price for electricity.
  /// [vtpassPrice] is the amount entered by the user.
  /// Returns vtpassPrice + processing fee.
  double electricityUserPrice(String disco, double vtpassPrice) {
    final rate = electricityRates[_normalizeDisco(disco)] ?? 0;
    return vtpassPrice * (1 + rate / 100);
  }

  /// Check if a service is enabled.
  bool isServiceEnabled(String service) => serviceToggles[service] ?? false;

  /// Check if amount is within transaction limits.
  bool isWithinLimits(double amount) => amount >= minTransaction && amount <= maxTransaction;

  // ─── Network name normalization ───

  /// Maps VTPass serviceIDs / screen IDs to rate map keys.
  static const _networkMap = {
    'mtn': 'MTN', 'mtn-data': 'MTN',
    'airtel': 'Airtel', 'airtel-data': 'Airtel',
    'glo': 'GLO', 'glo-data': 'GLO',
    '9mobile': '9mobile', '9mobile-data': '9mobile',
  };

  static const _cableMap = {
    'dstv': 'DSTV', 'gotv': 'GOTV', 'startimes': 'Startimes', 'showmax': 'Showmax',
  };

  static const _discoMap = {
    'ikeja-electric': 'IKEDC', 'eko-electric': 'EKEDC', 'abuja-electric': 'AEDC',
    'ibadan-electric': 'IBEDC', 'portharcourt-electric': 'PHED',
    'kano-electric': 'KEDCO', 'jos-electric': 'JED', 'kaduna-electric': 'KAEDCO',
    'enugu-electric': 'EEDC', 'benin-electric': 'BEDC',
  };

  String _normalizeNetwork(String id) => _networkMap[id] ?? id;
  String _normalizeCableProvider(String id) => _cableMap[id.toLowerCase()] ?? id;
  String _normalizeDisco(String id) => _discoMap[id] ?? id;

  // ─── Helpers ───

  void _applyMap(Map<String, dynamic> data, String key, Map<String, double> target) {
    final raw = data[key];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) target[k.toString()] = v.toDouble();
      });
    }
  }

  void _applyNestedMap(Map<String, dynamic> data, String key, Map<String, Map<String, double>> target) {
    final raw = data[key];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is Map) {
          final inner = <String, double>{};
          v.forEach((ik, iv) {
            if (iv is num) inner[ik.toString()] = iv.toDouble();
          });
          target[k.toString()] = inner;
        }
      });
    }
  }
}
