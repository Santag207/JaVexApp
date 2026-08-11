import 'package:equatable/equatable.dart';

/// Definición de un formulario configurable (tabla `forms`).
class FormDefinition extends Equatable {
  final int id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final bool activo;
  final int orden;

  const FormDefinition({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.activo,
    required this.orden,
  });

  factory FormDefinition.fromJson(Map<String, dynamic> json) {
    return FormDefinition(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
      orden: json['orden'] as int? ?? 0,
    );
  }

  /// Payload para crear/actualizar (sin `id`, que es identidad).
  Map<String, dynamic> toPayload() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'icon': icon,
      'activo': activo,
      'orden': orden,
    };
  }

  FormDefinition copyWith({
    String? key,
    String? title,
    String? description,
    String? icon,
    bool? activo,
    int? orden,
  }) {
    return FormDefinition(
      id: id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
    );
  }

  @override
  List<Object?> get props => [id, key, title, description, icon, activo, orden];
}
