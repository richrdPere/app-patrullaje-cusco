import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';

class IncidenteHandlers {
  final IncidenteUseCases incidenteUseCases;
  final HistorialPatrullajeUseCases historialUseCases;

  IncidenteHandlers({
    required this.incidenteUseCases,
    required this.historialUseCases,
  });

  Future<void> onCrearIncidente(
    CrearIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, success: false));

    try {
      final incidencia = await incidenteUseCases.createIncidente.run(
        event.params,
      );

      final historial = _buildHistorialFromIncidencia(incidencia);

      await historialUseCases.registerResumenHistorial.run(historial);

      emit(
        state.copyWith(isLoading: false, success: true, incidencia: incidencia),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, success: false, error: e.toString()),
      );
    }
  }

  Future<void> onReporteRapido(
    ReporteRapidoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
    Function(IncidenteEvent) add,
  ) async {
    if (state.latitud == null || state.longitud == null) {
      emit(state.copyWith(error: 'Ubicación no disponible'));

      return;
    }

    final incidente = IncidenteModel(
      tipo: event.tipo.name.toUpperCase(),
      descripcion: 'Reporte rápido generado',
      latitud: state.latitud!,
      longitud: state.longitud!,
      usuarioId: 0,
    );

    add(CrearIncidenteEvent(incidente));
  }

  HistorialPatrullajeModel _buildHistorialFromIncidencia(
    IncidenteModel incidencia,
  ) {
    return HistorialPatrullajeModel(
      patrullajeId: incidencia.patrullajeId ?? 0,
      serenoId: incidencia.usuarioId,
      zonaId: incidencia.zonaId ?? 0,
      tipo: "ALERTA",
      titulo: "Incidencia reportada: ${incidencia.tipo}",
      descripcion: incidencia.descripcion,
      prioridad: _mapPrioridad(incidencia.tipo),
      latitud: incidencia.latitud,
      longitud: incidencia.longitud,
      visibleParaSiguienteTurno: true,
      estado: "ACTIVO",
    );
  }

  String _mapPrioridad(String tipo) {
    switch (tipo) {
      case "ROBO":
        return "ALTA";

      case "INCENDIO":
        return "CRITICA";

      case "VIOLENCIA":
        return "ALTA";

      case "ACCIDENTE":
        return "MEDIA";

      case "SOSPECHOSO":
        return "MEDIA";

      default:
        return "BAJA";
    }
  }
}
