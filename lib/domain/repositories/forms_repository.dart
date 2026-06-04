import 'dart:typed_data';

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
}
