import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';

import 'historial_patrullaje_event.dart';
import 'historial_patrullaje_state.dart';

class HistorialPatrullajeBloc
    extends Bloc<HistorialPatrullajeEvent, HistorialPatrullajeState> {
  final HistorialPatrullajeUseCases useCases;

  HistorialPatrullajeBloc(this.useCases)
    : super(const HistorialPatrullajeState()) {
    on<LoadHistorialPatrullajeEvent>(_onLoadHistorial);
    on<LoadHistorialDetalleEvent>(_onLoadDetalle);
    on<RegisterHistorialEvent>(_onRegister);
    on<UpdateHistorialEvent>(_onUpdate);
    on<ArchiveHistorialEvent>(_onArchive);
  }

  // =====================================================
  // CARGAR HISTORIAL
  // =====================================================
  Future<void> _onLoadHistorial(
    LoadHistorialPatrullajeEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final historial = await useCases.getHistorialByPatrullaje.run(
        event.patrullajeId,
      );

      emit(state.copyWith(loading: false, historial: historial));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  // =====================================================
  // DETALLE
  // =====================================================
  Future<void> _onLoadDetalle(
    LoadHistorialDetalleEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    try {
      final historial = await useCases.getHistorialById.run(event.historialId);

      emit(state.copyWith(historialDetalle: historial));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // =====================================================
  // REGISTRAR
  // =====================================================
  Future<void> _onRegister(
    RegisterHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    try {
      await useCases.createHistorial.run(event.historial);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // =====================================================
  // EDITAR
  // =====================================================
  Future<void> _onUpdate(
    UpdateHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    try {
      await useCases.updateHistorial.run(event.historial);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // =====================================================
  // ARCHIVAR
  // =====================================================
  Future<void> _onArchive(
    ArchiveHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    try {
      await useCases.archivedHistorial.run(event.historialId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
