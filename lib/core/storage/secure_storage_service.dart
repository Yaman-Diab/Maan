// -------------------------
// Secure Storage Service
// -------------------------

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageKeys {
  SecureStorageKeys._();

  static const String accessToken = 'ACCESS_TOKEN';
  static const String refreshToken = 'REFRESH_TOKEN';
  static const String userData = 'USER_DATA';
  static const String isGuest = 'IS_GUEST';
  static const String visitorId = 'VISITOR_ID';
}

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  // -------------------------
  // Base Helpers
  // -------------------------

  Future<void> _write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _delete(String key) async {
    await _storage.delete(key: key);
  }

  // -------------------------
  // Tokens
  // -------------------------

  Future<void> saveAccessToken(String token) async {
    await _write(key: SecureStorageKeys.accessToken, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _write(key: SecureStorageKeys.refreshToken, value: token);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _read(SecureStorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return _read(SecureStorageKeys.refreshToken);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isLoggedIn() async {
    return hasAccessToken();
  }

  Future<void> clearTokens() async {
    await _delete(SecureStorageKeys.accessToken);
    await _delete(SecureStorageKeys.refreshToken);
  }

  // -------------------------
  // User
  // -------------------------

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _write(key: SecureStorageKeys.userData, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final data = await _read(SecureStorageKeys.userData);

      if (data == null || data.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(data);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _delete(SecureStorageKeys.userData);
  }

  // -------------------------
  // Guest
  // -------------------------

  Future<void> setGuest(bool value) async {
    await _write(
      key: SecureStorageKeys.isGuest,
      value: value ? 'true' : 'false',
    );
  }

  Future<bool> isGuest() async {
    final value = await _read(SecureStorageKeys.isGuest);
    return value == 'true';
  }

  Future<void> clearGuestFlag() async {
    await _delete(SecureStorageKeys.isGuest);
  }

  // -------------------------
  // Visitor
  // -------------------------

  Future<void> saveVisitorId(String id) async {
    await _write(key: SecureStorageKeys.visitorId, value: id);
  }

  Future<String?> getVisitorId() async {
    return _read(SecureStorageKeys.visitorId);
  }

  Future<void> clearVisitorId() async {
    await _delete(SecureStorageKeys.visitorId);
  }

  // -------------------------
  // Clear
  // -------------------------

  Future<void> clearSession({
    bool keepGuestFlag = false,
    bool keepVisitorId = false,
  }) async {
    await clearTokens();
    await clearUser();

    if (!keepVisitorId) {
      await clearVisitorId();
    }

    if (!keepGuestFlag) {
      await clearGuestFlag();
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
