import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Un archivo seleccionado por el usuario, listo para subir, asociado a una
/// sección del formulario.
class FormFileUpload extends Equatable {
  final String sectionKey;
  final String fileName;
  final Uint8List bytes;

  const FormFileUpload({
    required this.sectionKey,
    required this.fileName,
    required this.bytes,
  });

  @override
  List<Object?> get props => [sectionKey, fileName];
}

abstract class FormsEvent extends Equatable {
  const FormsEvent();

  @override
  List<Object?> get props => [];
}

/// Sube todos los archivos seleccionados de un formulario de tipo archivo.
class SubmitFormFilesRequested extends FormsEvent {
  final String formType;
  final List<FormFileUpload> files;

  const SubmitFormFilesRequested({
    required this.formType,
    required this.files,
  });

  @override
  List<Object?> get props => [formType, files];
}

/// Envía las respuestas de un formulario de texto.
class SubmitFormTextRequested extends FormsEvent {
  final String formType;
  final Map<String, dynamic> answers;

  const SubmitFormTextRequested({
    required this.formType,
    required this.answers,
  });

  @override
  List<Object?> get props => [formType, answers];
}
