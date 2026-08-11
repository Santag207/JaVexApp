import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/form_definition.dart';
import '../../domain/entities/form_field_def.dart';
import '../../domain/repositories/forms_repository.dart';

/// Editor de un formulario (cabecera + preguntas). Solo superuser.
/// Si [form] es null, se está creando uno nuevo.
class FormEditorScreen extends StatefulWidget {
  const FormEditorScreen({super.key, this.form});

  final FormDefinition? form;

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

const _typeLabels = <String, String>{
  'text': 'Texto',
  'multiline': 'Multilínea',
  'radio': 'Opción múltiple',
  'archivo': 'Archivo',
};

String _slug(String s) {
  final base = s
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return base.isEmpty ? 'campo' : base;
}

class _FormEditorScreenState extends State<FormEditorScreen> {
  final FormsRepository _repo = GetIt.I<FormsRepository>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _keyCtrl;
  late final TextEditingController _descCtrl;
  bool _activo = true;

  FormDefinition? _form;
  List<FormFieldDef> _fields = [];
  bool _loadingFields = false;
  bool _savingHeader = false;

  @override
  void initState() {
    super.initState();
    _form = widget.form;
    _titleCtrl = TextEditingController(text: _form?.title ?? '');
    _keyCtrl = TextEditingController(text: _form?.key ?? '');
    _descCtrl = TextEditingController(text: _form?.description ?? '');
    _activo = _form?.activo ?? true;
    if (_form != null) _loadFields();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _keyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFields() async {
    setState(() => _loadingFields = true);
    try {
      final fields = await _repo.getFormFields(_form!.id);
      if (!mounted) return;
      setState(() {
        _fields = fields;
        _loadingFields = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFields = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _saveHeader() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack('El título es obligatorio.', error: true);
      return;
    }
    final key = _keyCtrl.text.trim().isEmpty
        ? _slug(title)
        : _slug(_keyCtrl.text.trim());
    setState(() => _savingHeader = true);
    try {
      if (_form == null) {
        final created = await _repo.createForm(FormDefinition(
          id: 0,
          key: key,
          title: title,
          description: _descCtrl.text.trim(),
          icon: '',
          activo: _activo,
          orden: 0,
        ));
        if (!mounted) return;
        setState(() {
          _form = created;
          _keyCtrl.text = created.key;
          _savingHeader = false;
        });
        _snack('Formulario creado. Ahora agrega preguntas.');
      } else {
        final updated = await _repo.updateForm(_form!.id, {
          'key': key,
          'title': title,
          'description': _descCtrl.text.trim(),
          'activo': _activo,
        });
        if (!mounted) return;
        setState(() {
          _form = updated;
          _savingHeader = false;
        });
        _snack('Formulario actualizado.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingHeader = false);
      _snack('Error al guardar: $e', error: true);
    }
  }

  Future<void> _saveField(FormFieldDef? existing, FormFieldDef draft) async {
    try {
      if (existing == null) {
        await _repo.createField(draft);
      } else {
        await _repo.updateField(existing.id, draft.toPayload());
      }
      await _loadFields();
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar la pregunta: $e', error: true);
    }
  }

  Future<void> _deleteField(FormFieldDef field) async {
    try {
      await _repo.deleteField(field.id);
      await _loadFields();
    } catch (e) {
      if (!mounted) return;
      _snack('Error al eliminar: $e', error: true);
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
    });
    // Persistir el nuevo `orden` (índice) de las preguntas que cambiaron.
    try {
      for (var i = 0; i < _fields.length; i++) {
        if (_fields[i].orden != i) {
          await _repo.updateField(_fields[i].id, {'orden': i});
          _fields[i] = _fields[i].copyWith(orden: i);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Error al reordenar: $e', error: true);
      _loadFields();
    }
  }

  void _showFieldEditor(FormFieldDef? existing) {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final hintCtrl = TextEditingController(text: existing?.hint ?? '');
    final sectionCtrl = TextEditingController(text: existing?.section ?? '');
    final optionsCtrl = TextEditingController(
        text: existing == null ? '' : existing.options.join('\n'));
    String type = existing?.type ?? 'text';
    bool requerido = existing?.requerido ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
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
                  Text(existing == null ? 'NUEVA PREGUNTA' : 'EDITAR PREGUNTA',
                      style: Theme.of(ctx).textTheme.displaySmall),
                  const SizedBox(height: 20),
                  AppTextField(controller: labelCtrl, label: 'Pregunta'),
                  const SizedBox(height: 16),
                  const Text('TIPO',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    dropdownColor: AppColors.cardBackground,
                    iconEnabledColor: AppColors.primaryAccent,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    items: _typeLabels.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setModal(() => type = v ?? 'text'),
                  ),
                  if (type == 'radio') ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: optionsCtrl,
                      label: 'Opciones (una por línea)',
                      maxLines: 4,
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppTextField(
                      controller: hintCtrl, label: 'Ayuda (opcional)'),
                  const SizedBox(height: 16),
                  AppTextField(
                      controller: sectionCtrl,
                      label: 'Sección (opcional)'),
                  const SizedBox(height: 4),
                  const Text(
                    'Aparece como título encima de esta pregunta. Déjalo vacío '
                    'si la pregunta va dentro de la sección anterior.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryAccent,
                    title: const Text('Obligatoria',
                        style: TextStyle(color: AppColors.textPrimary)),
                    value: requerido,
                    onChanged: (v) => setModal(() => requerido = v),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Guardar pregunta',
                    fullWidth: true,
                    glow: true,
                    onPressed: () {
                      final label = labelCtrl.text.trim();
                      if (label.isEmpty) return;
                      final options = type == 'radio'
                          ? optionsCtrl.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList()
                          : <String>[];
                      final draft = FormFieldDef(
                        id: existing?.id ?? 0,
                        formId: _form!.id,
                        key: existing?.key ?? _slug(label),
                        label: label,
                        hint: hintCtrl.text.trim().isEmpty
                            ? null
                            : hintCtrl.text.trim(),
                        type: type,
                        options: options,
                        section: sectionCtrl.text.trim().isEmpty
                            ? null
                            : sectionCtrl.text.trim(),
                        requerido: requerido,
                        orden: existing?.orden ?? _fields.length,
                      );
                      Navigator.pop(ctx);
                      _saveField(existing, draft);
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasForm = _form != null;
    return AppScaffold(
      title: hasForm ? 'EDITAR FORMULARIO' : 'NUEVO FORMULARIO',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 4),
          AppTextField(controller: _titleCtrl, label: 'Título'),
          const SizedBox(height: 12),
          AppTextField(
              controller: _keyCtrl,
              label: 'Clave (opcional, se genera del título)'),
          const SizedBox(height: 12),
          AppTextField(
              controller: _descCtrl, label: 'Descripción', maxLines: 2),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryAccent,
            title: const Text('Activo',
                style: TextStyle(color: AppColors.textPrimary)),
            value: _activo,
            onChanged: (v) => setState(() => _activo = v),
          ),
          const SizedBox(height: 4),
          AppButton(
            label: hasForm ? 'Guardar cambios' : 'Crear formulario',
            fullWidth: true,
            glow: true,
            loading: _savingHeader,
            onPressed: _saveHeader,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PREGUNTAS', style: textTheme.titleLarge),
              if (hasForm)
                TextButton.icon(
                  onPressed: () => _showFieldEditor(null),
                  icon: const Icon(Icons.add,
                      color: AppColors.primaryAccent, size: 18),
                  label: const Text('Agregar',
                      style: TextStyle(color: AppColors.primaryAccent)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!hasForm)
            Text('// Guarda el formulario para agregar preguntas.',
                style: textTheme.labelMedium)
          else if (_loadingFields)
            const Center(child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ))
          else if (_fields.isEmpty)
            Text('// Sin preguntas. Agrega la primera.',
                style: textTheme.labelMedium)
          else ...[
            Text('Mantén presionada una pregunta y arrástrala para reordenar.',
                style: textTheme.bodySmall),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: true,
              itemCount: _fields.length,
              onReorder: _onReorder,
              itemBuilder: (context, i) =>
                  _fieldTile(_fields[i], i, textTheme),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _fieldTile(FormFieldDef f, int index, TextTheme textTheme) {
    final hasSection = f.section != null && f.section!.isNotEmpty;
    return Padding(
      key: ValueKey(f.id),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de sección (mismo estilo azul que en el formulario).
          if (hasSection)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                f.section!.toUpperCase(),
                style: textTheme.titleLarge
                    ?.copyWith(color: AppColors.primaryAccent),
              ),
            ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.label,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        '${_typeLabels[f.type] ?? f.type}'
                        '${f.requerido ? ' · obligatoria' : ''}'
                        '${hasSection ? ' · sección: ${f.section}' : ''}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: AppColors.primaryAccent, size: 18),
                  onPressed: () => _showFieldEditor(f),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18),
                  onPressed: () => _deleteField(f),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
