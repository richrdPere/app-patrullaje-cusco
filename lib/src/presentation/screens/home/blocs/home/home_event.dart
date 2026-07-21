import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

abstract class HomeEvent {}

// HTTP
class LoadPatrullajeActivo extends HomeEvent {}

// SOCKET
class InitSocketListeners extends HomeEvent {}

class NuevoPatrullajeRecibido extends HomeEvent {
  final PatrullajeData patrullaje;

  NuevoPatrullajeRecibido(this.patrullaje);
}

class PatrullajeActualizadoRecibido extends HomeEvent {
  final PatrullajeData patrullaje;
  PatrullajeActualizadoRecibido(this.patrullaje);
}

// USER
class AceptarPatrullaje extends HomeEvent {
  final int patrullajeId;

  AceptarPatrullaje(this.patrullajeId);
}

class FinalizarPatrullaje extends HomeEvent {
  final int patrullajeId;
  final String? observacionFinal;

  FinalizarPatrullaje({required this.patrullajeId, this.observacionFinal});
}

class LimpiarPatrullajeFinalizado extends HomeEvent {}
