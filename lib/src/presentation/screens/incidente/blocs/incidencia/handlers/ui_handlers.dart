import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class UiHandlers {
  const UiHandlers();

  // ======================================================
  // 1. RESTABLECER TODO EL MÓDULO
  // ======================================================
  Future<void> onResetIncidente(
    ResetIncidenteEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    emit(const IncidenteState());
  }

  // ======================================================
  // 2. LIMPIAR RESPUESTAS DE ACCIONES
  // ======================================================
  Future<void> onLimpiarAccionIncidente(
    LimpiarAccionIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        clearCreateResponse: true,
        clearAgregarArchivosResponse: true,
        clearEliminarArchivoResponse: true,
      ),
    );
  }

  // ======================================================
  // 3. LIMPIAR RESPUESTAS DE ERROR
  // ======================================================
  Future<void> onLimpiarErrorIncidente(
    LimpiarErrorIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final hasAnyError =
        state.createResponse is ErrorData ||
        state.agregarArchivosResponse is ErrorData ||
        state.eliminarArchivoResponse is ErrorData ||
        state.misIncidenciasResponse is ErrorData ||
        state.detalleResponse is ErrorData ||
        state.archivosResponse is ErrorData ||
        state.cercanosResponse is ErrorData ||
        state.incidenciasPatrullajeResponse is ErrorData ||
        state.incidenciasZonaResponse is ErrorData ||
        state.mediaError != null;

    if (!hasAnyError) {
      return;
    }

    emit(
      state.copyWith(
        /*
         * Solamente se limpian las respuestas cuando
         * actualmente contienen un ErrorData.
         *
         * Las respuestas exitosas o en carga se conservan.
         */
        clearCreateResponse: state.createResponse is ErrorData,

        clearAgregarArchivosResponse:
            state.agregarArchivosResponse is ErrorData,

        clearEliminarArchivoResponse:
            state.eliminarArchivoResponse is ErrorData,

        clearMisIncidenciasResponse: state.misIncidenciasResponse is ErrorData,

        clearDetalleResponse: state.detalleResponse is ErrorData,

        clearArchivosResponse: state.archivosResponse is ErrorData,

        clearCercanosResponse: state.cercanosResponse is ErrorData,

        clearIncidenciasPatrullajeResponse:
            state.incidenciasPatrullajeResponse is ErrorData,

        clearIncidenciasZonaResponse:
            state.incidenciasZonaResponse is ErrorData,

        clearMediaError: state.mediaError != null,
      ),
    );
  }

  // ======================================================
  // 4. CAMBIAR PESTAÑA
  // ======================================================
  Future<void> onCambiarTab(
    CambiarTabIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.currentTab == event.tab) {
      return;
    }

    emit(state.copyWith(currentTab: event.tab));
  }

  // ======================================================
  // 5. EXPANDIR SHEET
  // ======================================================
  Future<void> onExpandirSheet(
    ExpandirSheetIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.isSheetExpanded) {
      return;
    }

    emit(state.copyWith(isSheetExpanded: true));
  }

  // ======================================================
  // 6. CONTRAER SHEET
  // ======================================================
  Future<void> onContraerSheet(
    ContraerSheetIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!state.isSheetExpanded) {
      return;
    }

    emit(state.copyWith(isSheetExpanded: false));
  }
}
