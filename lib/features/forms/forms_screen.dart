import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// Lista de formularios disponibles. Por ahora solo el "Sistema de Gestión
/// Documental" está implementado; los reportes semanales quedan visibles pero
/// deshabilitados ("Próximamente").
class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'FORMULARIOS',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => context.pop(),
      ),
      body: ListView(
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
          _FormCard(
            title: 'Reporte Semanal Individual',
            description: 'Próximamente.',
            icon: Icons.assignment_ind_outlined,
            enabled: false,
          ).fadeInUp(delay: const Duration(milliseconds: 80)),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Reporte Semanal Coordinador',
            description: 'Próximamente.',
            icon: Icons.supervisor_account_outlined,
            enabled: false,
          ).fadeInUp(delay: const Duration(milliseconds: 160)),
        ],
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
    this.enabled = true,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AppCard(
        onTap: enabled ? onTap : null,
        glow: enabled,
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? AppColors.primaryAccent : AppColors.textSecondary,
              size: 32,
            ),
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
                  Text(
                    description,
                    style: textTheme.bodySmall,
                  ),
                  if (!enabled) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRÓXIMAMENTE',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right, color: AppColors.primaryAccent),
          ],
        ),
      ),
    );
  }
}
