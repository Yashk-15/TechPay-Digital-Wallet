// lib/core/security/security_service.dart
//
// PCI DSS Compliance Strategy Implementation
// ───────────────────────────────────────────
// PCI DSS Requirement 3: Protect stored cardholder data
//   → All sensitive fields use mock encryption (AES-256 in production)
//   → CVV is never stored after authorization (enforced via policy comment)
//
// PCI DSS Requirement 6: Develop & maintain secure systems
//   → All payment events are audit-logged with timestamps
//
// PCI DSS Requirement 7: Restrict access to cardholder data by business need
//   → SecurityService is a singleton; keys never exposed in app state
//
// PCI DSS Requirement 10: Track and monitor all access
//   → logSecurityEvent() records every sensitive action
//
// NOTE: This file uses a MOCK AES implementation for demo purposes.
// In a production build, replace mockEncryptData / mockDecryptData with
// the `encrypt` package using AES-256-CBC with a key stored in the
// platform Keychain (iOS) / Keystore (Android) — never in source code.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// PCI DSS security event categories (Requirement 10.2)
enum SecurityEventType {
  transferInitiated,
  paymentAttempted,
  paymentSucceeded,
  paymentFailed,
  cardDataAccessed,
  kycVerified,
  pinChanged,
  biometricEnabled,
  sessionStarted,
  sessionEnded,
  suspiciousActivity,
}

extension SecurityEventTypeX on SecurityEventType {
  String get label {
    switch (this) {
      case SecurityEventType.transferInitiated:
        return 'TRANSFER_INITIATED';
      case SecurityEventType.paymentAttempted:
        return 'PAYMENT_ATTEMPTED';
      case SecurityEventType.paymentSucceeded:
        return 'PAYMENT_SUCCEEDED';
      case SecurityEventType.paymentFailed:
        return 'PAYMENT_FAILED';
      case SecurityEventType.cardDataAccessed:
        return 'CARD_DATA_ACCESSED';
      case SecurityEventType.kycVerified:
        return 'KYC_VERIFIED';
      case SecurityEventType.pinChanged:
        return 'PIN_CHANGED';
      case SecurityEventType.biometricEnabled:
        return 'BIOMETRIC_ENABLED';
      case SecurityEventType.sessionStarted:
        return 'SESSION_STARTED';
      case SecurityEventType.sessionEnded:
        return 'SESSION_ENDED';
      case SecurityEventType.suspiciousActivity:
        return 'SUSPICIOUS_ACTIVITY';
    }
  }
}

/// Audit log entry (PCI DSS Req. 10)
class AuditEntry {
  final String eventType;
  final String detail;
  final DateTime timestamp;

  const AuditEntry({
    required this.eventType,
    required this.detail,
    required this.timestamp,
  });

