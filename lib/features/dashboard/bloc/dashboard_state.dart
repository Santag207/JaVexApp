import 'package:equatable/equatable.dart';

/// Rendimiento de un integrante dentro de un equipo (subsistema).
class MemberStats extends Equatable {
  final int userId;
  final String nombre;
  final bool esLider;
  final int cumplidas;
  final int atrasadas;
  final int pendientes;

  const MemberStats({
    required this.userId,
    required this.nombre,
    required this.esLider,
    required this.cumplidas,
    required this.atrasadas,
    required this.pendientes,
  });

  /// Rendimiento 0..1 = cumplidas / (cumplidas + atrasadas). Null si no hay
  /// tareas con las que medir.
  double? get rendimiento {
    final base = cumplidas + atrasadas;
    if (base == 0) return null;
    return cumplidas / base;
  }

  @override
  List<Object?> get props =>
      [userId, nombre, esLider, cumplidas, atrasadas, pendientes];
}

/// Vista de un equipo (subsistema) con sus integrantes.
class TeamView extends Equatable {
  final String subsistema;
  final List<MemberStats> integrantes;

  const TeamView({required this.subsistema, required this.integrantes});

  int get totalCumplidas =>
      integrantes.fold(0, (s, m) => s + m.cumplidas);
  int get totalAtrasadas =>
      integrantes.fold(0, (s, m) => s + m.atrasadas);
  int get totalPendientes =>
      integrantes.fold(0, (s, m) => s + m.pendientes);

  @override
  List<Object?> get props => [subsistema, integrantes];
}

/// Agregado anónimo de un equipo para la vista general (sin nombres).
class SubsistemaAgg extends Equatable {
  final String subsistema;
  final int integrantes;
  final int cumplidas;
  final int pendientes;
  final int atrasadas;

  const SubsistemaAgg({
    required this.subsistema,
    required this.integrantes,
    required this.cumplidas,
    required this.pendientes,
    required this.atrasadas,
  });

  /// Promedio de tareas cumplidas por integrante.
  double get promedioCumplidas =>
      integrantes == 0 ? 0 : cumplidas / integrantes;

  /// % de pendientes que están atrasadas (0..1).
  double get porcentajeAtrasadas =>
      pendientes == 0 ? 0 : atrasadas / pendientes;

  /// Avance global del equipo: cumplidas / (cumplidas + pendientes) (0..1).
  double get avance {
    final base = cumplidas + pendientes;
    if (base == 0) return 0;
    return cumplidas / base;
  }

  @override
  List<Object?> get props =>
      [subsistema, integrantes, cumplidas, pendientes, atrasadas];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  /// Equipos a los que pertenece el usuario actual (vista "Mi equipo").
  final List<TeamView> misEquipos;

  /// Agregados de todos los equipos (vista "General").
  final List<SubsistemaAgg> general;

  const DashboardLoaded({required this.misEquipos, required this.general});

  @override
  List<Object?> get props => [misEquipos, general];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
