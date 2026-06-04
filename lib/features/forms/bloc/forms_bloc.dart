import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/forms_repository.dart';
import 'forms_event.dart';
import 'forms_state.dart';

class FormsBloc extends Bloc<FormsEvent, FormsState> {
  final FormsRepository formsRepository;

  FormsBloc({required this.formsRepository}) : super(const FormsInitial()) {
    on<SubmitFormFilesRequested>(_onSubmitFormFilesRequested);
  }

  Future<void> _onSubmitFormFilesRequested(
    SubmitFormFilesRequested event,
    Emitter<FormsState> emit,
  ) async {
    if (event.files.isEmpty) {
      emit(const FormsError(message: 'No hay archivos seleccionados'));
      return;
    }

    emit(const FormsUploading());

    try {
      for (final file in event.files) {
        await formsRepository.submitFile(
          formType: event.formType,
          sectionKey: file.sectionKey,
          fileName: file.fileName,
          bytes: file.bytes,
        );
      }
      emit(FormsSuccess(uploadedCount: event.files.length));
    } catch (e) {
      emit(FormsError(message: 'Error al subir archivos: ${e.toString()}'));
    }
  }
}
