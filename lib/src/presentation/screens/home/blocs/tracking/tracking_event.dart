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
}

// Detener tracking
class StopTrackingEvent extends TrackingEvent {}

// Actualizar ubicacion
class LocationUpdatedEvent extends TrackingEvent {
  final LocationEntity location;
  const LocationUpdatedEvent(this.location);
}


