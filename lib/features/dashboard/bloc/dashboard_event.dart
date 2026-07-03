import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Carga los datos de los dashboards. [currentUser] determina cuál es el equipo
/// (subsistemas) del usuario para la vista "Mi equipo".
class LoadDashboardRequested extends DashboardEvent {
  final User currentUser;

  const LoadDashboardRequested(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}
