import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

// Iniciar patrullaje
class StartPatrullajeEvent extends TrackingEvent {
  final int patrullajeId;

  const StartPatrullajeEvent(this.patrullajeId);

  @override
  List<Object?> get props => [patrullajeId];
}

// Finalizar patrullaje
class EndPatrullajeEvent extends TrackingEvent {
  final int patrullajeId;

  const EndPatrullajeEvent(this.patrullajeId);

  @override
  List<Object?> get props => [patrullajeId];
}

// Iniciar tracking
class StartTrackingEvent extends TrackingEvent {}

// Detener tracking
class StopTrackingEvent extends TrackingEvent {}

class LocationUpdatedEvent extends TrackingEvent {
  final LocationEntity location;
  const LocationUpdatedEvent(this.location);
}
