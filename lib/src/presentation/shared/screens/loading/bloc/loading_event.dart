import 'package:equatable/equatable.dart';

abstract class LoadingEvent extends Equatable {
  const LoadingEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia la carga de información inicial
class LoadingStarted extends LoadingEvent {
  const LoadingStarted();
}
