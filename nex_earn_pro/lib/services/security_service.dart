// File: lib/services/security_service.dart
// Kaam: Device fingerprint banao, max 2 accounts per device check karo
// Anti-cheat: duplicate transactions rokna

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/constants.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;

  // ─── Device Fingerprint ────────────────────────────────────────────────────

  /// Android device ka unique fingerprint banao
  Future<String> getDeviceFingerprint() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final raw = [
        androidInfo.id,
        androidInfo.brand,
        androidInfo.model,
        androidInfo.device,
        androidInfo.fingerprint,
        androidInfo.host,
      ].join('|');

      final hash = sha256.convert(utf8.encode(raw)).toString();
      _cachedDeviceId = hash.substring(0, 32); // 32 char ID
      return _cachedDeviceId!;
    } catch (e) {
      // Fallback: random-ish ID (should not happen on real device)
      _cachedDeviceId = sha256
          .convert(utf8.encode(DateTime.now().millisecondsSinceEpoch.toString()))
          .toString()
          .substring(0, 32);
      return _cachedDeviceId!;
    }
  }

  // ─── Device Account Limit ──────────────────────────────────────────────────

  /// Check karo is device pe kitne accounts hain (max 2)
  Future<bool> canCreateAccountOnDevice(String uid) async {
    try {
      final deviceId = await getDeviceFingerprint();
      final db = FirebaseDatabase.instance;
      final ref = db.ref('${FirebasePaths.deviceFingerprint(deviceId)}/uids');

      final snapshot = await ref.get();
      if (!snapshot.exists) {
        // No accounts yet — allowed
        await ref.child(uid).set(true);
        return true;
      }

      final uids = snapshot.value as Map<dynamic, dynamic>;
      if (uids.containsKey(uid)) {
        // Same user logging in again — allowed
        return true;
      }

      if (uids.length >= 2) {
        // Already 2 accounts on this device — blocked
        return false;
      }

      // Under limit — add this uid
      await ref.child(uid).set(true);
      return true;
    } catch (e) {
      // On error, allow (don't block legitimate users)
      return true;
    }
  }

  // ─── Transaction Deduplication ─────────────────────────────────────────────

  /// Check karo kya yeh transaction already process ho gayi (duplicate reward prevent)
  Future<bool> isTransactionNew(String txnId) async {
    try {
      final ref =
          FirebaseDatabase.instance.ref(FirebasePaths.adTransaction(txnId));
      final snap = await ref.get();
      if (snap.exists) return false; // Already processed

      // Mark as processed
      await ref.set({
        'processed_at': DateTime.now().toIso8601String(),
        'txn_id': txnId,
      });
      return true;
    } catch (e) {
      return true;
    }
  }

  // ─── Generate Transaction ID ───────────────────────────────────────────────

  /// Unique transaction ID generate karo
  String generateTxnId(String uid, String action) {
    final data = '$uid|$action|${DateTime.now().millisecondsSinceEpoch}';
    return sha256.convert(utf8.encode(data)).toString().substring(0, 20);
  }
}