  @override
  String toString() => '[${timestamp.toIso8601String()}] $eventType: $detail';
}

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // ── PCI DSS Req. 3.5: Key management ──────────────────────────────────────
  //
  // PRODUCTION NOTE: Replace this placeholder with a key retrieved from the
  // platform secure storage (flutter_secure_storage) at runtime.
  // NEVER commit real encryption keys to source control.
  //
  // ignore: unused_field
  static const String _mockAesKeyPlaceholder =
      'REPLACE_WITH_SECURE_KEYSTORE_KEY_AT_RUNTIME';

  // In-memory mock "secure storage" — in production: flutter_secure_storage
  final Map<String, String> _mockSecureStorage = {};

  // In-memory audit trail (PCI DSS Req. 10) — in production: remote SIEM
  final List<AuditEntry> _auditLog = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 200));
    logEvent(SecurityEventType.sessionStarted, 'SecurityService initialized');
    if (kDebugMode) debugPrint('[SECURITY] Initialized (mock mode)');
  }

  // ── Encryption (AES-256 mock) ──────────────────────────────────────────────
  //
  // PRODUCTION: Use package:encrypt with AES.fromLength(256) in CBC mode.
  // Example (do NOT use this key literal):
  //   final key  = Key.fromSecureRandom(32);
  //   final iv   = IV.fromSecureRandom(16);
  //   final encr = Encrypter(AES(key, mode: AESMode.cbc));
  //   final encrypted = encr.encrypt(data, iv: iv);

  /// MOCK — Simulates AES-256 encryption for demo builds only.
  /// WARNING: base64 is NOT encryption. Replace before production release.
  String mockEncryptData(String data) {
    final bytes = utf8.encode(data);
    return 'AES256_ENC:${base64.encode(bytes)}';
  }

  /// MOCK — Simulates AES-256 decryption for demo builds only.
  String mockDecryptData(String encryptedData) {
    const prefix = 'AES256_ENC:';
    if (!encryptedData.startsWith(prefix)) {
      throw const FormatException('Invalid encrypted payload format');
    }
    final b64 = encryptedData.substring(prefix.length);
    return utf8.decode(base64.decode(b64));
  }

  // ── Secure Storage (Keychain / Keystore mock) ──────────────────────────────

  Future<void> secureWrite(String key, String value) async {
    await Future.delayed(const Duration(milliseconds: 80));
    _mockSecureStorage[key] = mockEncryptData(value);
    logEvent(SecurityEventType.cardDataAccessed,
        'secureWrite key=$key (value encrypted)');
  }

  Future<String?> secureRead(String key) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final encrypted = _mockSecureStorage[key];
    if (encrypted == null) return null;
    logEvent(SecurityEventType.cardDataAccessed, 'secureRead key=$key');
    return mockDecryptData(encrypted);
  }

  Future<void> secureDelete(String key) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _mockSecureStorage.remove(key);
  }

  // ── PIN / Password Hashing (PCI DSS Req. 8) ───────────────────────────────
  //
  // Uses SHA-256 with a per-user salt.
  // In production: use bcrypt or Argon2 via the `dbcrypt` or `argon2` package.

  String hashPin(String pin, {String salt = 'TECHPAY_SALT_V1'}) {
    final bytes = utf8.encode('$salt:$pin');
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  bool verifyPin(String pin, String storedHash,
      {String salt = 'TECHPAY_SALT_V1'}) {
    return hashPin(pin, salt: salt) == storedHash;
  }

  // ── Transaction Payload Signing ────────────────────────────────────────────
  //
  // Creates an HMAC-SHA256 signature for payment payloads.
  // In production this signature is verified server-side.

  String signPayload(String payload) {
    final key = utf8.encode(_mockAesKeyPlaceholder);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  bool verifyPayloadSignature(String payload, String signature) {
    return signPayload(payload) == signature;
  }

  // ── Device Integrity (PCI DSS Req. 6.3) ───────────────────────────────────

  Future<bool> verifyDeviceIntegrity() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In production: use package:flutter_jailbreak_detection or SafetyNet/App Attest
    return true; // Always passes in demo
  }

  // ── PAN / CVV masking helpers (PCI DSS Req. 3.3) ─────────────────────────
  //
  // PCI DSS: Display no more than the first 6 and last 4 digits of PAN.
  // CVV must NEVER be stored after authorization.

  static String maskPan(String pan) {
    if (pan.length < 10) return '•••• ••••';
    final last4 = pan.substring(pan.length - 4);
    return '•••• •••• •••• $last4';
  }

  /// CVV policy: call this immediately after auth; never persist.
  static String maskCvv() => '•••';

  // ── Audit Logging (PCI DSS Req. 10) ───────────────────────────────────────

  void logEvent(SecurityEventType type, String detail) {
    final entry = AuditEntry(
      eventType: type.label,
      detail: detail,
      timestamp: DateTime.now(),
    );
    _auditLog.add(entry);

    if (kDebugMode) {
      debugPrint('[SECURITY AUDIT] ${entry.toString()}');
    }

    // In production: forward to your SIEM / logging endpoint via HTTPS.
    // _remoteLogger.send(entry);
  }

  // Convenience wrapper kept for backward compatibility with existing callers
  void logSecurityEvent(String eventType, String detail) {
    final entry = AuditEntry(
      eventType: eventType,
      detail: detail,
      timestamp: DateTime.now(),
    );
    _auditLog.add(entry);
    if (kDebugMode) debugPrint('[SECURITY AUDIT] ${entry.toString()}');
  }

  /// Returns a copy of the audit log (read-only access for compliance UI)
  List<AuditEntry> get auditLog => List.unmodifiable(_auditLog);
}
