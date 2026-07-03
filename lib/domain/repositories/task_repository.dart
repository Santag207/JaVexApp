import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks({String? subsistema, String? estado});
  Future<Task> createTask(Map<String, dynamic> task);
  Future<void> completeTask(int id);
  Future<void> deleteTask(int id);
}
