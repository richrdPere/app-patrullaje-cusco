import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingUseCases trackingUseCases;

  StreamSubscription<LocationEntity>? _gpsSubscription;

  TrackingBloc(this.trackingUseCases) : super(const TrackingState()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<LocationUpdatedEvent>(_onLocationUpdated);

    // Eventos internos del stream.
    on<TrackingStreamErrorEvent>(_onTrackingStreamError);
    on<TrackingStreamCompletedEvent>(_onTrackingStreamCompleted);
  }

  // =====================================================
  // 1. INICIAR TRACKING
  // =====================================================
  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final mismoPatrullaje =
        state.isTracking &&
        _gpsSubscription != null &&
        state.patrullajeId == event.patrullajeId;

    if (mismoPatrullaje) {
      debugPrint(
        '⚠️ Tracking ya activo para el patrullaje '
        '${event.patrullajeId}',
      );

      return;
    }

    // Siempre cancela cualquier suscripción anterior antes
    // de crear una nueva.
    if (_gpsSubscription != null) {
      debugPrint('🔄 Cancelando stream GPS anterior...');

      await _gpsSubscription!.cancel();
      _gpsSubscription = null;
    }

    debugPrint(
      '📍 Iniciando tracking para patrullaje '
      '${event.patrullajeId}...',
    );

    emit(
      state.copyWith(
        isLoading: true,
        isTracking: false,
        patrullajeId: event.patrullajeId,
        clearLastLocation: true,
        clearError: true,
      ),
    );

    try {
      debugPrint(
        '📍 Iniciando tracking para patrullaje '
        '${event.patrullajeId}...',
      );

      final stream = trackingUseCases.getLocationStream.run(
        tipo: 'TRACKING',
        distanceFilter: 5,
        interval: const Duration(seconds: 5),
      );

      _gpsSubscription = stream.listen(
        (location) {
          debugPrint(
            '📍 TrackingBloc recibió: '
            '${location.latitud}, ${location.longitud} | '
            '${location.fechaHora}',
          );

          // Actualiza la UI mediante un evento.
          add(LocationUpdatedEvent(location));

          // Envía la ubicación sin bloquear el stream.
          unawaited(
            _sendLocation(location: location, patrullajeId: event.patrullajeId),
          );
          // _sendLocation(location: location, patrullajeId: event.patrullajeId);
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ Error en stream GPS: $error');

          add(
            TrackingStreamErrorEvent(
              patrullajeId: event.patrullajeId,
              message: error.toString(),
            ),
          );
        },
        onDone: () {
          debugPrint('⚠️ Stream GPS finalizado');

          add(TrackingStreamCompletedEvent(patrullajeId: event.patrullajeId));
        },
        cancelOnError: false,
      );

      emit(
        state.copyWith(
          isLoading: false,
          isTracking: true,
          patrullajeId: event.patrullajeId,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('❌ No se pudo iniciar el tracking: $error');
      debugPrintStack(stackTrace: stackTrace);

      await _gpsSubscription?.cancel();
      _gpsSubscription = null;

      emit(
        state.copyWith(
          isLoading: false,
          isTracking: false,
          error: error.toString(),
          clearLastLocation: true,
        ),
      );
    }
  }

  // =====================================================
  // 2. ENVIAR UBICACIÓN AL BACKEND
  // =====================================================
  Future<void> _sendLocation({
    required LocationEntity location,
    required int patrullajeId,
  }) async {
    try {
      await trackingUseCases.sendLocation.run(location, patrullajeId);
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error enviando ubicación del patrullaje '
        '$patrullajeId: $error',
      );

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // =====================================================
  // 3. DETENER TRACKING
  // =====================================================
  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (_gpsSubscription != null) {
      debugPrint('🛑 Deteniendo tracking...');

      await _gpsSubscription!.cancel();
      _gpsSubscription = null;
    }

    emit(
      state.copyWith(
        isTracking: false,
        isLoading: false,
        clearPatrullajeId: true,
        clearLastLocation: true,
        clearError: true,
      ),
    );
  }

  // =====================================================
  // 4. ACTUALIZAR UBICACIÓN DE UI
  // =====================================================
  void _onLocationUpdated(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) {
    /*
     * Ignora ubicaciones que lleguen después de detener
     * el tracking.
     */
    if (!state.isTracking || state.patrullajeId == null) {
      debugPrint(
        '⚠️ Ubicación ignorada porque el tracking '
        'no está activo.',
      );

      return;
    }

    debugPrint(
      '🔄 Actualizando TrackingState: '
      '${event.location.latitud}, '
      '${event.location.longitud}',
    );

    emit(state.copyWith(lastLocation: event.location, clearError: true));
  }

  // =====================================================
  // 5. ERROR DEL STREAM
  // =====================================================
  Future<void> _onTrackingStreamError(
    TrackingStreamErrorEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state.patrullajeId != event.patrullajeId) {
      debugPrint('⚠️ Error ignorado: pertenece a un tracking anterior.');

      return;
    }

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    emit(
      state.copyWith(
        isLoading: false,
        isTracking: false,
        error: event.message,
        clearLastLocation: true,
      ),
    );
  }

  // =====================================================
  // 6. STREAM GPS FINALIZADO
  // =====================================================
  Future<void> _onTrackingStreamCompleted(
    TrackingStreamCompletedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state.patrullajeId != event.patrullajeId) {
      debugPrint('⚠️ Finalización ignorada: pertenece a un stream anterior.');

      return;
    }

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    emit(state.copyWith(isLoading: false, isTracking: false));
  }

  // =====================================================
  // CLEANUP
  // =====================================================
  @override
  Future<void> close() async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    return super.close();
  }
}
