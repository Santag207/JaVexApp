import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/form_definition.dart';
import '../../domain/repositories/forms_repository.dart';
import 'form_editor_screen.dart';

/// Lista de administración de formularios (solo superuser): crear, editar y
/// eliminar formularios configurables.
class FormsAdminScreen extends StatefulWidget {
  const FormsAdminScreen({super.key});

  @override
  State<FormsAdminScreen> createState() => _FormsAdminScreenState();
}

class _FormsAdminScreenState extends State<FormsAdminScreen> {
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
      setState(() => _forms = forms);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _openEditor(FormDefinition? form) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FormEditorScreen(form: form)),
    );
    _load();
  }

  Future<void> _delete(FormDefinition form) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Eliminar formulario',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text(
          'Se eliminará "${form.title}" y sus preguntas. Las respuestas ya '
          'enviadas no se borran. ¿Continuar?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AppButton(
            label: 'Eliminar',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteForm(form.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se pudo eliminar: $e'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      title: 'ADMINISTRAR FORMULARIOS',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => Navigator.of(context).pop(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.background,
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add),
      ),
      body: _error != null
          ? Center(
              child: Text('// $_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)))
          : _forms == null
              ? const Center(child: CircularProgressIndicator())
              : _forms!.isEmpty
                  ? Center(
                      child: Text('// Sin formularios. Crea uno con +',
                          style: textTheme.labelMedium))
                  : ListView.separated(
                      itemCount: _forms!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final f = _forms![i];
                        return AppCard(
                          borderColor:
                              f.activo ? null : AppColors.border,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(f.title,
                                        style: textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(f.activo ? 'Activo' : 'Inactivo',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: f.activo
                                                ? AppColors.success
                                                : AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: AppColors.primaryAccent, size: 20),
                                onPressed: () => _openEditor(f),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error, size: 20),
                                onPressed: () => _delete(f),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
