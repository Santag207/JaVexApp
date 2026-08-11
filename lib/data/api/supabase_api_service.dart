import 'dart:typed_data';

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
  Future<Map<String, dynamic>?> signInWithPassword(
      String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final authId = res.user?.id;
      if (authId == null) return null;
      return _profileByAuthId(authId);
    } on AuthException catch (e) {
      // Credenciales inválidas u otros errores de Auth: el flujo de login
      // los trata como "credenciales incorrectas".
      print('Error en signInWithPassword: ${e.message}');
      return null;
    } catch (e) {
      print('Error en signInWithPassword: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error en signOut: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> currentUserProfile() async {
    final authId = _client.auth.currentUser?.id;
    if (authId == null) return null;
    return _profileByAuthId(authId);
  }

  @override
  String? currentRefreshToken() => _client.auth.currentSession?.refreshToken;

  @override
  String? currentAuthUserId() => _client.auth.currentUser?.id;

  @override
  String? currentAuthEmail() => _client.auth.currentUser?.email;

  @override
  Future<bool> restoreSession(String refreshToken) async {
    try {
      final res = await _client.auth.setSession(refreshToken);
      return res.session != null;
    } catch (e) {
      print('Error al restaurar sesión: $e');
      return false;
    }
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) {
      throw StateError('No hay una sesión activa.');
    }
    // 1) Verificar la contraseña actual reautenticando.
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      throw Exception('La contraseña actual es incorrecta.');
    }
    // 2) Aplicar la nueva contraseña.
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> createUser(Map<String, dynamic> payload) async {
    final res = await _client.functions.invoke('create-user', body: payload);
    if (res.status != 200 && res.status != 201) {
      final data = res.data;
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'No se pudo crear el usuario (código ${res.status}).';
      throw Exception(msg);
    }
  }

  /// Busca el perfil de la tabla `users` vinculado a la cuenta de Auth.
  Future<Map<String, dynamic>?> _profileByAuthId(String authId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();
      return data == null ? null : Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error al obtener perfil por auth_id: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTasks(
      {String? subsistema, String? estado}) async {
    try {
      // Embebe los responsables (task_responsables) en cada tarea.
      var query = _client.from('tasks').select('*, task_responsables(user_id)');
      if (subsistema != null) query = query.eq('subsistema', subsistema);
      if (estado != null) query = query.eq('estado', estado);
      final data = await query;
      return _asList(data);
    } catch (e) {
      print('Error al obtener tareas: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    try {
      // El id lo genera la identidad de Postgres y los responsables van en su
      // propia tabla: ninguno debe ir en el payload de `tasks`.
      final responsables = (task['responsables'] as List?)
              ?.map((e) => e is int ? e : int.parse(e.toString()))
              .toList() ??
          const <int>[];
      final payload = Map<String, dynamic>.from(task)
        ..remove('id')
        ..remove('responsables');
      final data =
          await _client.from('tasks').insert(payload).select().single();
      final created = Map<String, dynamic>.from(data);

      if (responsables.isNotEmpty) {
        final taskId = created['id'];
        final rows = responsables
            .map((uid) => {'task_id': taskId, 'user_id': uid})
            .toList();
        await _client.from('task_responsables').insert(rows);
        // Reflejar los responsables recién creados en el objeto devuelto.
        created['task_responsables'] =
            responsables.map((uid) => {'user_id': uid}).toList();
      }
      return created;
    } catch (e) {
      print('Error al crear tarea: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeTask(int id) async {
    try {
      await _client.from('tasks').update({
        'estado': 'completada',
        'completada_en': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      print('Error al completar tarea: $e');
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
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final data = await _client.from('users').select();
      return _asList(data);
    } catch (e) {
      print('Error al obtener usuarios: $e');
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

  // ==================== Formularios ====================

  static const String _formsBucket = 'form-files';

  @override
  Future<String> uploadFormFile(String storagePath, List<int> bytes) async {
    try {
      await _client.storage.from(_formsBucket).uploadBinary(
            storagePath,
            Uint8List.fromList(bytes),
            fileOptions: const FileOptions(upsert: true),
          );
      return storagePath;
    } catch (e) {
      print('Error al subir archivo de formulario: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createFormFileSubmission(
      Map<String, dynamic> submission) async {
    try {
      // El id (identidad) y user_auth_id (default auth.uid()) los pone el backend.
      final payload = Map<String, dynamic>.from(submission)
        ..remove('id')
        ..remove('user_auth_id');
      final data = await _client
          .from('form_file_submissions')
          .insert(payload)
          .select()
          .single();
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error al registrar archivo de formulario: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFormFileSubmissions(
      String formType) async {
    try {
      final data = await _client
          .from('form_file_submissions')
          .select()
          .eq('form_type', formType);
      return _asList(data);
    } catch (e) {
      print('Error al obtener archivos de formulario: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createFormTextSubmission(
      Map<String, dynamic> submission) async {
    try {
      // El id (identidad) y user_auth_id (default auth.uid()) los pone el backend.
      final payload = Map<String, dynamic>.from(submission)
        ..remove('id')
        ..remove('user_auth_id');
      final data = await _client
          .from('form_text_submissions')
          .insert(payload)
          .select()
          .single();
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error al registrar respuestas de formulario: $e');
      rethrow;
    }
  }

  @override
  Future<String> createSignedFormFileUrl(String storagePath) async {
    // URL firmada válida por 1 hora.
    return _client.storage.from(_formsBucket).createSignedUrl(storagePath, 3600);
  }

  // ============ Formularios modulares (definiciones) ============

  @override
  Future<List<Map<String, dynamic>>> getForms() async {
    try {
      final data = await _client.from('forms').select().order('orden');
      return _asList(data);
    } catch (e) {
      print('Error al obtener formularios: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFormFields(int formId) async {
    try {
      final data = await _client
          .from('form_fields')
          .select()
          .eq('form_id', formId)
          .order('orden');
      return _asList(data);
    } catch (e) {
      print('Error al obtener campos del formulario: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createForm(Map<String, dynamic> form) async {
    final payload = Map<String, dynamic>.from(form)..remove('id');
    final data = await _client.from('forms').insert(payload).select().single();
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>> updateForm(
      int id, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)..remove('id');
    final result =
        await _client.from('forms').update(payload).eq('id', id).select().single();
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> deleteForm(int id) async {
    await _client.from('forms').delete().eq('id', id);
  }

  @override
  Future<Map<String, dynamic>> createField(Map<String, dynamic> field) async {
    final payload = Map<String, dynamic>.from(field)..remove('id');
    final data =
        await _client.from('form_fields').insert(payload).select().single();
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>> updateField(
      int id, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)..remove('id');
    final result = await _client
        .from('form_fields')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> deleteField(int id) async {
    await _client.from('form_fields').delete().eq('id', id);
  }
}
