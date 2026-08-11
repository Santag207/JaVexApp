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

/// Un archivo seleccionado para un campo de tipo `archivo` de un formulario
/// modular.
class FieldFileUpload extends Equatable {
  final String fieldKey;
  final String fileName;
  final Uint8List bytes;

  const FieldFileUpload({
    required this.fieldKey,
    required this.fileName,
    required this.bytes,
  });

  @override
  List<Object?> get props => [fieldKey, fileName];
}

/// Envía un formulario modular: sube los archivos de sus campos `archivo`,
/// mezcla las referencias en `answers` y registra la respuesta.
class SubmitDynamicFormRequested extends FormsEvent {
  final String formKey;
  final Map<String, dynamic> answers;
  final List<FieldFileUpload> files;

  const SubmitDynamicFormRequested({
    required this.formKey,
    required this.answers,
    this.files = const [],
  });

  @override
  List<Object?> get props => [formKey, answers, files];
}
