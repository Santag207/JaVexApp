import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          LoginRequested(email: email, password: password),
        );
  }

  Future<void> _askToEnableBiometric(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Inicio con huella o rostro'),
        content: const Text(
          '¿Quieres activar el inicio con huella o rostro para tu próxima sesión? '
          'Tu huella o rostro nunca sale de tu dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Activar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (accepted == true) {
      context.read<AuthBloc>().add(const BiometricEnableRequested());
    } else {
      context.read<AuthBloc>().add(const BiometricSkipped());
      context.go('/menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return current is AuthAuthenticated ||
              current is AuthAuthenticatedAwaitingBiometricChoice ||
              current is AuthError;
        },
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/menu');
          } else if (state is AuthAuthenticatedAwaitingBiometricChoice) {
            _askToEnableBiometric(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowCyan(0.3),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 180,
                          width: 180,
                        ),
                      ).fadeInUp(),
                      const SizedBox(height: 24),
                      Text(
                        'JAVEX ROBOTICS',
                        style: textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryAccent,
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ).fadeInUp(delay: const Duration(milliseconds: 100)),
                      const SizedBox(height: 8),
                      Text(
                        '// Acceso al sistema',
                        style: textTheme.labelMedium,
                      ).fadeInUp(delay: const Duration(milliseconds: 150)),
                      const SizedBox(height: 32),
                      AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              hint: 'usuario@dominio.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.alternate_email,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              obscureText: true,
                              prefixIcon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 24),
                            state is AuthLoading
                                ? const CircularProgressIndicator()
                                : AppButton(
                                    label: 'Iniciar sesión',
                                    onPressed: _login,
                                    fullWidth: true,
                                    glow: true,
                                    icon: Icons.arrow_forward,
                                  ),
                          ],
                        ),
                      ).fadeInUp(delay: const Duration(milliseconds: 200)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
