import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';

class ContextHandlers {
  final IncidenteUseCases incidenteUseCases;

  const ContextHandlers({required this.incidenteUseCases});

  // 1. INCIDENTES CERCANOS
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

      final incidents = await incidenteUseCases.getIncidenciasCercanas.run(
        latitud: state.latitud!,
        longitud: state.longitud!,
      );

      emit(state.copyWith(loadingNearby: false, nearbyIncidents: incidents));
    } catch (e) {
      emit(state.copyWith(loadingNearby: false, error: e.toString()));
    }
  }

  // 2. MAPA DE INCIDENTES ACTIVOS
  Future<void> onObtenerMapaIncidentes(
    ObtenerMapaIncidentesEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingMapa: true, error: null));

    try {
      debugPrint("PROBANDO OBTENRR MAPA");
      // final incidencias = await incidenteUseCases.getMapaIncidentes.run();

      // emit(state.copyWith(loadingMapa: false, mapaIncidentes: incidencias));
    } catch (e) {
      emit(state.copyWith(loadingMapa: false, error: e.toString()));
    }
  }

  // 3. DASHBOARD DE INCIDENTES
  Future<void> onObtenerDashboard(
    ObtenerDashboardIncidentesEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingDashboard: true, error: null));

    try {
      debugPrint("PROBANDO OBTENRR DASHBOARD");
      // final dashboard = await incidenteUseCases.getDashboardIncidentes.run();

      // emit(state.copyWith(loadingDashboard: false, dashboard: dashboard));
    } catch (e) {
      emit(state.copyWith(loadingDashboard: false, error: e.toString()));
    }
  }
}
