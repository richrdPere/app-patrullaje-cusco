import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

class TrackingState extends Equatable {
  // =====================================================
  // ESTADO DEL TRACKING
  // =====================================================
  final bool isTracking;
  final bool isLoading;

  // =====================================================
  // CONTEXTO DEL PATRULLAJE
  // =====================================================
  final int? patrullajeId;

  // =====================================================
  // ÚLTIMA UBICACIÓN
  // =====================================================
  final LocationEntity? lastLocation;

  // =====================================================
  // ERROR
  // =====================================================
  final String? error;

  const TrackingState({
    this.isTracking = false,
    this.isLoading = false,
    this.patrullajeId,
    this.lastLocation,
    this.error,
  });

  // =====================================================
  // HELPERS
  // =====================================================
  bool get tienePatrullaje => patrullajeId != null;

  bool get tieneUbicacion => lastLocation != null;

  bool get tieneError => error != null && error!.trim().isNotEmpty;

  bool get estaListo =>
      isTracking && patrullajeId != null && lastLocation != null;

  // =====================================================
  // COPY WITH
  // =====================================================
  TrackingState copyWith({
    bool? isTracking,
    bool? isLoading,

    int? patrullajeId,
    bool clearPatrullajeId = false,

    LocationEntity? lastLocation,
    bool clearLastLocation = false,

    String? error,
    bool clearError = false,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,

      patrullajeId: clearPatrullajeId
          ? null
          : patrullajeId ?? this.patrullajeId,

      lastLocation: clearLastLocation
          ? null
          : lastLocation ?? this.lastLocation,

      error: clearError ? null : error ?? this.error,
    );
  }

  // =====================================================
  // RESET
  // =====================================================
  TrackingState reset() {
    return const TrackingState();
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
