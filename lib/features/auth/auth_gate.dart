import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

/// Pantalla inicial de la app. Decide a dónde va el usuario:
///   - Si tiene biometría activada y disponible → lanza el prompt directo.
///   - Si no → lleva al formulario de email/password.
///   - Si ya está autenticado → lleva al menú.
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _biometricAttempted = false;

  @override
  void initState() {
    super.initState();
    // Disparar la verificación al construir la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/menu');
        } else if (state is AuthUnauthenticated) {
          if (state.shouldPromptBiometric && !_biometricAttempted) {
            // Lanza el prompt nativo de huella/Face ID directamente.
            _biometricAttempted = true;
            context.read<AuthBloc>().add(const BiometricLoginRequested());
          } else if (!state.shouldPromptBiometric) {
            // Sin biometría → formulario email/password.
            context.go('/login');
          }
        } else if (state is AuthError) {
          // Si la biometría falla, ir al formulario.
          context.go('/login');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowWhite(0.5),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', height: 180, width: 180),
                ),
                const SizedBox(height: 24),
                if (state is AuthUnauthenticated && state.shouldPromptBiometric)
                  Column(
                    children: [
                      IconButton(
                        iconSize: 72,
                        icon: const Icon(Icons.fingerprint,
                            color: AppColors.primaryAccent),
                        tooltip: 'Reintentar huella',
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const BiometricLoginRequested());
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca para verificar tu identidad',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'USAR CONTRASEÑA',
                          style: TextStyle(
                            color: AppColors.primaryAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
