import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro para token JWT, datos de usuario y flag biométrico.
/// Usa Keychain en iOS y EncryptedSharedPreferences en Android.
class SecureStorageService {
  static const _kAuthToken = 'auth_token';
  static const _kUserJson = 'user_json';
  static const _kBiometricEnabled = 'biometric_enabled';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  Future<String?> readAuthToken() => _storage.read(key: _kAuthToken);

  Future<void> deleteAuthToken() => _storage.delete(key: _kAuthToken);

  Future<void> saveUserJson(String userJson) =>
      _storage.write(key: _kUserJson, value: userJson);

  Future<String?> readUserJson() => _storage.read(key: _kUserJson);

  Future<void> deleteUserJson() => _storage.delete(key: _kUserJson);

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometricEnabled, value: enabled.toString());

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _kBiometricEnabled);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await Future.wait([
      deleteAuthToken(),
      deleteUserJson(),
      _storage.delete(key: _kBiometricEnabled),
    ]);
  }
}
