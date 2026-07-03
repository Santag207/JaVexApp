import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../api_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiService _apiService;

  TaskRepositoryImpl(this._apiService);

  @override
  Future<List<Task>> getTasks({String? subsistema, String? estado}) async {
    final result =
        await _apiService.getTasks(subsistema: subsistema, estado: estado);
    return result.map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<Task> createTask(Map<String, dynamic> task) async {
    final result = await _apiService.createTask(task);
    return Task.fromJson(result);
  }

  @override
  Future<void> completeTask(int id) async {
    await _apiService.completeTask(id);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _apiService.deleteTask(id);
  }
}
