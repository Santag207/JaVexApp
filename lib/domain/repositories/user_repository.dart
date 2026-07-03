import '../entities/member.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(int id);
  Future<User> updateUser(int id, Map<String, dynamic> data);
  Future<List<Member>> getMembers();
  Future<List<User>> getUsers();
}
