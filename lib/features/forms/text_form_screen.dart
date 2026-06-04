import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import 'bloc/forms_bloc.dart';
import 'bloc/forms_event.dart';
import 'bloc/forms_state.dart';

enum FormFieldType { text, multiline, radio }

/// Definición de un campo de un formulario de texto.
class FormFieldConfig {
  final String key;
  final String label;
  final String? hint;
  final FormFieldType type;
  final List<String> options; // sólo para [FormFieldType.radio]
  final String? section; // encabezado de grupo, si inicia una sección nueva

  const FormFieldConfig({
    required this.key,
    required this.label,
    this.hint,
    this.type = FormFieldType.text,
    this.options = const [],
    this.section,
  });
}

/// Pantalla genérica para formularios de texto: renderiza los campos a partir
/// de una lista de [FormFieldConfig] y envía las respuestas como un objeto.
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

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      if (f.type == FormFieldType.radio) {
        _radioValues[f.key] = null;
      } else {
        _controllers[f.key] = TextEditingController();
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

  void _submit() {
    final answers = <String, dynamic>{};
    for (final f in widget.fields) {
      if (f.type == FormFieldType.radio) {
        final value = _radioValues[f.key];
        if (value == null) {
          _showSnack('Selecciona una opción en "${f.label}".', isError: true);
          return;
        }
        answers[f.key] = value;
      } else {
        final text = _controllers[f.key]!.text.trim();
        if (text.isEmpty) {
          _showSnack('Completa el campo "${f.label}".', isError: true);
          return;
        }
        answers[f.key] = text;
      }
    }

    context.read<FormsBloc>().add(
          SubmitFormTextRequested(formType: widget.formType, answers: answers),
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
                      label: 'Enviar reporte',
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

    if (field.type == FormFieldType.radio) {
      children.add(_buildRadioGroup(field, enabled: enabled));
    } else {
      // Pregunta como etiqueta y descripción debajo, en texto menor, para que
      // se lea completa (en vez de truncarse dentro del campo).
      children.add(Text(field.label,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)));
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
    }

    children.add(const SizedBox(height: 16));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
