import 'package:equatable/equatable.dart';

abstract class FormsState extends Equatable {
  const FormsState();

  @override
  List<Object?> get props => [];
}

class FormsInitial extends FormsState {
  const FormsInitial();
}

class FormsUploading extends FormsState {
  const FormsUploading();
}

class FormsSuccess extends FormsState {
  final int uploadedCount;

  const FormsSuccess({required this.uploadedCount});

  @override
  List<Object?> get props => [uploadedCount];
}

class FormsError extends FormsState {
  final String message;

  const FormsError({required this.message});

  @override
  List<Object?> get props => [message];
}
