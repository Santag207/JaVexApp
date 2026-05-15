import 'dart:convert';

import '../../core/services/biometric_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;
  final BiometricService _biometric;

  AuthRepositoryImpl(
    this._apiService,
    this._secureStorage,
    this._biometric,
  );

  @override
  Future<User?> login(String email, String password) async {
    final result = await _apiService.login(email, password);
    if (result == null) return null;
    return User.fromJson(result);
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  @override
  Future<User?> loginWithBiometrics() async {
    final ok = await _biometric.authenticate(
      reason: 'Inicia sesión con tu huella o rostro',
    );
    if (!ok) return null;

    final userJson = await _secureStorage.readUserJson();
    final token = await _secureStorage.readAuthToken();
    if (userJson == null || token == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isBiometricLoginEnabled() async {
    final enabled = await _secureStorage.isBiometricEnabled();
    if (!enabled) return false;
    // Sólo está realmente habilitado si también hay token y user persistidos.
    final token = await _secureStorage.readAuthToken();
    final userJson = await _secureStorage.readUserJson();
    return token != null && userJson != null;
  }

  @override
  Future<bool> isBiometricAvailableOnDevice() => _biometric.isAvailable();

  @override
  Future<void> enableBiometricLogin({
    required String token,
    required User user,
  }) async {
    await _secureStorage.saveAuthToken(token);
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
    await _secureStorage.setBiometricEnabled(true);
  }

  @override
  Future<void> disableBiometricLogin() async {
    await _secureStorage.clearAll();
  }
}
