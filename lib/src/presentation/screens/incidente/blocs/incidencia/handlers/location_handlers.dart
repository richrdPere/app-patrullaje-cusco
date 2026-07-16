import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
// import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class LocationHandlers {
  final GeolocatorUseCases geolocatorUseCases;

  const LocationHandlers({required this.geolocatorUseCases});

  // ======================================================
  // OBTENER UBICACIÓN ACTUAL
  // ======================================================
  Future<void> onObtenerUbicacion(
    ObtenerUbicacionEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState currentState,
  ) async {
    if (currentState.loadingLocation) {
      return;
    }

    final state = currentState.copyWith(
      loadingLocation: true,
      clearLatitud: true,
      clearLongitud: true,
      clearDireccion: true,
    );

    emit(state);

    try {
      final LocationEntity location = await geolocatorUseCases
          .getCurrentLocation
          .run(tipo: 'EMERGENCIA');

      debugPrint(
        'UBICACIÓN OBTENIDA: '
        '${location.latitud}, ${location.longitud}',
      );

      emit(
        state.copyWith(
          latitud: location.latitud,
          longitud: location.longitud,
          loadingLocation: false,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('EXCEPCIÓN AL OBTENER UBICACIÓN: $error');
      debugPrintStack(stackTrace: stackTrace);

      emit(state.copyWith(loadingLocation: false));
    }
  }
}
