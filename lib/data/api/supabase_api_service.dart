import 'package:supabase_flutter/supabase_flutter.dart';
import '../api_service.dart';

/// Implementación del [ApiService] usando el cliente postgrest de Supabase.
///
/// Es la fuente de datos de la app (reemplazó al json-server). Las columnas
/// en Supabase usan exactamente las mismas claves camelCase que las entidades,
/// por lo que lo que devuelve postgrest encaja directo en los `fromJson`,
/// sin tocar repositorios ni modelos.
class SupabaseApiService implements ApiService {
  final SupabaseClient _client;

  SupabaseApiService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  List<Map<String, dynamic>> _asList(dynamic data) =>
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // El password se valida en el cliente (replica el flujo del mock).
      final data = await _client
          .from('users')
          .select()
          .eq('email', email)
          .limit(1);
      if (data.isNotEmpty) {
        final user = Map<String, dynamic>.from(data.first);
        if (user['password'] == password) {
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTasks({String? subsistema}) async {
    try {
      final data = subsistema != null
          ? await _client.from('tasks').select().eq('subsistema', subsistema)
          : await _client.from('tasks').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener tareas: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    try {
      // El id lo genera la identidad de Postgres: no debe venir en el payload.
      final payload = Map<String, dynamic>.from(task)..remove('id');
      final data =
          await _client.from('tasks').insert(payload).select().single();
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error al crear tarea: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _client.from('tasks').delete().eq('id', id);
    } catch (e) {
      print('Error al eliminar tarea: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final data = await _client.from('members').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener miembros: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      final data = await _client.from('users').select().eq('id', id).single();
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error al obtener usuario: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUser(
      int id, Map<String, dynamic> data) async {
    try {
      // El id es inmutable (identidad): nunca debe ir en el update.
      final payload = Map<String, dynamic>.from(data)..remove('id');
      final result = await _client
          .from('users')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error al actualizar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getItems() async {
    try {
      final data = await _client.from('items').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener items: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRegisteredItems() async {
    try {
      final data = await _client.from('registeredItems').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener items registrados: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubsistemas() async {
    try {
      final data = await _client.from('subsistemas').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener subsistemas: $e');
      return [];
    }
  }
}
