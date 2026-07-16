import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

// Iniciar tracking
class StartTrackingEvent extends TrackingEvent {
  final int patrullajeId;

  const StartTrackingEvent(this.patrullajeId);

  @override
  List<Object?> get props => [patrullajeId];
}

// Detener tracking
class StopTrackingEvent extends TrackingEvent {
  const StopTrackingEvent();
}

// Actualizar ubicacion
class LocationUpdatedEvent extends TrackingEvent {
  final LocationEntity location;
  const LocationUpdatedEvent(this.location);

  @override
  List<Object?> get props => [location];
}

// =====================================================
// EVENTOS INTERNOS
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
