import 'package:equatable/equatable.dart';

/// Definición de un campo/pregunta de un formulario (tabla `form_fields`).
class FormFieldDef extends Equatable {
  final int id;
  final int formId;
  final String key;
  final String label;
  final String? hint;

  /// 'text' | 'multiline' | 'radio' | 'archivo'
  final String type;
  final List<String> options; // solo para 'radio'
  final String? section;
  final bool requerido;
  final int orden;

  const FormFieldDef({
    required this.id,
    required this.formId,
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.options = const [],
    this.section,
    required this.requerido,
    required this.orden,
  });

  bool get esArchivo => type == 'archivo';

  factory FormFieldDef.fromJson(Map<String, dynamic> json) {
    return FormFieldDef(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      formId: json['form_id'] is int
          ? json['form_id']
          : int.parse(json['form_id'].toString()),
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      hint: json['hint'] as String?,
      type: json['type'] as String? ?? 'text',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      section: json['section'] as String?,
      requerido: json['requerido'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
    );
  }

  /// Payload para crear/actualizar (sin `id`, que es identidad).
  Map<String, dynamic> toPayload() {
    return {
      'form_id': formId,
      'key': key,
      'label': label,
      'hint': hint,
      'type': type,
      'options': options,
      'section': section,
      'requerido': requerido,
      'orden': orden,
    };
  }

  FormFieldDef copyWith({
    int? formId,
    String? key,
    String? label,
    String? hint,
    String? type,
    List<String>? options,
    String? section,
    bool? requerido,
    int? orden,
  }) {
    return FormFieldDef(
      id: id,
      formId: formId ?? this.formId,
      key: key ?? this.key,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      type: type ?? this.type,
      options: options ?? this.options,
      section: section ?? this.section,
      requerido: requerido ?? this.requerido,
      orden: orden ?? this.orden,
    );
  }

  @override
  List<Object?> get props =>
      [id, formId, key, label, hint, type, options, section, requerido, orden];
}
