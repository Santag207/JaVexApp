import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  /// Último usuario autenticado (en memoria) — necesario cuando la UI
  /// confirma activar la biometría tras un login email/password.
  User? _lastAuthenticatedUser;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<BiometricEnableRequested>(_onBiometricEnableRequested);
    on<BiometricDisableRequested>(_onBiometricDisableRequested);
    on<BiometricSkipped>(_onBiometricSkipped);
  }

  Future<void> _onBiometricSkipped(
    BiometricSkipped event,
    Emitter<AuthState> emit,
  ) async {
    final user = _lastAuthenticatedUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.login(event.email, event.password);

      if (user == null) {
        emit(const AuthError(message: 'Correo o contraseña incorrectos'));
        return;
      }

      _lastAuthenticatedUser = user;

      // Si el dispositivo soporta biometría y el usuario aún no la activó,
      // dejamos que la UI pregunte. Si no, autenticación normal.
      final deviceSupports = await authRepository.isBiometricAvailableOnDevice();
      final alreadyEnabled = await authRepository.isBiometricLoginEnabled();

      if (deviceSupports && !alreadyEnabled) {
        emit(AuthAuthenticatedAwaitingBiometricChoice(user: user));
      } else {
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      emit(AuthError(message: 'Error en login: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    _lastAuthenticatedUser = null;

    final deviceSupports = await authRepository.isBiometricAvailableOnDevice();
    emit(AuthUnauthenticated(
      biometricEnabled: false,
      deviceSupportsBiometric: deviceSupports,
    ));
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final deviceSupports = await authRepository.isBiometricAvailableOnDevice();
    final biometricEnabled = await authRepository.isBiometricLoginEnabled();

    // Si la biometría está activada, dejamos que el AuthGate lance el prompt.
    // Si no, pero ya hay una sesión de Supabase persistida, entramos directo.
    if (!biometricEnabled) {
      final user = await authRepository.currentUser();
      if (user != null) {
        _lastAuthenticatedUser = user;
        emit(AuthAuthenticated(user: user));
        return;
      }
    }

    emit(AuthUnauthenticated(
      biometricEnabled: biometricEnabled,
      deviceSupportsBiometric: deviceSupports,
    ));
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authRepository.loginWithBiometrics();
      if (user != null) {
        _lastAuthenticatedUser = user;
        emit(AuthAuthenticated(user: user));
      } else {
        // Cancelado, fallido o sin datos persistidos: caer al formulario.
        final deviceSupports =
            await authRepository.isBiometricAvailableOnDevice();
        final biometricEnabled =
            await authRepository.isBiometricLoginEnabled();
        emit(AuthUnauthenticated(
          biometricEnabled: biometricEnabled,
          deviceSupportsBiometric: deviceSupports,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Error en biometría: ${e.toString()}'));
    }
  }

  Future<void> _onBiometricEnableRequested(
    BiometricEnableRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _lastAuthenticatedUser;
    if (user == null) {
      emit(const AuthError(
        message: 'No hay sesión activa para activar la biometría',
      ));
      return;
    }

    try {
      await authRepository.enableBiometricLogin(user: user);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'No se pudo activar la biometría: ${e.toString()}'));
    }
  }

  Future<void> _onBiometricDisableRequested(
    BiometricDisableRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.disableBiometricLogin();
    final user = _lastAuthenticatedUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    }
  }
}
