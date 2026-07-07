import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Mientras se valida la sesión
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Existe una sesión almacenada
class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

/// No existe una sesión
class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

/// Error inesperado
class SplashFailure extends SplashState {
  final String message;

  const SplashFailure(this.message);

  @override
  List<Object?> get props => [message];
}
