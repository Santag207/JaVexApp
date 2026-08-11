import 'dart:typed_data';

import '../entities/form_definition.dart';
import '../entities/form_field_def.dart';
import '../entities/form_file_submission.dart';

abstract class FormsRepository {
  /// Sube un archivo al storage y registra sus metadatos, referenciándolo al
  /// usuario autenticado. Devuelve el registro creado.
  Future<FormFileSubmission> submitFile({
    required String formType,
    required String sectionKey,
    required String fileName,
    required Uint8List bytes,
  });

  /// Lista los archivos que el usuario autenticado ya subió para un formulario.
  Future<List<FormFileSubmission>> getSubmissions(String formType);

  /// Registra las respuestas de un formulario de texto, referenciadas al
  /// usuario autenticado. `answers` es un mapa pregunta → respuesta.
  Future<void> submitText({
    required String formType,
    required Map<String, dynamic> answers,
  });

  /// Sube un archivo (campo de tipo `archivo` en un formulario modular) y
  /// devuelve la referencia `{file_name, storage_path}` para guardarla en las
  /// respuestas.
  Future<Map<String, String>> uploadFieldFile({
    required String formKey,
    required String fieldKey,
    required String fileName,
    required Uint8List bytes,
  });

  /// Genera una URL firmada temporal para ver/descargar un archivo por su path.
  Future<String> signedFileUrl(String storagePath);

  // ============ Definiciones (formularios modulares) ============

  Future<List<FormDefinition>> getForms();
  Future<List<FormFieldDef>> getFormFields(int formId);
  Future<FormDefinition> createForm(FormDefinition form);
  Future<FormDefinition> updateForm(int id, Map<String, dynamic> data);
  Future<void> deleteForm(int id);
  Future<FormFieldDef> createField(FormFieldDef field);
  Future<FormFieldDef> updateField(int id, Map<String, dynamic> data);
  Future<void> deleteField(int id);
}
