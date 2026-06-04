import 'dart:typed_data';

import '../../domain/entities/form_file_submission.dart';
import '../../domain/repositories/forms_repository.dart';
import '../api_service.dart';

class FormsRepositoryImpl implements FormsRepository {
  final ApiService _apiService;

  FormsRepositoryImpl(this._apiService);

  @override
  Future<FormFileSubmission> submitFile({
    required String formType,
    required String sectionKey,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final email = _apiService.currentAuthEmail();
    if (email == null) {
      throw StateError('No hay sesión activa para subir archivos');
    }

    // Ruta: {email}/{form_type}/{section_key}/{timestamp}_{file_name}
    // El prefijo con el email identifica de forma legible la carpeta de cada
    // usuario; las políticas de Storage lo validan contra el email del JWT.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '$email/$formType/$sectionKey/${timestamp}_$safeName';

    await _apiService.uploadFormFile(storagePath, bytes);

    final result = await _apiService.createFormFileSubmission({
      'form_type': formType,
      'section_key': sectionKey,
      'file_name': fileName,
      'storage_path': storagePath,
    });
    return FormFileSubmission.fromJson(result);
  }

  @override
  Future<List<FormFileSubmission>> getSubmissions(String formType) async {
    final result = await _apiService.getFormFileSubmissions(formType);
    return result.map((json) => FormFileSubmission.fromJson(json)).toList();
  }

  @override
  Future<void> submitText({
    required String formType,
    required Map<String, dynamic> answers,
  }) async {
    await _apiService.createFormTextSubmission({
      'form_type': formType,
      'answers': answers,
    });
  }
}
