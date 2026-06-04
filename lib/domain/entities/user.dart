import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String nombre;
  final String apellidos;
  final String fechaUnion;
  final String rango;
  final int tareasCompletadas;
  final int tareasCreadas;
  final int horasTrabajadas;
  final List<String> subsistemas;
  final String liderSubsistema;
  final Map<String, int> tareasCompletadasPorSubsistema;

  /// UUID de la cuenta en Supabase Auth (columna `auth_id`). Vacío si el perfil
  /// aún no está vinculado a una cuenta de Auth.
  final String authId;

  const User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellidos,
    required this.fechaUnion,
    required this.rango,
    required this.tareasCompletadas,
    required this.tareasCreadas,
    required this.horasTrabajadas,
    required this.subsistemas,
    required this.liderSubsistema,
    required this.tareasCompletadasPorSubsistema,
    this.authId = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      fechaUnion: json['fechaUnion'] as String? ?? '',
      rango: json['rango'] as String? ?? '',
      tareasCompletadas: json['tareasCompletadas'] as int? ?? 0,
      tareasCreadas: json['tareasCreadas'] as int? ?? 0,
      horasTrabajadas: json['horasTrabajadas'] as int? ?? 0,
      subsistemas: (json['subsistemas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      liderSubsistema: json['liderSubsistema'] as String? ?? '',
      tareasCompletadasPorSubsistema:
          (json['tareasCompletadasPorSubsistema'] as Map<String, dynamic>?)
                  ?.map((key, value) => MapEntry(key, value as int)) ??
              {},
      authId: json['auth_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'fechaUnion': fechaUnion,
      'rango': rango,
      'tareasCompletadas': tareasCompletadas,
      'tareasCreadas': tareasCreadas,
      'horasTrabajadas': horasTrabajadas,
      'subsistemas': subsistemas,
      'liderSubsistema': liderSubsistema,
      'tareasCompletadasPorSubsistema': tareasCompletadasPorSubsistema,
      'auth_id': authId,
    };
  }

  @override
  List<Object?> get props => [id, email, nombre];
}
