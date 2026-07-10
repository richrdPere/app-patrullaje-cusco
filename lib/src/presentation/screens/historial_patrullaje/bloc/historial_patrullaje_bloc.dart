import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'historial_patrullaje_event.dart';
import 'historial_patrullaje_state.dart';

class HistorialPatrullajeBloc
    extends Bloc<HistorialPatrullajeEvent, HistorialPatrullajeState> {
  final HistorialPatrullajeUseCases historialUseCases;
  final PatrullajeUseCases patrullajeUseCases;

  HistorialPatrullajeBloc(this.historialUseCases, this.patrullajeUseCases)
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
    debugPrint("=== LoadHistorialPatrullajeEvent ===");
    emit(state.copyWith(loading: true, error: null));

    try {
      final response = await patrullajeUseCases.getPatrullajeActivo.run();

      debugPrint("Patrullaje obtenido: $response");

      if (response is Success<PatrullajeData?>) {
        final patrullaje = response.data;

        if (patrullaje == null) {
          emit(
            state.copyWith(
              loading: false,
              error: "No existe un patrullaje activo",
            ),
          );
          return;
        }

        debugPrint("ID Patrullaje: ${patrullaje.id}");
        debugPrint("Zona: ${patrullaje.zona.id}");

        final historial = await historialUseCases.getHistorialByPatrullaje.run(
          patrullaje.id,
        );

        debugPrint("ID historial: $historial");

        emit(
          state.copyWith(
            loading: false,
            patrullaje: patrullaje,
            historial: historial,
          ),
        );
      }
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
      final historial = await historialUseCases.getHistorialById.run(
        event.historialId,
      );

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
      await historialUseCases.createHistorial.run(event.historial);
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
      await historialUseCases.updateHistorial.run(event.historial);
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
      await historialUseCases.archivedHistorial.run(event.historialId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
