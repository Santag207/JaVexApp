/// Interface que define todos los métodos del API.
/// Cuando tengan el backend real, solo necesitan crear otra implementación
/// de esta misma interface apuntando al servidor real.
abstract class ApiService {
  /// Inicia sesión con Supabase Auth (email + password). Si las credenciales
  /// son válidas, devuelve el perfil de la tabla `users` vinculado por `auth_id`.
  /// Retorna null si las credenciales son incorrectas o no hay perfil asociado.
  Future<Map<String, dynamic>?> signInWithPassword(String email, String password);

  /// Cierra la sesión de Supabase Auth.
  Future<void> signOut();

  /// Si hay una sesión de Supabase Auth activa, devuelve el perfil de `users`
  /// vinculado al usuario autenticado; null si no hay sesión o perfil.
  Future<Map<String, dynamic>?> currentUserProfile();

  /// Refresh token de la sesión activa (se persiste para el desbloqueo
  /// biométrico). Null si no hay sesión.
  String? currentRefreshToken();

  /// UUID (auth.uid()) del usuario autenticado, o null si no hay sesión.
  String? currentAuthUserId();

  /// Email del usuario autenticado, o null si no hay sesión.
  String? currentAuthEmail();

  /// Restaura una sesión a partir de un refresh token (usado tras verificar
  /// la huella/rostro). Devuelve true si la sesión se restauró correctamente.
  Future<bool> restoreSession(String refreshToken);

  /// Cambia la contraseña del usuario autenticado. Reautentica con
  /// [currentPassword] para verificarla y luego aplica [newPassword].
  /// Lanza una excepción si la contraseña actual es incorrecta.
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Crea un nuevo usuario (solo superuser) invocando la Edge Function
  /// `create-user`. [payload] incluye email, password, nombre y apellidos.
  Future<void> createUser(Map<String, dynamic> payload);

  /// Obtiene todas las tareas. Opcionalmente filtra por subsistema y/o estado
  /// ('pendiente' | 'completada'). Incluye los responsables embebidos.
  Future<List<Map<String, dynamic>>> getTasks({String? subsistema, String? estado});

  /// Crea una nueva tarea. Si [task] incluye una lista `responsables`
  /// (IDs de `users`), los registra en `task_responsables`.
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> task);

  /// Marca una tarea como completada (estado='completada', completada_en=now()).
  Future<void> completeTask(int id);

  /// Elimina (borra físicamente) una tarea por su ID.
  Future<void> deleteTask(int id);

  /// Obtiene la lista de miembros activos.
  Future<List<Map<String, dynamic>>> getMembers();

  /// Obtiene la lista completa de usuarios (perfiles de la tabla `users`).
  Future<List<Map<String, dynamic>>> getUsers();

  /// Obtiene un usuario por su ID.
  Future<Map<String, dynamic>> getUser(int id);

  /// Actualiza un usuario por su ID.
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data);

  /// Obtiene la lista de piezas disponibles en inventario.
  Future<List<Map<String, dynamic>>> getItems();

  /// Obtiene la lista de piezas registradas (apartadas).
  Future<List<Map<String, dynamic>>> getRegisteredItems();

  /// Obtiene la lista de subsistemas disponibles.
  Future<List<Map<String, dynamic>>> getSubsistemas();

  // ==================== Formularios ====================

  /// Sube los bytes de un archivo al bucket `form-files` en la ruta indicada.
  /// Devuelve la ruta de almacenamiento (`storage_path`).
  Future<String> uploadFormFile(String storagePath, List<int> bytes);

  /// Registra en la tabla `form_file_submissions` los metadatos de un archivo
  /// subido. `user_auth_id` lo asigna el backend (default `auth.uid()`).
  Future<Map<String, dynamic>> createFormFileSubmission(
      Map<String, dynamic> submission);

  /// Lista los registros de archivos subidos por el usuario autenticado para
  /// un tipo de formulario (filtrado por RLS = `auth.uid()`).
  Future<List<Map<String, dynamic>>> getFormFileSubmissions(String formType);

  /// Registra en la tabla `form_text_submissions` las respuestas de un
  /// formulario de texto. `user_auth_id` lo asigna el backend (default
  /// `auth.uid()`). `answers` es un objeto con las respuestas por pregunta.
  Future<Map<String, dynamic>> createFormTextSubmission(
      Map<String, dynamic> submission);

  /// Genera una URL firmada temporal para descargar/ver un archivo del bucket
  /// `form-files` a partir de su `storage_path`.
  Future<String> createSignedFormFileUrl(String storagePath);

  // ============ Formularios modulares (definiciones) ============

  /// Lista los formularios configurables (tabla `forms`), ordenados por `orden`.
  Future<List<Map<String, dynamic>>> getForms();

  /// Lista los campos de un formulario (tabla `form_fields`), por `orden`.
  Future<List<Map<String, dynamic>>> getFormFields(int formId);

  /// Crea un formulario. Solo superuser (RLS). Devuelve el registro creado.
  Future<Map<String, dynamic>> createForm(Map<String, dynamic> form);

  /// Actualiza un formulario por su id. Solo superuser (RLS).
  Future<Map<String, dynamic>> updateForm(int id, Map<String, dynamic> data);

  /// Elimina un formulario por su id (borra en cascada sus campos). Superuser.
  Future<void> deleteForm(int id);

  /// Crea un campo de formulario. Solo superuser (RLS).
  Future<Map<String, dynamic>> createField(Map<String, dynamic> field);

  /// Actualiza un campo por su id. Solo superuser (RLS).
  Future<Map<String, dynamic>> updateField(int id, Map<String, dynamic> data);

  /// Elimina un campo por su id. Solo superuser (RLS).
  Future<void> deleteField(int id);
}
