import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/password_generator.dart';
import '../../core/widgets/widgets.dart';
import '../add_hours/add_hours_screen.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TaskRepository _taskRepository = GetIt.I<TaskRepository>();
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  List<Task> _pendientes = [];
  bool _loadingPendientes = true;

  @override
  void initState() {
    super.initState();
    _loadPendientes();
  }

  Future<void> _loadPendientes() async {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated
        ? authState.user
        : authState is AuthAuthenticatedAwaitingBiometricChoice
            ? authState.user
            : null;
    if (user == null) {
      if (mounted) setState(() => _loadingPendientes = false);
      return;
    }
    try {
      final tasks = await _taskRepository.getTasks(estado: 'pendiente');
      final mias =
          tasks.where((t) => t.responsableIds.contains(user.id)).toList();
      if (!mounted) return;
      setState(() {
        _pendientes = mias;
        _loadingPendientes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPendientes = false);
    }
  }

  void _showEditModal(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.nombre);
    final lastNameController = TextEditingController(text: user.apellidos);
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EDITAR PERFIL', style: textTheme.displaySmall),
                  const SizedBox(height: 20),
                  AppTextField(controller: nameController, label: 'Nombre'),
                  const SizedBox(height: 16),
                  AppTextField(controller: lastNameController, label: 'Apellidos'),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Guardar',
                    onPressed: () => Navigator.pop(ctx),
                    fullWidth: true,
                    glow: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated
              ? state.user
              : state is AuthAuthenticatedAwaitingBiometricChoice
                  ? state.user
                  : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('PERFIL'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  tooltip: 'Cerrar sesión',
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                ),
              ],
            ),
            floatingActionButton: user == null
                ? null
                : FloatingActionButton(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: AppColors.background,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddHoursScreen()),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
            body: user == null
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryAccent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.glowCyan(0.3),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  color: AppColors.cardBackground,
                                  child: Image.asset(
                                    'assets/profile_picture.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).fadeInUp(),
                            const SizedBox(height: 16),
                            Text(
                              user.nombre.toUpperCase(),
                              style: textTheme.displayMedium,
                            ),
                            Text(
                              user.apellidos,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('// INFO', style: textTheme.labelMedium),
                                      IconButton(
                                        onPressed: () =>
                                            _showEditModal(context, user),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.primaryAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _kvRow('Fecha de unión', user.fechaUnion,
                                      textTheme),
                                  _kvRow('Rango', user.rango, textTheme,
                                      valueColor: AppColors.secondaryAccent),
                                  if (user.subsistemas.isNotEmpty)
                                    _kvRow(
                                      'Subsistemas',
                                      user.subsistemas.join(', '),
                                      textTheme,
                                    ),
                                  if (user.liderSubsistema.isNotEmpty)
                                    _kvRow(
                                      'Líder de',
                                      user.liderSubsistema,
                                      textTheme,
                                      valueColor: AppColors.success,
                                    ),
                                ],
                              ),
                            ).fadeInUp(delay: const Duration(milliseconds: 100)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statColumn(
                                    user.tareasCompletadas.toString(),
                                    'Tareas\nCompletadas',
                                    textTheme),
                                _statColumn(user.tareasCreadas.toString(),
                                    'Tareas\nCreadas', textTheme),
                                _statColumn(user.horasTrabajadas.toString(),
                                    'Horas', textTheme),
                              ],
                            ).fadeInUp(delay: const Duration(milliseconds: 200)),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'TAREAS POR SUBSISTEMA',
                                style: textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (user.tareasCompletadasPorSubsistema.isNotEmpty)
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.4,
                                children: user.tareasCompletadasPorSubsistema
                                    .entries
                                    .map((e) => _buildSubsystemCard(
                                        e.key, '${e.value} tareas', user))
                                    .toList(),
                              ),
                            const SizedBox(height: 24),
                            _buildPendientesSection(textTheme),
                            const SizedBox(height: 24),
                            _buildCuentaSection(context, user, textTheme),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  // ==================== Tareas pendientes ====================

  Widget _buildPendientesSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('TAREAS PENDIENTES', style: textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        if (_loadingPendientes)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_pendientes.isEmpty)
          Text('// No tienes tareas pendientes asignadas',
              style: textTheme.labelMedium)
        else
          ..._pendientes.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  borderColor: t.estaAtrasada ? AppColors.error : null,
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 20, color: _urgenciaColor(t.urgencia)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${t.titulo} (${t.urgencia})',
                                style: textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '${t.subsistema} · Fecha límite: ${t.fecha}'
                              '${t.estaAtrasada ? ' · ATRASADA' : ''}',
                              style: textTheme.labelMedium?.copyWith(
                                color: t.estaAtrasada
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Color _urgenciaColor(String urgencia) {
    switch (urgencia) {
      case '!':
        return AppColors.success;
      case '!!':
        return AppColors.warning;
      case '!!!':
        return AppColors.error;
      default:
        return AppColors.textPrimary;
    }
  }

  // ==================== Cuenta ====================

  Widget _buildCuentaSection(
      BuildContext context, User user, TextTheme textTheme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('// CUENTA', style: textTheme.labelMedium),
          const SizedBox(height: 12),
          AppButton(
            label: 'Cambiar contraseña',
            icon: Icons.lock_outline,
            fullWidth: true,
            variant: AppButtonVariant.ghost,
            onPressed: () => _showChangePasswordDialog(context),
          ),
          if (user.isSuperuser) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Crear usuario',
              icon: Icons.person_add_alt_1,
              fullWidth: true,
              glow: true,
              onPressed: () => _showCreateUserDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              final actual = actualCtrl.text.trim();
              final nueva = nuevaCtrl.text;
              final confirm = confirmCtrl.text;
              if (actual.isEmpty || nueva.isEmpty) {
                setModalState(() => error = 'Completa todos los campos.');
                return;
              }
              if (nueva.length < 6) {
                setModalState(() =>
                    error = 'La nueva contraseña debe tener al menos 6 caracteres.');
                return;
              }
              if (nueva != confirm) {
                setModalState(() => error = 'Las contraseñas no coinciden.');
                return;
              }
              setModalState(() {
                loading = true;
                error = null;
              });
              try {
                await _authRepository.changePassword(actual, nueva);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña actualizada.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                setModalState(() {
                  loading = false;
                  error = e.toString().replaceFirst('Exception: ', '');
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CAMBIAR CONTRASEÑA',
                      style: Theme.of(ctx).textTheme.displaySmall),
                  const SizedBox(height: 20),
                  AppTextField(
                      controller: actualCtrl,
                      label: 'Contraseña actual',
                      obscureText: true),
                  const SizedBox(height: 16),
                  AppTextField(
                      controller: nuevaCtrl,
                      label: 'Nueva contraseña',
                      obscureText: true),
                  const SizedBox(height: 16),
                  AppTextField(
                      controller: confirmCtrl,
                      label: 'Confirmar nueva contraseña',
                      obscureText: true),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Guardar',
                    fullWidth: true,
                    glow: true,
                    loading: loading,
                    onPressed: submit,
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? error;
    bool loading = false;
    bool creado = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              final email = emailCtrl.text.trim();
              final nombre = nombreCtrl.text.trim();
              final apellidos = apellidosCtrl.text.trim();
              final password = passwordCtrl.text;
              if (email.isEmpty || password.isEmpty) {
                setModalState(() =>
                    error = 'Email y contraseña son obligatorios. Genera la contraseña.');
                return;
              }
              setModalState(() {
                loading = true;
                error = null;
              });
              try {
                await _authRepository.createUser(
                  email: email,
                  password: password,
                  nombre: nombre,
                  apellidos: apellidos,
                );
                setModalState(() {
                  loading = false;
                  creado = true;
                });
              } catch (e) {
                setModalState(() {
                  loading = false;
                  error = e.toString().replaceFirst('Exception: ', '');
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREAR USUARIO',
                      style: Theme.of(ctx).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Genera la contraseña y cópiala para compartirla. El usuario '
                    'inicia sesión con su email.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                      controller: emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  AppTextField(controller: nombreCtrl, label: 'Nombre'),
                  const SizedBox(height: 16),
                  AppTextField(controller: apellidosCtrl, label: 'Apellidos'),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Generar contraseña',
                    icon: Icons.casino,
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () {
                      setModalState(() {
                        passwordCtrl.text = PasswordGenerator.generate();
                      });
                    },
                  ),
                  if (passwordCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'CONTRASEÑA GENERADA',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              passwordCtrl.text,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy,
                                color: AppColors.primaryAccent, size: 20),
                            tooltip: 'Copiar',
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: passwordCtrl.text));
                              if (!ctx.mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Contraseña copiada al portapapeles.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ],
                  if (creado) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '✓ Usuario creado. Recuerda compartir la contraseña antes de cerrar.',
                      style: TextStyle(color: AppColors.success, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: creado ? 'Cerrar' : 'Crear usuario',
                    fullWidth: true,
                    glow: true,
                    loading: loading,
                    onPressed: creado ? () => Navigator.pop(ctx) : submit,
                  ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _kvRow(String key, String value, TextTheme textTheme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              key.toUpperCase(),
              style: textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label, TextTheme textTheme) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsystemCard(String title, String count, User user) {
    final isOwn = user.subsistemas.contains(title);
    final isLead = user.liderSubsistema == title;
    final accent = isLead
        ? AppColors.success
        : isOwn
            ? AppColors.primaryAccent
            : AppColors.border;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: accent,
      glow: isOwn,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isOwn ? accent : AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
