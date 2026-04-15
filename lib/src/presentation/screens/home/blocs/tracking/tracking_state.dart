import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

class TrackingState extends Equatable {
  final bool isTracking;
  final bool isLoading;

  final int? patrullajeId;
  final LocationEntity? lastLocation;

  final String? error;

  const TrackingState({
    this.isTracking = false,
    this.isLoading = false,
    this.patrullajeId,
    this.lastLocation,
    this.error,
  });

  TrackingState copyWith({
    bool? isTracking,
    bool? isLoading,
    int? patrullajeId,
    LocationEntity? lastLocation,
    String? error,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      lastLocation: lastLocation ?? this.lastLocation,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isTracking,
    isLoading,
    patrullajeId,
    lastLocation,
    error,
  ];
}
