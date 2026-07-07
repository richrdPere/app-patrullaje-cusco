import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Evento inicial del Splash
class SplashStarted extends SplashEvent {
  const SplashStarted();
}
