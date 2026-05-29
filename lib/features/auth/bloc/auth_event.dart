import 'package:equatable/equatable.dart';

/// Eventos del AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login con email + contraseña.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Cerrar sesión.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Verificar estado de sesión al abrir la app (lo dispara el AuthGate).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Disparar el prompt biométrico para iniciar sesión.
class BiometricLoginRequested extends AuthEvent {
  const BiometricLoginRequested();
}

/// Activar la biometría tras un login exitoso por email/password.
class BiometricEnableRequested extends AuthEvent {
  const BiometricEnableRequested();
}

/// Desactivar la biometría (ej. desde Perfil).
class BiometricDisableRequested extends AuthEvent {
  const BiometricDisableRequested();
}

/// El usuario eligió no activar biometría tras el login: pasamos a
/// AuthAuthenticated sin guardar credenciales para biometría.
class BiometricSkipped extends AuthEvent {
  const BiometricSkipped();
}
