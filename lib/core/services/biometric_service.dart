import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Wrapper sobre [LocalAuthentication] con un API simple para la app.
///
/// La huella o el rostro NUNCA salen del dispositivo: sólo recibimos
/// un booleano del sistema operativo indicando si la verificación fue exitosa.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// True si el hardware soporta biometría y el usuario tiene al menos
  /// una huella o rostro enrolado en el sistema.
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return const [];
    }
  }

  /// Lanza el prompt nativo de huella/Face ID.
  /// Devuelve true si la verificación fue exitosa.
  Future<bool> authenticate({
    String reason = 'Verifica tu identidad para continuar',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // Errores esperables: no enrolado, bloqueado, no disponible.
      // No relanzamos: la UI debe degradar a email/password.
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
        case auth_error.passcodeNotSet:
          return false;
        default:
          return false;
      }
    }
  }
}
