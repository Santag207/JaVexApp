import 'package:equatable/equatable.dart';

/// Registro de un archivo subido en un formulario de tipo "archivo"
/// (p. ej. el Sistema de Gestión Documental), referenciado al usuario
/// autenticado mediante `user_auth_id` (= auth.uid()).
class FormFileSubmission extends Equatable {
  final int id;
  final String userAuthId;
  final String formType;
  final String sectionKey;
  final String fileName;
  final String storagePath;
  final String uploadedAt;

  const FormFileSubmission({
    required this.id,
    required this.userAuthId,
    required this.formType,
    required this.sectionKey,
    required this.fileName,
    required this.storagePath,
    required this.uploadedAt,
  });

  factory FormFileSubmission.fromJson(Map<String, dynamic> json) {
    return FormFileSubmission(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userAuthId: json['user_auth_id'] as String? ?? '',
      formType: json['form_type'] as String? ?? '',
      sectionKey: json['section_key'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      storagePath: json['storage_path'] as String? ?? '',
      uploadedAt: json['uploaded_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_auth_id': userAuthId,
      'form_type': formType,
      'section_key': sectionKey,
      'file_name': fileName,
      'storage_path': storagePath,
      'uploaded_at': uploadedAt,
    };
  }

  @override
  List<Object?> get props => [id, storagePath];
}
