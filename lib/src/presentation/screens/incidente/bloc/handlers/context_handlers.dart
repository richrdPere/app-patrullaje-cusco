import 'package:bloc/bloc.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';

class ContextHandlers {
  const ContextHandlers();

  Future<void> onObtenerIncidentesCercanos(
    ObtenerIncidentesCercanosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingNearby: true, error: null));

    try {
      if (state.latitud == null || state.longitud == null) {
        emit(
          state.copyWith(
            loadingNearby: false,
            error: 'Ubicación no disponible',
          ),
        );

        return;
      }

      // TODO:
      // final incidents =
      // await incidenteUseCases.getNearbyIncidents.run(
      //   latitud: state.latitud!,
      //   longitud: state.longitud!,
      // );

      emit(
        state.copyWith(
          loadingNearby: false,

          // nearbyIncidents: incidents,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loadingNearby: false, error: e.toString()));
    }
  }
}
