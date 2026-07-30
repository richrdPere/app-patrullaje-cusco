import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/tracking_transmission_status.dart';

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
  // ERROR GENERAL DEL TRACKING
  // =====================================================
  final String? error;

  // =====================================================
  // ESTADO DE TRANSMISIÓN
  // =====================================================
  final TrackingTransmissionStatus transmissionStatus;

  /// Fecha y hora de la última confirmación recibida
  /// desde el backend.
  final DateTime? lastTransmissionAt;

  /// Mensaje relacionado con el último envío.
  final String? transmissionMessage;

  /// Cantidad de errores consecutivos al transmitir.
  final int consecutiveFailures;

  const TrackingState({
    this.isTracking = false,
    this.isLoading = false,
    this.patrullajeId,
    this.lastLocation,
    this.error,
    this.transmissionStatus = TrackingTransmissionStatus.idle,
    this.lastTransmissionAt,
    this.transmissionMessage,
    this.consecutiveFailures = 0,
  });

  // =====================================================
  // HELPERS GENERALES
  // =====================================================
  bool get tienePatrullaje => patrullajeId != null;

  bool get tieneUbicacion => lastLocation != null;

  bool get tieneError => error != null && error!.trim().isNotEmpty;

  bool get estaListo =>
      isTracking && patrullajeId != null && lastLocation != null;

  // =====================================================
  // HELPERS DE TRANSMISIÓN
  // =====================================================

  /// Indica que actualmente se está intentando enviar
  /// una ubicación al servidor.
  bool get estaTransmitiendo =>
      transmissionStatus == TrackingTransmissionStatus.sending;

  /// Indica que el backend confirmó correctamente
  /// la última ubicación.
  bool get transmisionExitosa =>
      transmissionStatus == TrackingTransmissionStatus.transmitted ||
      transmissionStatus == TrackingTransmissionStatus.omitted;

  /// Indica que el último intento de transmisión falló.
  bool get transmisionFallida =>
      transmissionStatus == TrackingTransmissionStatus.failed;

  /// Indica si ya existe al menos una confirmación
  /// del servidor.
  bool get tieneTransmisionConfirmada => lastTransmissionAt != null;

  /// Indica si la última confirmación es reciente.
  ///
  /// Este helper permite detectar que el tracking pudo
  /// haberse detenido aunque anteriormente haya enviado
  /// una ubicación correctamente.
  bool get transmisionEsReciente {
    final fecha = lastTransmissionAt;

    if (fecha == null) return false;

    return DateTime.now().difference(fecha) <= const Duration(seconds: 30);
  }

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

    TrackingTransmissionStatus? transmissionStatus,

    DateTime? lastTransmissionAt,
    bool clearLastTransmissionAt = false,

    String? transmissionMessage,
    bool clearTransmissionMessage = false,

    int? consecutiveFailures,

    bool clearTransmission = false,
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

      transmissionStatus: clearTransmission
          ? TrackingTransmissionStatus.idle
          : transmissionStatus ?? this.transmissionStatus,

      lastTransmissionAt: clearTransmission || clearLastTransmissionAt
          ? null
          : lastTransmissionAt ?? this.lastTransmissionAt,

      transmissionMessage: clearTransmission || clearTransmissionMessage
          ? null
          : transmissionMessage ?? this.transmissionMessage,

      consecutiveFailures: clearTransmission
          ? 0
          : consecutiveFailures ?? this.consecutiveFailures,
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
    transmissionStatus,
    lastTransmissionAt,
    transmissionMessage,
    consecutiveFailures,
  ];
}
