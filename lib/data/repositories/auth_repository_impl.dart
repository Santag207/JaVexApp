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
    final result = await _apiService.signInWithPassword(email, password);
    if (result == null) return null;
    return User.fromJson(result);
  }

  @override
  Future<User?> currentUser() async {
    final result = await _apiService.currentUserProfile();
    if (result == null) return null;
    return User.fromJson(result);
  }

  @override
  Future<void> logout() async {
    await _apiService.signOut();
    await _secureStorage.clearAll();
  }

  @override
  Future<User?> loginWithBiometrics() async {
    final ok = await _biometric.authenticate(
      reason: 'Inicia sesión con tu huella o rostro',
    );
    if (!ok) return null;

    final userJson = await _secureStorage.readUserJson();
    final refreshToken = await _secureStorage.readAuthToken();
    if (userJson == null || refreshToken == null) return null;

    // Caso normal: Supabase persiste y auto-refresca la sesión entre reinicios.
    // Si ya hay sesión viva, la usamos y refrescamos el refresh token guardado
    // (rota en cada refresco, así el respaldo se mantiene útil).
    final liveProfile = await _apiService.currentUserProfile();
    if (liveProfile != null) {
      final fresh = _apiService.currentRefreshToken();
      if (fresh != null) {
        await _secureStorage.saveAuthToken(fresh);
      }
      return User.fromJson(liveProfile);
    }

    // Respaldo: no hay sesión viva → restaurarla con el refresh token guardado.
    final restored = await _apiService.restoreSession(refreshToken);
    if (!restored) return null;

    final restoredProfile = await _apiService.currentUserProfile();
    if (restoredProfile != null) {
      final fresh = _apiService.currentRefreshToken();
      if (fresh != null) {
        await _secureStorage.saveAuthToken(fresh);
      }
      return User.fromJson(restoredProfile);
    }

    // Último recurso: rehidratar desde el JSON persistido.
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
    required User user,
  }) async {
    // Persistimos el refresh token real de la sesión activa: con él se
    // restaurará la sesión de Supabase tras verificar la huella/rostro.
    final refreshToken = _apiService.currentRefreshToken();
    if (refreshToken == null) {
      throw StateError('No hay sesión activa para activar la biometría');
    }
    await _secureStorage.saveAuthToken(refreshToken);
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
    await _secureStorage.setBiometricEnabled(true);
  }

  @override
  Future<void> disableBiometricLogin() async {
    await _secureStorage.clearAll();
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _apiService.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String nombre,
    required String apellidos,
  }) async {
    await _apiService.createUser({
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellidos': apellidos,
    });
  }
}
