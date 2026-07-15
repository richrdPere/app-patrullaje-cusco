import 'package:bloc/bloc.dart';

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
        clearArchivoActionResponse: true,
      ),
    );
  }

  // ======================================================
  // 3. CAMBIAR PESTAÑA
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
  // 4. EXPANDIR SHEET
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
  // 5. CONTRAER SHEET
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
