import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String titulo;
  final String urgencia;
  final String fecha;
  final String subsistema;
  final String descripcion;
  final String nombreCreador;

  /// Estado de la tarea: 'pendiente' | 'completada'.
  final String estado;

  /// Marca temporal de cuándo se completó (ISO8601). Vacío si sigue pendiente.
  final String completadaEn;

  /// IDs de los usuarios (`users.id`) responsables de la tarea.
  final List<int> responsableIds;

  const Task({
    required this.id,
    required this.titulo,
    required this.urgencia,
    required this.fecha,
    required this.subsistema,
    required this.descripcion,
    required this.nombreCreador,
    this.estado = 'pendiente',
    this.completadaEn = '',
    this.responsableIds = const [],
  });

  /// True si la tarea está pendiente y su fecha límite ya pasó.
  bool get estaAtrasada {
    if (estado != 'pendiente') return false;
    final f = DateTime.tryParse(fecha);
    if (f == null) return false;
    final hoy = DateTime.now();
    final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);
    return f.isBefore(hoySoloFecha);
  }

  bool get estaCompletada => estado == 'completada';

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      titulo: json['titulo'] as String? ?? '',
      urgencia: json['urgencia'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
      subsistema: json['subsistema'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      nombreCreador: json['nombreCreador'] as String? ?? '',
      estado: json['estado'] as String? ?? 'pendiente',
      completadaEn: json['completada_en']?.toString() ?? '',
      responsableIds: _parseResponsables(json['task_responsables']),
    );
  }

  /// Parsea la relación embebida `task_responsables` (lista de `{user_id}`)
  /// que devuelve PostgREST. Tolera nulos y formatos string/int.
  static List<int> _parseResponsables(dynamic raw) {
    if (raw is! List) return const [];
    final ids = <int>[];
    for (final e in raw) {
      if (e is Map && e['user_id'] != null) {
        final v = e['user_id'];
        final id = v is int ? v : int.tryParse(v.toString());
        if (id != null) ids.add(id);
      }
    }
    return ids;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'urgencia': urgencia,
      'fecha': fecha,
      'subsistema': subsistema,
      'descripcion': descripcion,
      'nombreCreador': nombreCreador,
      'estado': estado,
      'completada_en': completadaEn,
    };
  }

  @override
  List<Object?> get props => [id, titulo, subsistema, estado, responsableIds];
}
