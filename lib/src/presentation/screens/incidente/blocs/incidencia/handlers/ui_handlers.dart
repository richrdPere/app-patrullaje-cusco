import 'package:bloc/bloc.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';
import '../../../enums/incidente_tab_enum.dart';

class UiHandlers {
  const UiHandlers();

  // ==============================
  // CAMBIAR TAB
  // ==============================
  Future<void> onCambiarTab(
    CambiarTabEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(currentTab: event.tab));
  }

  // ==============================
  // EXPANDIR SHEET
  // ==============================
  Future<void> onExpandirSheet(
    ExpandirSheetEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(isSheetExpanded: true));
  }

  // ==============================
  // CONTRAER SHEET
  // ==============================
  Future<void> onContraerSheet(
    ContraerSheetEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(isSheetExpanded: false));
  }

  // ==============================
  // RESET
  // ==============================
  Future<void> onResetIncidente(
    ResetIncidenteEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    emit(const IncidenteState(currentTab: IncidenteTabEnum.incidente));
  }

  // ==============================
  // LIMPIAR ERROR
  // ==============================
  Future<void> onLimpiarError(
    LimpiarErrorEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(error: null));
  }
}
