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
  final String message;

  const FormsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class FormsError extends FormsState {
  final String message;

  const FormsError({required this.message});

  @override
  List<Object?> get props => [message];
}
