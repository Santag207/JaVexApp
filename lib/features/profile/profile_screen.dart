import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../add_hours/add_hours_screen.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../../domain/entities/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
