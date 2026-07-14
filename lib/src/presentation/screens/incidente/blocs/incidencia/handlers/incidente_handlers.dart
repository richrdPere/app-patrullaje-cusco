import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
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

  // 1. CREAR INCIDENCIA
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

      // await historialUseCases.createHistorial.run(historial);

      emit(
        state.copyWith(isLoading: false, success: true, incidencia: incidencia),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, success: false, error: e.toString()),
      );
    }
  }

  // 2. OBTENER DETALLE INCIDENCIA
  Future<void> onObtenerIncidencia(
    ObtenerIncidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final incidencia = await incidenteUseCases.getMisIncidencias.run(
       //  event.incidenciaId,
      );

      emit(
        state.copyWith(isLoading: false, incidenciaSeleccionada: incidencia),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // 3. OBTENER EVIDENCIAS
  Future<void> onObtenerEvidencias(
    ObtenerEvidenciasEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingEvidencias: true, error: null));

    try {
      final evidencias = await incidenteUseCases.getEvidenciasIncidente.run(
        event.incidenciaId,
      );

      emit(state.copyWith(loadingEvidencias: false, evidencias: evidencias));
    } catch (e) {
      emit(state.copyWith(loadingEvidencias: false, error: e.toString()));
    }
  }

  // 4. AGREGAR EVIDENCIAS
  Future<void> onAgregarEvidencias(
    AgregarEvidenciasEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingEvidencias: true, error: null));

    try {
      await incidenteUseCases.addArchivosIncidencia.run(
        incidenciaId: event.incidenciaId,
        archivos: event.archivos,
      );

      final evidencias = await incidenteUseCases.getEvidenciasIncidente.run(
        event.incidenciaId,
      );

      emit(state.copyWith(loadingEvidencias: false, evidencias: evidencias));
    } catch (e) {
      emit(state.copyWith(loadingEvidencias: false, error: e.toString()));
    }
  }

  // 5. ELIMINAR EVIDENCIA
  Future<void> onEliminarEvidencia(
    EliminarEvidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingEvidencias: true, error: null));

    try {
      await incidenteUseCases.removeEvidenciaIncidente.run(incidenciaId: event.evidenciaId, archivoId: 1);

      final evidencias = await incidenteUseCases.getEvidenciasIncidente.run(
        event.incidenciaId,
      );

      emit(state.copyWith(loadingEvidencias: false, evidencias: evidencias));
    } catch (e) {
      emit(state.copyWith(loadingEvidencias: false, error: e.toString()));
    }
  }

  // 6. REPORTE RÁPIDO
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
    );

    add(CrearIncidenteEvent(incidente));
  }

  // ==================================================
  // HELPERS
  // ==================================================
  HistorialPatrullajeModel _buildHistorialFromIncidencia(
    IncidenteModel incidencia,
  ) {
    return HistorialPatrullajeModel(
      // patrullajeId: incidencia.patrullajeId ?? 0,
      // serenoId: incidencia.usuarioId,
      // zonaId: incidencia.zonaId ?? 0,
      tipo: "ALERTA",
      titulo: "Incidencia reportada: ${incidencia.tipo}",
      descripcion: incidencia.descripcion,
      prioridad: _mapPrioridad(incidencia.tipo),
      latitud: incidencia.latitud,
      longitud: incidencia.longitud,
      visibleParaSiguienteTurno: true,
      // estado: "ACTIVO",
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
