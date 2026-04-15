import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GeolocatorUseCases geolocatorUseCases;
  final PatrullajeUseCases patrullajeUseCases;

  StreamSubscription<LocationEntity>? _locationSubscription;

  TrackingBloc(this.geolocatorUseCases, this.patrullajeUseCases)
    : super(TrackingState()) {
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
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final patrullaje = await patrullajeUseCases.startPatrullaje.run(
        event.patrullajeId,
      );

      print("Patrullaje en TRACKING: ${patrullaje}");

      emit(state.copyWith(isLoading: false, patrullajeId: event.patrullajeId));

      // automáticamente inicia tracking
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

    emit(state.copyWith(isTracking: true, error: null));

    await _locationSubscription?.cancel();

    _locationSubscription = geolocatorUseCases.getLocationStream.run().listen((
      location,
    ) {
      add(LocationUpdatedEvent(location));
    });

    // _locationSubscription = geolocatorUseCases.getLocationStream.run().listen((
    //   location,
    // ) async {
    //   emit(state.copyWith(lastLocation: location));

    //   try {
    //     // actualizar UI
    //     emit(state.copyWith(lastLocation: location));

    //     // ENVÍO AUTOMÁTICO AL BACKEND
    //     await patrullajeUseCases.sendLocation.run(
    //       LocationEntity(
    //         latitud: location.latitud,
    //         longitud: location.longitud,
    //         velocidad: location.velocidad,
    //         precision: location.precision,
    //         fechaHora: location.fechaHora,
    //         tipo: location.tipo,
    //         // patrullajeId: state.patrullajeId,
    //       ),
    //     );

    //     print("Enviando ubicación: ${location.latitud}, ${location.longitud}");
    //   } catch (e) {
    //     print("Error enviando ubicación: $e");
    //   }
    // });
  }

  // =====================================================
  // 3. DETENER TRACKING
  // =====================================================
  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    emit(state.copyWith(isTracking: false));
  }

  // =====================================================
  // 4. FINALIZAR PATRULLAJE
  // =====================================================
  Future<void> _onEndPatrullaje(
    EndPatrullajeEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // detener tracking primero
      await _locationSubscription?.cancel();

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
    _locationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLocationUpdatedEvent(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // 1. actualizar UI (rápido)
    emit(state.copyWith(lastLocation: event.location));

    try {
      // 2. enviar backend (sin bloquear stream principal)
      await patrullajeUseCases.sendLocation.run(event.location);
    } catch (e) {
      print("Error enviando ubicación: $e");
    }
  }
}
