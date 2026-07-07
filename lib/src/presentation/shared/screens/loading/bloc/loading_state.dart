import 'package:equatable/equatable.dart';

abstract class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class LoadingInitial extends LoadingState {
  const LoadingInitial();
}

/// Cargando información
class LoadingInProgress extends LoadingState {
  const LoadingInProgress();
}

/// Toda la información cargada
class LoadingSuccess extends LoadingState {
  const LoadingSuccess();
}

/// Ocurrió un error
class LoadingFailure extends LoadingState {
  final String message;

  const LoadingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
