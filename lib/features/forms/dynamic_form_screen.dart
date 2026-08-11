import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/form_definition.dart';
import '../../domain/repositories/forms_repository.dart';
import 'text_form_screen.dart';

/// Carga los campos de un formulario (definido en la BD) y los renderiza con
/// [TextFormScreen], que ya sabe dibujar cualquier lista de campos.
class DynamicFormScreen extends StatefulWidget {
  const DynamicFormScreen({super.key, required this.form});

  final FormDefinition form;

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final FormsRepository _repo = GetIt.I<FormsRepository>();

  List<FormFieldConfig>? _fields;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final defs = await _repo.getFormFields(widget.form.id);
      if (!mounted) return;
      setState(() {
        _fields = defs.map(FormFieldConfig.fromDef).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _fields;
    if (_error != null) {
      return AppScaffold(
        title: widget.form.title.toUpperCase(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: Center(
          child: Text('// $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error)),
        ),
      );
    }
    if (fields == null) {
      return const AppScaffold(
        title: 'CARGANDO',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return TextFormScreen(
      formType: widget.form.key,
      title: widget.form.title.toUpperCase(),
      fields: fields,
    );
  }
}
