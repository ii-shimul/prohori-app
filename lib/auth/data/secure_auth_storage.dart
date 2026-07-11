import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Encrypted persistence for both Supabase session and PKCE verifier material.
/// Never replace this with unencrypted persistence.
class SecureAuthStorage extends LocalStorage implements GotrueAsyncStorage {
  SecureAuthStorage(this._storage);

  static const _sessionKey = 'prohori.supabase.session';

  final FlutterSecureStorage _storage;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: _sessionKey))?.isNotEmpty ?? false;

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _sessionKey, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _sessionKey);

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);

  /// Logout boundary: removes session, PKCE verifier, and every other secret.
  Future<void> wipeDatabase() => _storage.deleteAll();
}
