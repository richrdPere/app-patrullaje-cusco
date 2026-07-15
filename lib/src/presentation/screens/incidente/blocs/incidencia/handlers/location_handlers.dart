import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

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
    IncidenteState state,
  ) async {
    if (state.loadingLocation) {
      return;
    }

    emit(
      state.copyWith(
        loadingLocation: true,
        clearLatitud: true,
        clearLongitud: true,
        clearDireccion: true,
      ),
    );

    try {
      final response = await geolocatorUseCases.getLocationStream.run();
      // final response = await geolocatorUseCases.getCurrentPosition();

      if (response is Success) {
        final position = response.data;

        emit(
          state.copyWith(
            latitud: position.latitude,
            longitud: position.longitude,
            loadingLocation: false,
          ),
        );

        return;
      }

      if (response is ErrorData) {
        emit(state.copyWith(loadingLocation: false));

        return;
      }

      emit(state.copyWith(loadingLocation: false));
    } catch (error) {
      emit(state.copyWith(loadingLocation: false));
    }
  }
}
