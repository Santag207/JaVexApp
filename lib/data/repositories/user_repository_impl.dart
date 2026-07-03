import '../../domain/entities/member.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../api_service.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User> getUser(int id) async {
    final result = await _apiService.getUser(id);
    return User.fromJson(result);
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final result = await _apiService.updateUser(id, data);
    return User.fromJson(result);
  }

  @override
  Future<List<Member>> getMembers() async {
    final result = await _apiService.getMembers();
    return result.map((json) => Member.fromJson(json)).toList();
  }

  @override
  Future<List<User>> getUsers() async {
    final result = await _apiService.getUsers();
    return result.map((json) => User.fromJson(json)).toList();
  }
}
