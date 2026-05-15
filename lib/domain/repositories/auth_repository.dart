import '../entities/user.dart';

abstract class AuthRepository {
  /// Login tradicional con email/password. Devuelve el usuario o null.
  Future<User?> login(String email, String password);

  /// Cierra sesión: limpia tokens y desactiva la biometría persistida.
  Future<void> logout();

  /// Login usando biometría (huella/rostro). Lanza el prompt nativo del SO,
  /// y si el usuario se autentica, rehidrata el [User] desde el secure storage.
  Future<User?> loginWithBiometrics();

  /// True si el usuario ya activó el inicio biométrico previamente.
  Future<bool> isBiometricLoginEnabled();

  /// True si el dispositivo soporta biometría y tiene huella/rostro enrolado.
  Future<bool> isBiometricAvailableOnDevice();

  /// Persiste token y user en secure storage y marca el flag biométrico.
  /// La huella/rostro NO se guarda — sólo el token que protegerá.
  Future<void> enableBiometricLogin({required String token, required User user});

  /// Quita el flag y borra los datos persistidos.
  Future<void> disableBiometricLogin();
}
