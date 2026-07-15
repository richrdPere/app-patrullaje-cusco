import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class ContextHandlers {
  final IncidenteUseCases incidenteUseCases;

  const ContextHandlers({required this.incidenteUseCases});

  // ======================================================
  // 1. OBTENER INCIDENCIAS CERCANAS
  // ======================================================

  Future<void> onObtenerIncidentesCercanos(
    ObtenerIncidentesCercanosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    /*
     * Evita ejecutar una nueva solicitud mientras todavía existe
     * una consulta de incidencias cercanas en curso.
     */
    if (state.isLoadingCercanos) {
      return;
    }

    emit(state.copyWith(cercanosResponse: Loading()));

    try {
      final response = await incidenteUseCases.getIncidenciasCercanas.run(
        latitud: event.latitud,
        longitud: event.longitud,
        radio: event.radio,
        // limit: event.limit,
      );

      if (response is Success<List<IncidenteModel>>) {
        final incidentes = _eliminarDuplicados(response.data);

        emit(
          state.copyWith(
            cercanosResponse: response,
            incidentesCercanos: incidentes,
          ),
        );

        return;
      }

      emit(state.copyWith(cercanosResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          cercanosResponse: ErrorData<List<IncidenteModel>>(
            message: 'No se pudieron obtener las incidencias cercanas: $error',
          ),
        ),
      );
    }
  }

  // ======================================================
  // 2. LIMPIAR INCIDENCIAS CERCANAS
  // ======================================================

  Future<void> onLimpiarIncidentesCercanos(
    LimpiarIncidentesCercanosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(incidentesCercanos: const [], clearCercanosResponse: true),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================

  List<IncidenteModel> _eliminarDuplicados(List<IncidenteModel> incidencias) {
    final Map<int, IncidenteModel> incidenciasConId = {};
    final List<IncidenteModel> incidenciasSinId = [];

    for (final incidencia in incidencias) {
      final id = incidencia.id;

      if (id == null) {
        incidenciasSinId.add(incidencia);
      } else {
        incidenciasConId[id] = incidencia;
      }
    }

    return [...incidenciasConId.values, ...incidenciasSinId];
  }
}
