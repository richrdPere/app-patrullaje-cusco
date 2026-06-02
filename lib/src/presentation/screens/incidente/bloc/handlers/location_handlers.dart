import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';

class LocationHandlers {
  final GeolocatorUseCases geolocatorUseCases;

  LocationHandlers({required this.geolocatorUseCases});

  Future<void> onObtenerUbicacion(
    ObtenerUbicacionEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingLocation: true, error: null));

    try {
      final Position position = await geolocatorUseCases.findPosition.run();

      final placemark = await geolocatorUseCases.getPlaceMarkData.run(
        CameraPosition(target: LatLng(position.latitude, position.longitude)),
      );

      emit(
        state.copyWith(
          latitud: position.latitude,
          longitud: position.longitude,
          direccion: placemark.address,
          loadingLocation: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loadingLocation: false, error: e.toString()));
    }
  }
}
