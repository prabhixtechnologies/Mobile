import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'session_state.dart';

/// Encrypted prefs equivalent for OIDC tokens + product authorization mirror.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;
  SessionState? _memory;
  String? _deviceMemory;
  static const _uuid = Uuid();

  /// Last session read or written in this process. Avoids a keystore round trip
  /// on every API call while the access token is still fresh.
  SessionState? get cachedSession => _memory;

  static const _kAccess = 'access';
  static const _kRefresh = 'refresh';
  static const _kIdToken = 'id_token';
  static const _kExpires = 'expires';
  static const _kOrg = 'org';
  static const _kPermissions = 'permissions';
  static const _kUserId = 'user_id';
  static const _kEmail = 'email';
  static const _kDisplay = 'display';
  static const _kPlatformAdmin = 'platform_admin';
  static const _kDeviceId = 'device_id';
  static const _kBiometric = 'biometric';

  Future<String> deviceId() async {
    final cached = _deviceMemory;
    if (cached != null && cached.isNotEmpty) return cached;
    final existing = await _storage.read(key: _kDeviceId);
    if (existing != null && existing.isNotEmpty) {
      _deviceMemory = existing;
      return existing;
    }
    final created = _uuid.v4();
    await _storage.write(key: _kDeviceId, value: created);
    _deviceMemory = created;
    return created;
  }

  Future<void> saveOidcTokens(OidcTokens tokens) async {
    await _storage.write(key: _kAccess, value: tokens.accessToken);
    await _storage.write(key: _kRefresh, value: tokens.refreshToken);
    await _storage.write(key: _kExpires, value: '${tokens.expiresAtEpochMs}');
    if (tokens.idToken != null) {
      await _storage.write(key: _kIdToken, value: tokens.idToken);
    }
    final current = _memory;
    if (current != null) {
      _memory = current.copyWith(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAtEpochMs: tokens.expiresAtEpochMs,
        idToken: tokens.idToken ?? current.idToken,
      );
    }
  }

  Future<String?> idToken() => _storage.read(key: _kIdToken);

  Future<void> saveAuthorization({
    String? organizationId,
    Set<String> permissions = const {},
  }) async {
    if (organizationId == null) {
      await _storage.delete(key: _kOrg);
    } else {
      await _storage.write(key: _kOrg, value: organizationId);
    }
    await _storage.write(key: _kPermissions, value: permissions.join(','));
    final current = _memory;
    if (current != null) {
      _memory = current.copyWith(
        organizationId: organizationId ?? current.organizationId,
        permissions: permissions,
      );
    }
  }

  Future<void> saveProfile({
    required String userId,
    required String email,
    required String displayName,
    bool platformAdmin = false,
  }) async {
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kEmail, value: email);
    await _storage.write(key: _kDisplay, value: displayName);
    await _storage.write(key: _kPlatformAdmin, value: platformAdmin ? '1' : '0');
    final current = _memory;
    if (current != null) {
      _memory = current.copyWith(
        userId: userId,
        email: email,
        displayName: displayName,
        platformAdmin: platformAdmin,
      );
    }
  }

  Future<SessionState?> session() async {
    final cached = _memory;
    if (cached != null) return cached;
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    if (access == null || refresh == null) return null;
    final expiresRaw = await _storage.read(key: _kExpires);
    final permissionsRaw = await _storage.read(key: _kPermissions) ?? '';
    _memory = SessionState(
      accessToken: access,
      refreshToken: refresh,
      expiresAtEpochMs: int.tryParse(expiresRaw ?? '0') ?? 0,
      idToken: await _storage.read(key: _kIdToken),
      organizationId: await _storage.read(key: _kOrg),
      permissions: permissionsRaw.isEmpty
          ? {}
          : permissionsRaw.split(',').where((e) => e.isNotEmpty).toSet(),
      userId: await _storage.read(key: _kUserId),
      email: await _storage.read(key: _kEmail),
      displayName: await _storage.read(key: _kDisplay),
      platformAdmin: (await _storage.read(key: _kPlatformAdmin)) == '1',
    );
    return _memory;
  }

  Future<bool> biometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == '1';

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _kBiometric, value: enabled ? '1' : '0');
  }

  Future<void> clear() async {
    final device = _deviceMemory ?? await _storage.read(key: _kDeviceId);
    _memory = null;
    await _storage.deleteAll();
    if (device != null) {
      _deviceMemory = device;
      await _storage.write(key: _kDeviceId, value: device);
    }
  }
}
