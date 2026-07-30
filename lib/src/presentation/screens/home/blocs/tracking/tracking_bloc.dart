import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/tracking_transmission_status.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingUseCases trackingUseCases;

  StreamSubscription<LocationEntity>? _gpsSubscription;

  TrackingBloc(this.trackingUseCases) : super(const TrackingState()) {
    // =====================================================
    // TRACKING
    // =====================================================
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<LocationUpdatedEvent>(_onLocationUpdated);

    // =====================================================
    // STREAM GPS
    // =====================================================
    on<TrackingStreamErrorEvent>(_onTrackingStreamError);

    on<TrackingStreamCompletedEvent>(_onTrackingStreamCompleted);

    // =====================================================
    // TRANSMISIÓN
    // =====================================================
    on<TrackingSendStartedEvent>(_onTrackingSendStarted);

    on<TrackingSendSuccessEvent>(_onTrackingSendSuccess);

    on<TrackingSendFailedEvent>(_onTrackingSendFailed);
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
        '${event.patrullajeId}.',
      );

      return;
    }

    // Cancela cualquier stream anterior.
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
        clearTransmission: true,
      ),
    );

    try {
      final stream = trackingUseCases.getLocationStream.run(
        tipo: 'TRACKING',
        distanceFilter: 5,
        interval: const Duration(seconds: 5),
      );

      _gpsSubscription = stream.listen(
        (location) {
          debugPrint(
            '📍 TrackingBloc recibió ubicación: '
            '${location.latitud}, '
            '${location.longitud} | '
            '${location.fechaHora}',
          );

          /*
           * Actualiza la ubicación utilizada por la interfaz
           * y por MapaBloc.
           */
          add(LocationUpdatedEvent(location));

          /*
           * Envía la ubicación al backend sin bloquear
           * la recepción del siguiente punto GPS.
           */
          unawaited(
            _sendLocation(location: location, patrullajeId: event.patrullajeId),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ Error en stream GPS: $error');

          debugPrintStack(stackTrace: stackTrace);

          add(
            TrackingStreamErrorEvent(
              patrullajeId: event.patrullajeId,
              message: error.toString(),
            ),
          );
        },
        onDone: () {
          debugPrint('⚠️ Stream GPS finalizado.');

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
          transmissionStatus: TrackingTransmissionStatus.waitingLocation,
          transmissionMessage: 'Esperando la primera ubicación...',
          consecutiveFailures: 0,
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
          error: _formatError(error),
          clearLastLocation: true,
          transmissionStatus: TrackingTransmissionStatus.failed,
          transmissionMessage: 'No se pudo iniciar el seguimiento GPS.',
          consecutiveFailures: 1,
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
    /*
     * Antes de enviar, informa al BLoC que la transmisión
     * está en proceso.
     */
    add(TrackingSendStartedEvent(location: location));

    try {
      final result = await trackingUseCases.sendLocation.run(
        location,
        patrullajeId,
      );

      /*
       * El resultado proviene del ACK enviado por el backend.
       */
      add(
        TrackingSendSuccessEvent(
          confirmedAt: result.confirmedAt,
          message: result.message,
          omitted: result.omitted,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error enviando ubicación del patrullaje '
        '$patrullajeId: $error',
      );

      debugPrintStack(stackTrace: stackTrace);

      add(TrackingSendFailedEvent(message: _formatError(error)));
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
        clearTransmission: true,
      ),
    );
  }

  // =====================================================
  // 4. ACTUALIZAR UBICACIÓN DE LA INTERFAZ
  // =====================================================
  void _onLocationUpdated(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) {
    /*
     * Ignora puntos que puedan llegar después de detener
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
      '${event.location.longitud}.',
    );

    emit(state.copyWith(lastLocation: event.location, clearError: true));
  }

  // =====================================================
  // 5. ERROR DEL STREAM GPS
  // =====================================================
  Future<void> _onTrackingStreamError(
    TrackingStreamErrorEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state.patrullajeId != event.patrullajeId) {
      debugPrint(
        '⚠️ Error ignorado: pertenece a un '
        'tracking anterior.',
      );

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
        transmissionStatus: TrackingTransmissionStatus.failed,
        transmissionMessage: 'El seguimiento GPS se interrumpió.',
        consecutiveFailures: state.consecutiveFailures + 1,
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
      debugPrint(
        '⚠️ Finalización ignorada: pertenece a '
        'un stream anterior.',
      );

      return;
    }

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    emit(
      state.copyWith(
        isLoading: false,
        isTracking: false,
        transmissionStatus: TrackingTransmissionStatus.failed,
        transmissionMessage: 'El seguimiento de ubicación se detuvo.',
      ),
    );
  }

  // =====================================================
  // 7. INICIO DEL ENVÍO
  // =====================================================
  void _onTrackingSendStarted(
    TrackingSendStartedEvent event,
    Emitter<TrackingState> emit,
  ) {
    /*
     * Puede ocurrir que un envío haya empezado justo antes
     * de detener el patrullaje. En ese caso se ignora.
     */
    if (!state.isTracking || state.patrullajeId == null) {
      debugPrint(
        '⚠️ Inicio de transmisión ignorado porque '
        'el tracking no está activo.',
      );

      return;
    }

    emit(
      state.copyWith(
        transmissionStatus: TrackingTransmissionStatus.sending,
        transmissionMessage: 'Transmitiendo ubicación...',
        clearError: true,
      ),
    );
  }

  // =====================================================
  // 8. TRANSMISIÓN CONFIRMADA
  // =====================================================
  void _onTrackingSendSuccess(
    TrackingSendSuccessEvent event,
    Emitter<TrackingState> emit,
  ) {
    /*
     * Evita que un ACK tardío cambie el estado después
     * de detener el tracking.
     */
    if (!state.isTracking || state.patrullajeId == null) {
      debugPrint(
        '⚠️ Confirmación ignorada porque el '
        'tracking ya no está activo.',
      );

      return;
    }

    final status = event.omitted
        ? TrackingTransmissionStatus.omitted
        : TrackingTransmissionStatus.transmitted;

    debugPrint(
      event.omitted
          ? '✅ Ubicación recibida, pero omitida por '
                'no existir desplazamiento significativo.'
          : '✅ Ubicación confirmada por el backend.',
    );

    emit(
      state.copyWith(
        transmissionStatus: status,
        lastTransmissionAt: event.confirmedAt,
        transmissionMessage: event.message,
        consecutiveFailures: 0,
        clearError: true,
      ),
    );
  }

  // =====================================================
  // 9. ERROR DE TRANSMISIÓN
  // =====================================================
  void _onTrackingSendFailed(
    TrackingSendFailedEvent event,
    Emitter<TrackingState> emit,
  ) {
    /*
     * Si el patrullaje ya terminó, no es necesario mostrar
     * un error producido por una respuesta tardía.
     */
    if (!state.isTracking || state.patrullajeId == null) {
      debugPrint(
        '⚠️ Error de transmisión ignorado porque '
        'el tracking ya no está activo.',
      );

      return;
    }

    final failures = state.consecutiveFailures + 1;

    debugPrint(
      '❌ Fallo consecutivo de transmisión '
      '#$failures: ${event.message}',
    );

    emit(
      state.copyWith(
        transmissionStatus: TrackingTransmissionStatus.failed,
        transmissionMessage: event.message,
        consecutiveFailures: failures,
      ),
    );
  }

  // =====================================================
  // 10. FORMATEAR ERRORES
  // =====================================================
  String _formatError(Object error) {
    if (error is TimeoutException) {
      return error.message ?? 'El servidor no confirmó la ubicación.';
    }

    if (error is StateError) {
      return error.message;
    }

    if (error is ArgumentError) {
      return error.message?.toString() ??
          'Los datos de tracking no son válidos.';
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.startsWith('Bad state: ')) {
      return message.replaceFirst('Bad state: ', '');
    }

    return message;
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
