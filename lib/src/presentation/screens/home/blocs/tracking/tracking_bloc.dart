import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  // final GeolocatorUseCases geolocatorUseCases;
  // final SocketUseCases socketUseCases;
  // final PatrullajeUseCases patrullajeUseCases;

  final TrackingUseCases trackingUseCases;

  StreamSubscription<LocationEntity>? _gpsSubscription;

  TrackingBloc(this.trackingUseCases) : super(TrackingState()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<LocationUpdatedEvent>(_onLocationUpdatedEvent);
  }

  // =====================================================
  // 1. INICIAR TRACKING
  // =====================================================
  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // YA TRACKING DEL MISMO PATRULLAJE
    if (state.isTracking &&
        _gpsSubscription != null &&
        state.patrullajeId == event.patrullajeId) {
      print("⚠️ Tracking ya activo para este patrullaje");

      return;
    }

    // NUEVO PATRULLAJE
    if (state.isTracking && state.patrullajeId != event.patrullajeId) {
      print("🔄 Reiniciando tracking para nuevo patrullaje");
      await _gpsSubscription?.cancel();
      _gpsSubscription = null;
    }

    print("📍 Iniciando tracking...");

    _gpsSubscription = trackingUseCases.getLocationStream.run().listen(
      (location) {
        // 1. UI update
        add(LocationUpdatedEvent(location));

        // 2. enviar al backend
        trackingUseCases.sendLocation.run(location, event.patrullajeId);
      },

      onError: (error) {
        print("❌ Error GPS: $error");

        emit(state.copyWith(isTracking: false));
      },

      onDone: () {
        print("⚠️ Stream GPS finalizado");

        emit(state.copyWith(isTracking: false));
      },
    );

    emit(state.copyWith(isTracking: true, patrullajeId: event.patrullajeId));
  }

  // =====================================================
  // 2. DETENER TRACKING
  // =====================================================
  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    emit(state.copyWith(isTracking: false));
  }

  // =====================================================
  // 3. ACTUALIZAR UI
  // =====================================================
  Future<void> _onLocationUpdatedEvent(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(lastLocation: event.location));
  }

  // =====================================================
  // CLEANUP
  // =====================================================
  @override
  Future<void> close() {
    _gpsSubscription?.cancel();
    return super.close();
  }
}
