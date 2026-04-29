import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GeolocatorUseCases geolocatorUseCases;
  final SocketUseCases socketUseCases;
  final PatrullajeUseCases patrullajeUseCases;

  StreamSubscription<LocationEntity>? _gpsSubscription;

  TrackingBloc(
    this.geolocatorUseCases,
    this.socketUseCases,
    this.patrullajeUseCases,
  ) : super(TrackingState()) {
    on<StartPatrullajeEvent>(_onStartPatrullaje);
    on<EndPatrullajeEvent>(_onEndPatrullaje);
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);

    on<LocationUpdatedEvent>(_onLocationUpdatedEvent);
  }

  // =====================================================
  // 1. INICIAR PATRULLAJE
  // =====================================================
  Future<void> _onStartPatrullaje(
    StartPatrullajeEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await patrullajeUseCases.startPatrullaje.run(event.patrullajeId);

      emit(state.copyWith(isLoading: false, patrullajeId: event.patrullajeId));

      add(StartTrackingEvent());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // =====================================================
  // 2. INICIAR TRACKING (STREAM GPS)
  // =====================================================
  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    if (state.isTracking) return;

    final socket = socketUseCases.getSocket.run();

    _gpsSubscription?.cancel();

    _gpsSubscription = geolocatorUseCases.getLocationStream.run().listen((
      position,
    ) {
      final location = position;

      // 1. UI update inmediato
      add(LocationUpdatedEvent(location));

      // 2. socket emit (TIEMPO REAL)
      socket.emitWithAck(
        "tracking",
        locationToSocketJson(location, state.patrullajeId),
        ack: (response) {
          print("ACK TRACKING: $response");
        },
      );
      // socket.emit("tracking", {
      //   "lat": location.latitud,
      //   "lng": location.longitud,
      //   "timestamp": location.fechaHora.toIso8601String(),
      //   "velocidad": location.velocidad,
      //   "precision": location.precision,
      //   "tipo": location.tipo,
      //   "patrullaje_id": state.patrullajeId,
      // });
    });

    emit(state.copyWith(isTracking: true));
  }

  // =====================================================
  // 3. DETENER TRACKING
  // =====================================================
  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    emit(state.copyWith(isTracking: false));
  }

  // =========================
  // 4. LOCATION UPDATE (UI ONLY)
  // =========================
  Future<void> _onLocationUpdatedEvent(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // 1. actualizar UI (rápido)
    emit(state.copyWith(lastLocation: event.location));
  }

  // =====================================================
  // 5. FINALIZAR PATRULLAJE
  // =====================================================
  Future<void> _onEndPatrullaje(
    EndPatrullajeEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _gpsSubscription?.cancel();
      _gpsSubscription = null;

      print("Finalizando patrullaje ID: ${event.patrullajeId}");

      await patrullajeUseCases.endPatrullaje.run(event.patrullajeId);

      emit(const TrackingState());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // =====================================================
  // LIMPIEZA
  // =====================================================
  @override
  Future<void> close() {
    _gpsSubscription?.cancel();
    return super.close();
  }
}
