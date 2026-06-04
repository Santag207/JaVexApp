import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import 'bloc/forms_bloc.dart';
import 'bloc/forms_event.dart';
import 'bloc/forms_state.dart';

/// Configuración estática de cada sección del formulario.
class _SectionConfig {
  final String key;
  final String title;
  final String subtitle;
  final List<String> docs;
  final int limit;

  const _SectionConfig({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.docs,
    required this.limit,
  });
}

const _formType = 'document_management';

const List<_SectionConfig> _sections = [
  _SectionConfig(
    key: 'presidencia',
    title: 'Presidencia',
    subtitle: 'Presidente y vicepresidentes — una vez por semestre',
    docs: [
      'xae_01_metas_de_semestre.docx',
      'xae_05_cierre_del_semestre.docx',
    ],
    limit: 2,
  ),
  _SectionConfig(
    key: 'lider_proyecto',
    title: 'Líder de proyecto',
    subtitle: 'Reporte semanal y ficha maestra del proyecto',
    docs: [
      'xae_03_reporte_semanal_coordinador.docx',
      'xae_P1_ficha_maestra_del_proyecto.docx',
    ],
    limit: 2,
  ),
  _SectionConfig(
    key: 'grupo_proyecto',
    title: 'Grupo por proyecto',
    subtitle: 'Informe de avance — una vez al mes',
    docs: [
      'xae_P4_informe_de_avance.docx',
    ],
    limit: 1,
  ),
  _SectionConfig(
    key: 'individual',
    title: 'Individual por sesión',
    subtitle: 'Ficha bitácora de sesión — una por semana',
    docs: [
      'xae_P2_ficha_bitacora_de_sesion.docx',
    ],
    limit: 1,
  ),
];

class DocumentManagementFormScreen extends StatelessWidget {
  const DocumentManagementFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormsBloc>(
      create: (_) => GetIt.I<FormsBloc>(),
      child: const _DocumentManagementFormView(),
    );
  }
}

class _DocumentManagementFormView extends StatefulWidget {
  const _DocumentManagementFormView();

  @override
  State<_DocumentManagementFormView> createState() =>
      _DocumentManagementFormViewState();
}

class _DocumentManagementFormViewState
    extends State<_DocumentManagementFormView> {
  /// Archivos seleccionados por sección (key → lista de archivos).
  final Map<String, List<PlatformFile>> _selected = {
    for (final s in _sections) s.key: <PlatformFile>[],
  };

  Future<void> _pickFiles(_SectionConfig section) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: section.limit > 1,
      withData: true,
    );
    if (result == null) return;

    final current = _selected[section.key]!;
    final combined = [...current];
    for (final f in result.files) {
      if (combined.any((e) => e.name == f.name)) continue;
      combined.add(f);
    }

    if (combined.length > section.limit) {
      _showSnack(
        'Esta sección admite máximo ${section.limit} archivo(s).',
        isError: true,
      );
    }

    setState(() {
      _selected[section.key] = combined.take(section.limit).toList();
    });
  }

  void _removeFile(String sectionKey, PlatformFile file) {
    setState(() {
      _selected[sectionKey]!.removeWhere((e) => e.name == file.name);
    });
  }

  Future<Uint8List?> _bytesOf(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    if (file.path != null) return File(file.path!).readAsBytes();
    return null;
  }

  Future<void> _submit() async {
    final uploads = <FormFileUpload>[];
    for (final section in _sections) {
      for (final file in _selected[section.key]!) {
        final bytes = await _bytesOf(file);
        if (bytes == null) {
          _showSnack('No se pudo leer el archivo ${file.name}.', isError: true);
          return;
        }
        uploads.add(FormFileUpload(
          sectionKey: section.key,
          fileName: file.name,
          bytes: bytes,
        ));
      }
    }

    if (uploads.isEmpty) {
      _showSnack('Selecciona al menos un archivo para enviar.', isError: true);
      return;
    }

    if (!mounted) return;
    context.read<FormsBloc>().add(
          SubmitFormFilesRequested(formType: _formType, files: uploads),
        );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'GESTIÓN DOCUMENTAL',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => context.pop(),
      ),
      body: BlocConsumer<FormsBloc, FormsState>(
        listener: (context, state) {
          if (state is FormsSuccess) {
            // El ScaffoldMessenger es de nivel app, así que el aviso sigue
            // visible tras volver a la pantalla anterior (lista de formularios).
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is FormsError) {
            _showSnack(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final uploading = state is FormsUploading;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    for (var i = 0; i < _sections.length; i++) ...[
                      _SectionCard(
                        section: _sections[i],
                        files: _selected[_sections[i].key]!,
                        onPick: uploading
                            ? null
                            : () => _pickFiles(_sections[i]),
                        onRemove: uploading
                            ? null
                            : (f) => _removeFile(_sections[i].key, f),
                      ).fadeInUp(
                        delay: Duration(milliseconds: 60 * i),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              uploading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )
                  : AppButton(
                      label: 'Enviar archivos',
                      onPressed: _submit,
                      fullWidth: true,
                      glow: true,
                      icon: Icons.cloud_upload_outlined,
                    ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.files,
    required this.onPick,
    required this.onRemove,
  });

  final _SectionConfig section;
  final List<PlatformFile> files;
  final VoidCallback? onPick;
  final void Function(PlatformFile)? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: textTheme.titleLarge
                  ?.copyWith(color: AppColors.primaryAccent)),
          const SizedBox(height: 4),
          Text(section.subtitle, style: textTheme.bodySmall),
          const SizedBox(height: 10),
          ...section.docs.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(d,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Máximo ${section.limit} archivo(s)',
            style: textTheme.labelSmall,
          ),
          const SizedBox(height: 10),
          // Archivos seleccionados
          if (files.isNotEmpty)
            ...files.map(
              (f) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f.name,
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRemove != null)
                      InkWell(
                        onTap: () => onRemove!(f),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.error),
                      ),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: files.length >= section.limit ? null : onPick,
            icon: const Icon(Icons.attach_file, size: 18),
            label: Text(
              files.isEmpty ? 'Seleccionar archivo(s)' : 'Agregar otro',
            ),
          ),
        ],
      ),
    );
  }
}
