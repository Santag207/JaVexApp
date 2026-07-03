import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TaskRepository taskRepository;
  final UserRepository userRepository;

  DashboardBloc({
    required this.taskRepository,
    required this.userRepository,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardRequested>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final users = await userRepository.getUsers();
      final tasks = await taskRepository.getTasks();

      // Conjunto de todos los subsistemas presentes (en usuarios y tareas).
      final subsistemas = <String>{};
      for (final u in users) {
        subsistemas.addAll(u.subsistemas.where((s) => s.isNotEmpty));
      }
      for (final t in tasks) {
        if (t.subsistema.isNotEmpty) subsistemas.add(t.subsistema);
      }

      // Vista "Mi equipo": un TeamView por cada subsistema del usuario actual.
      final misEquipos = <TeamView>[];
      for (final sub in event.currentUser.subsistemas) {
        if (sub.isEmpty) continue;
        misEquipos.add(_buildTeamView(sub, users, tasks));
      }

      // Vista general: agregado anónimo por subsistema.
      final general = subsistemas
          .map((sub) => _buildAgg(sub, users, tasks))
          .toList()
        ..sort((a, b) => b.avance.compareTo(a.avance));

      emit(DashboardLoaded(misEquipos: misEquipos, general: general));
    } catch (e) {
      emit(DashboardError('Error cargando el dashboard: $e'));
    }
  }

  TeamView _buildTeamView(String sub, List<User> users, List<Task> tasks) {
    final miembros = users.where((u) => u.subsistemas.contains(sub)).toList();
    final tareasSub = tasks.where((t) => t.subsistema == sub).toList();

    final integrantes = miembros.map((u) {
      final suyas = tareasSub
          .where((t) => t.responsableIds.contains(u.id))
          .toList();
      final cumplidas = suyas.where((t) => t.estaCompletada).length;
      final atrasadas = suyas.where((t) => t.estaAtrasada).length;
      final pendientes = suyas.where((t) => t.estado == 'pendiente').length;
      return MemberStats(
        userId: u.id,
        nombre: '${u.nombre} ${u.apellidos}'.trim(),
        esLider: u.liderSubsistema == sub,
        cumplidas: cumplidas,
        atrasadas: atrasadas,
        pendientes: pendientes,
      );
    }).toList()
      ..sort((a, b) => b.cumplidas.compareTo(a.cumplidas));

    return TeamView(subsistema: sub, integrantes: integrantes);
  }

  SubsistemaAgg _buildAgg(String sub, List<User> users, List<Task> tasks) {
    final integrantes = users.where((u) => u.subsistemas.contains(sub)).length;
    final tareasSub = tasks.where((t) => t.subsistema == sub);
    final cumplidas = tareasSub.where((t) => t.estaCompletada).length;
    final pendientes = tareasSub.where((t) => t.estado == 'pendiente').length;
    final atrasadas = tareasSub.where((t) => t.estaAtrasada).length;
    return SubsistemaAgg(
      subsistema: sub,
      integrantes: integrantes,
      cumplidas: cumplidas,
      pendientes: pendientes,
      atrasadas: atrasadas,
    );
  }
}
