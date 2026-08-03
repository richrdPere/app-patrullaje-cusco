import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

// =====================================================
// INICIAR TRACKING
// =====================================================
class StartTrackingEvent extends TrackingEvent {
  final int patrullajeId;

  const StartTrackingEvent(this.patrullajeId);

  @override
  List<Object?> get props => [patrullajeId];
}

// =====================================================
// DETENER TRACKING
// =====================================================
class StopTrackingEvent extends TrackingEvent {
  const StopTrackingEvent();
}

// =====================================================
// ACTUALIZAR UBICACIÓN
// =====================================================
class LocationUpdatedEvent extends TrackingEvent {
  final LocationEntity location;

  const LocationUpdatedEvent(this.location);

  @override
  List<Object?> get props => [location];
}

// =====================================================
// EVENTOS INTERNOS DEL STREAM GPS
// =====================================================
class TrackingStreamErrorEvent extends TrackingEvent {
  final int patrullajeId;
  final String message;

  const TrackingStreamErrorEvent({
    required this.patrullajeId,
    required this.message,
  });

  @override
  List<Object?> get props => [patrullajeId, message];
}

class TrackingStreamCompletedEvent extends TrackingEvent {
  final int patrullajeId;

  const TrackingStreamCompletedEvent({required this.patrullajeId});

  @override
  List<Object?> get props => [patrullajeId];
}

// =====================================================
// EVENTOS INTERNOS DE TRANSMISIÓN
// =====================================================

/// Se emite inmediatamente antes de enviar una ubicación
/// por Socket.IO.
class TrackingSendStartedEvent extends TrackingEvent {
  final LocationEntity location;

  const TrackingSendStartedEvent({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Se emite cuando el backend confirma mediante ACK que
/// recibió correctamente la ubicación.
class TrackingSendSuccessEvent extends TrackingEvent {
  final DateTime confirmedAt;
  final String message;

  /// Indica que el servidor recibió el punto, pero decidió
  /// no guardarlo por no existir desplazamiento significativo.
  final bool omitted;
  final bool storedOffline;

  const TrackingSendSuccessEvent({
    required this.confirmedAt,
    required this.message,
    this.omitted = false,
    this.storedOffline = false,
  });

  @override
  List<Object?> get props => [confirmedAt, message, omitted, storedOffline];
}

/// Se emite cuando la ubicación no pudo transmitirse,
/// el socket estaba desconectado o el backend no respondió.
class TrackingSendFailedEvent extends TrackingEvent {
  final String message;

  const TrackingSendFailedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}
