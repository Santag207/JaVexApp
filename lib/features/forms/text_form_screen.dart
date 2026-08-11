import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/form_field_def.dart';
import 'bloc/forms_bloc.dart';
import 'bloc/forms_event.dart';
import 'bloc/forms_state.dart';

enum FormFieldType { text, multiline, radio, archivo }

/// Convierte el string de la columna `type` (BD) al enum de renderizado.
FormFieldType formFieldTypeFromString(String value) {
  switch (value) {
    case 'multiline':
      return FormFieldType.multiline;
    case 'radio':
      return FormFieldType.radio;
    case 'archivo':
      return FormFieldType.archivo;
    default:
      return FormFieldType.text;
  }
}

/// Definición de un campo de un formulario de texto.
class FormFieldConfig {
  final String key;
  final String label;
  final String? hint;
  final FormFieldType type;
  final List<String> options; // sólo para [FormFieldType.radio]
  final String? section; // encabezado de grupo, si inicia una sección nueva
  final bool requerido;

  const FormFieldConfig({
    required this.key,
    required this.label,
    this.hint,
    this.type = FormFieldType.text,
    this.options = const [],
    this.section,
    this.requerido = true,
  });

  /// Construye la config de renderizado a partir de la definición de la BD.
  factory FormFieldConfig.fromDef(FormFieldDef def) {
    return FormFieldConfig(
      key: def.key,
      label: def.label,
      hint: def.hint,
      type: formFieldTypeFromString(def.type),
      options: def.options,
      section: def.section,
      requerido: def.requerido,
    );
  }
}

/// Pantalla genérica para formularios: renderiza los campos a partir de una
/// lista de [FormFieldConfig] y envía las respuestas (texto/opción/archivo).
class TextFormScreen extends StatelessWidget {
  const TextFormScreen({
    super.key,
    required this.formType,
    required this.title,
    required this.fields,
  });

  final String formType;
  final String title;
  final List<FormFieldConfig> fields;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormsBloc>(
      create: (_) => GetIt.I<FormsBloc>(),
      child: _TextFormView(formType: formType, title: title, fields: fields),
    );
  }
}

class _TextFormView extends StatefulWidget {
  const _TextFormView({
    required this.formType,
    required this.title,
    required this.fields,
  });

  final String formType;
  final String title;
  final List<FormFieldConfig> fields;

  @override
  State<_TextFormView> createState() => _TextFormViewState();
}

class _TextFormViewState extends State<_TextFormView> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _radioValues = {};
  final Map<String, PlatformFile?> _files = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      switch (f.type) {
        case FormFieldType.radio:
          _radioValues[f.key] = null;
          break;
        case FormFieldType.archivo:
          _files[f.key] = null;
          break;
        case FormFieldType.text:
        case FormFieldType.multiline:
          _controllers[f.key] = TextEditingController();
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile(FormFieldConfig field) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    setState(() => _files[field.key] = result.files.first);
  }

  Future<Uint8List?> _bytesOf(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    if (file.path != null) return File(file.path!).readAsBytes();
    return null;
  }

  Future<void> _submit() async {
    final answers = <String, dynamic>{};
    final files = <FieldFileUpload>[];

    for (final f in widget.fields) {
      switch (f.type) {
        case FormFieldType.radio:
          final value = _radioValues[f.key];
          if (value == null) {
            if (f.requerido) {
              _showSnack('Selecciona una opción en "${f.label}".',
                  isError: true);
              return;
            }
            break;
          }
          answers[f.key] = value;
          break;
        case FormFieldType.archivo:
          final file = _files[f.key];
          if (file == null) {
            if (f.requerido) {
              _showSnack('Adjunta un archivo en "${f.label}".', isError: true);
              return;
            }
            break;
          }
          final bytes = await _bytesOf(file);
          if (bytes == null) {
            _showSnack('No se pudo leer el archivo ${file.name}.',
                isError: true);
            return;
          }
          files.add(FieldFileUpload(
            fieldKey: f.key,
            fileName: file.name,
            bytes: bytes,
          ));
          break;
        case FormFieldType.text:
        case FormFieldType.multiline:
          final text = _controllers[f.key]!.text.trim();
          if (text.isEmpty) {
            if (f.requerido) {
              _showSnack('Completa el campo "${f.label}".', isError: true);
              return;
            }
            break;
          }
          answers[f.key] = text;
          break;
      }
    }

    if (!mounted) return;
    context.read<FormsBloc>().add(
          SubmitDynamicFormRequested(
            formKey: widget.formType,
            answers: answers,
            files: files,
          ),
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
      title: widget.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => context.pop(),
      ),
      body: BlocConsumer<FormsBloc, FormsState>(
        listener: (context, state) {
          if (state is FormsSuccess) {
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
          final sending = state is FormsUploading;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 4),
                    for (var i = 0; i < widget.fields.length; i++)
                      _buildField(widget.fields[i], i, enabled: !sending),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )
                  : AppButton(
                      label: 'Enviar',
                      onPressed: _submit,
                      fullWidth: true,
                      glow: true,
                      icon: Icons.send,
                    ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(FormFieldConfig field, int index, {required bool enabled}) {
    final textTheme = Theme.of(context).textTheme;
    final children = <Widget>[];

    // Encabezado de sección (si este campo inicia una sección nueva).
    if (field.section != null) {
      children.add(Padding(
        padding: EdgeInsets.only(top: index == 0 ? 0 : 20, bottom: 8),
        child: Text(
          field.section!.toUpperCase(),
          style: textTheme.titleLarge?.copyWith(color: AppColors.primaryAccent),
        ),
      ));
    }

    switch (field.type) {
      case FormFieldType.radio:
        children.add(_buildRadioGroup(field, enabled: enabled));
        break;
      case FormFieldType.archivo:
        children.add(_buildFileField(field, enabled: enabled));
        break;
      case FormFieldType.text:
      case FormFieldType.multiline:
        children.add(Text(field.label,
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)));
        if (field.hint != null) {
          children.add(const SizedBox(height: 4));
          children.add(Text(field.hint!, style: textTheme.bodySmall));
        }
        children.add(const SizedBox(height: 8));
        children.add(AppTextField(
          controller: _controllers[field.key],
          enabled: enabled,
          maxLines: field.type == FormFieldType.multiline ? 4 : 1,
        ));
        break;
    }

    children.add(const SizedBox(height: 16));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildFileField(FormFieldConfig field, {required bool enabled}) {
    final textTheme = Theme.of(context).textTheme;
    final file = _files[field.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
        if (field.hint != null) ...[
          const SizedBox(height: 4),
          Text(field.hint!, style: textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        if (file != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  child: Text(file.name,
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis),
                ),
                if (enabled)
                  InkWell(
                    onTap: () => setState(() => _files[field.key] = null),
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.error),
                  ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: enabled ? () => _pickFile(field) : null,
          icon: const Icon(Icons.attach_file, size: 18),
          label: Text(file == null ? 'Adjuntar archivo' : 'Cambiar archivo'),
        ),
      ],
    );
  }

  Widget _buildRadioGroup(FormFieldConfig field, {required bool enabled}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
        if (field.hint != null) ...[
          const SizedBox(height: 4),
          Text(field.hint!, style: textTheme.bodySmall),
        ],
        const SizedBox(height: 4),
        RadioGroup<String>(
          groupValue: _radioValues[field.key],
          onChanged: (value) {
            if (!enabled) return;
            setState(() => _radioValues[field.key] = value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: field.options
                .map(
                  (opt) => RadioListTile<String>(
                    value: opt,
                    title: Text(opt,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textPrimary)),
                    activeColor: AppColors.primaryAccent,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
