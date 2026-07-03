import '../entities/user.dart';

abstract class AuthRepository {
  /// Login tradicional con email/password. Devuelve el usuario o null.
  Future<User?> login(String email, String password);

  /// Si hay una sesión de Supabase activa (persistida y refrescada por el SDK),
  /// devuelve el usuario asociado; null si no hay sesión.
  Future<User?> currentUser();

  /// Cierra sesión: limpia tokens y desactiva la biometría persistida.
  Future<void> logout();

  /// Login usando biometría (huella/rostro). Lanza el prompt nativo del SO,
  /// y si el usuario se autentica, rehidrata el [User] desde el secure storage.
  Future<User?> loginWithBiometrics();

  /// True si el usuario ya activó el inicio biométrico previamente.
  Future<bool> isBiometricLoginEnabled();

  /// True si el dispositivo soporta biometría y tiene huella/rostro enrolado.
  Future<bool> isBiometricAvailableOnDevice();

  /// Persiste el refresh token de la sesión actual y el user en secure storage,
  /// y marca el flag biométrico. La huella/rostro NO se guarda — sólo el token
  /// que se usará para restaurar la sesión tras la verificación biométrica.
  Future<void> enableBiometricLogin({required User user});

  /// Quita el flag y borra los datos persistidos.
  Future<void> disableBiometricLogin();

  /// Cambia la contraseña del usuario autenticado. Verifica [currentPassword]
  /// y aplica [newPassword]. Lanza si la contraseña actual es incorrecta.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Crea un nuevo usuario (solo superuser) vía Edge Function.
  Future<void> createUser({
    required String email,
    required String password,
    required String nombre,
    required String apellidos,
  });
}
