import 'dart:typed_data';

import '../../domain/entities/form_definition.dart';
import '../../domain/entities/form_field_def.dart';
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

  @override
  Future<Map<String, String>> uploadFieldFile({
    required String formKey,
    required String fieldKey,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final email = _apiService.currentAuthEmail() ?? 'anon';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '$email/$formKey/$fieldKey/${timestamp}_$safeName';
    await _apiService.uploadFormFile(storagePath, bytes);
    return {'file_name': fileName, 'storage_path': storagePath};
  }

  @override
  Future<String> signedFileUrl(String storagePath) =>
      _apiService.createSignedFormFileUrl(storagePath);

  // ============ Definiciones (formularios modulares) ============

  @override
  Future<List<FormDefinition>> getForms() async {
    final result = await _apiService.getForms();
    return result.map((json) => FormDefinition.fromJson(json)).toList();
  }

  @override
  Future<List<FormFieldDef>> getFormFields(int formId) async {
    final result = await _apiService.getFormFields(formId);
    return result.map((json) => FormFieldDef.fromJson(json)).toList();
  }

  @override
  Future<FormDefinition> createForm(FormDefinition form) async {
    final result = await _apiService.createForm(form.toPayload());
    return FormDefinition.fromJson(result);
  }

  @override
  Future<FormDefinition> updateForm(int id, Map<String, dynamic> data) async {
    final result = await _apiService.updateForm(id, data);
    return FormDefinition.fromJson(result);
  }

  @override
  Future<void> deleteForm(int id) => _apiService.deleteForm(id);

  @override
  Future<FormFieldDef> createField(FormFieldDef field) async {
    final result = await _apiService.createField(field.toPayload());
    return FormFieldDef.fromJson(result);
  }

  @override
  Future<FormFieldDef> updateField(int id, Map<String, dynamic> data) async {
    final result = await _apiService.updateField(id, data);
    return FormFieldDef.fromJson(result);
  }

  @override
  Future<void> deleteField(int id) => _apiService.deleteField(id);
}
