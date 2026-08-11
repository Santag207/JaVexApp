import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/form_definition.dart';
import '../../domain/repositories/forms_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'dynamic_form_screen.dart';
import 'forms_admin_screen.dart';

/// Lista de formularios disponibles. La "Gestión Documental" es una tarjeta
/// especial (flujo de archivos por secciones); el resto se cargan desde la BD.
class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  final FormsRepository _repo = GetIt.I<FormsRepository>();

  List<FormDefinition>? _forms;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _forms = null;
      _error = null;
    });
    try {
      final forms = await _repo.getForms();
      if (!mounted) return;
      setState(() => _forms = forms.where((f) => f.activo).toList());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  bool get _isSuperuser {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated
        ? state.user
        : state is AuthAuthenticatedAwaitingBiometricChoice
            ? state.user
            : null;
    return user?.isSuperuser ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'FORMULARIOS',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_isSuperuser)
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primaryAccent),
            tooltip: 'Administrar formularios',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const FormsAdminScreen()),
              );
              _load();
            },
          ),
      ],
      body: RefreshIndicator(
        color: AppColors.primaryAccent,
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _FormCard(
              title: 'Sistema de Gestión Documental',
              description: 'Sube los documentos del semillero (metas, reportes, '
                  'fichas e informes).',
              icon: Icons.folder_copy_outlined,
              onTap: () => context.pushNamed('documentManagementForm'),
            ).fadeInUp(),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('// $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error)),
              )
            else if (_forms == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              for (var i = 0; i < _forms!.length; i++) ...[
                _FormCard(
                  title: _forms![i].title,
                  description: _forms![i].description,
                  icon: Icons.assignment_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DynamicFormScreen(form: _forms![i]),
                    ),
                  ),
                ).fadeInUp(delay: Duration(milliseconds: 60 * (i + 1))),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      glow: true,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description, style: textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primaryAccent),
        ],
      ),
    );
  }
}
