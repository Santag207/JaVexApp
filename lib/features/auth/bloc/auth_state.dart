import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  /// Si el dispositivo soporta biometría y el usuario ya la activó previamente,
  /// el AuthGate disparará el prompt automáticamente.
  final bool biometricEnabled;
  final bool deviceSupportsBiometric;

  const AuthUnauthenticated({
    this.biometricEnabled = false,
    this.deviceSupportsBiometric = false,
  });

  bool get shouldPromptBiometric => biometricEnabled && deviceSupportsBiometric;

  @override
  List<Object?> get props => [biometricEnabled, deviceSupportsBiometric];
}

/// Estado emitido tras un login exitoso por email/password cuando el dispositivo
/// soporta biometría pero el usuario aún no la ha activado. La UI debe
/// preguntarle si desea activarla y luego confirmar con [BiometricEnableRequested].
class AuthAuthenticatedAwaitingBiometricChoice extends AuthState {
  final User user;

  const AuthAuthenticatedAwaitingBiometricChoice({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
