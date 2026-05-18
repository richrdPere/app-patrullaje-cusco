import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';

abstract class HomeEvent {}

// HTTP
class LoadPatrullajeActivo extends HomeEvent {}

// SOCKET
class InitSocketListeners extends HomeEvent {}

class NuevoPatrullajeRecibido extends HomeEvent {
  final PatrullajeModel patrullaje;

  NuevoPatrullajeRecibido(this.patrullaje);
}

class PatrullajeActualizadoRecibido extends HomeEvent {
  final PatrullajeModel patrullaje;
  PatrullajeActualizadoRecibido(this.patrullaje);
}

// USER
class AceptarPatrullaje extends HomeEvent {
  final int patrullajeId;

  AceptarPatrullaje(this.patrullajeId);
}

class FinalizarPatrullaje extends HomeEvent {
  final int patrullajeId;

  FinalizarPatrullaje(this.patrullajeId);
}
