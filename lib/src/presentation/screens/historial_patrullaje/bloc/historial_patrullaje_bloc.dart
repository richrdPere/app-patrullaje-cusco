import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'historial_patrullaje_event.dart';
import 'historial_patrullaje_state.dart';

class HistorialPatrullajeBloc
    extends Bloc<HistorialPatrullajeEvent, HistorialPatrullajeState> {
  final HistorialPatrullajeUseCases historialUseCases;

  HistorialPatrullajeBloc(this.historialUseCases)
    : super(const HistorialPatrullajeState()) {
    on<LoadHistorialPatrullajeEvent>(_onLoadHistorial);
    on<LoadHistorialDetalleEvent>(_onLoadDetalle);
    on<RegisterHistorialEvent>(_onRegisterHistorial);
    on<UpdateHistorialEvent>(_onUpdateHistorial);
    on<ArchiveHistorialEvent>(_onArchiveHistorial);
    on<ClearHistorialSelectedEvent>(_onClearSelected);
    on<ClearHistorialActionEvent>(_onClearAction);
  }

  // ======================================================
  // 1. OBTENER HISTORIAL POR PATRULLAJE
  // ======================================================
  Future<void> _onLoadHistorial(
    LoadHistorialPatrullajeEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.listStatus == HistorialListStatus.loading && !event.refresh) {
      return;
    }

    emit(
      state.copyWith(listStatus: HistorialListStatus.loading, clearError: true),
    );

    final response = await historialUseCases.getHistorialByPatrullaje.run(
      event.patrullajeId,
    );

    if (response is Success<List<HistorialPatrullajeModel>>) {
      final historial = response.data;

      emit(
        state.copyWith(
          listStatus: historial.isEmpty
              ? HistorialListStatus.empty
              : HistorialListStatus.success,
          historial: historial,
          clearError: true,
        ),
      );
      return;
    }

    if (response is ErrorData<List<HistorialPatrullajeModel>>) {
      emit(
        state.copyWith(
          listStatus: HistorialListStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
    }
  }

  // ======================================================
  // 2. OBTENER DETALLE
  // ======================================================
  Future<void> _onLoadDetalle(
    LoadHistorialDetalleEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    emit(
      state.copyWith(
        detailStatus: HistorialDetailStatus.loading,
        clearHistorialSelected: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.getHistorialById.run(
      event.historialId,
    );

    if (response is Success<HistorialPatrullajeModel>) {
      emit(
        state.copyWith(
          detailStatus: HistorialDetailStatus.success,
          historialSelected: response.data,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<HistorialPatrullajeModel>) {
      emit(
        state.copyWith(
          detailStatus: HistorialDetailStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
    }
  }

  // ======================================================
  // 3. REGISTRAR HISTORIAL
  // ======================================================
  Future<void> _onRegisterHistorial(
    RegisterHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.actionStatus == HistorialActionStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.loading,
        clearActionMessage: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.createHistorial.run(event.request);

    if (response is Success<HistorialPatrullajeModel>) {
      final historialCreado = response.data;

      final historialActualizado = [
        historialCreado,
        ...state.historial.where((item) => item.id != historialCreado.id),
      ];

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,
          actionMessage: 'Historial registrado correctamente.',
          listStatus: HistorialListStatus.success,
          historial: historialActualizado,
          historialSelected: historialCreado,
          detailStatus: HistorialDetailStatus.success,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<HistorialPatrullajeModel>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
    }
  }

  // ======================================================
  // 4. ACTUALIZAR HISTORIAL
  // ======================================================
  Future<void> _onUpdateHistorial(
    UpdateHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.actionStatus == HistorialActionStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.loading,
        clearActionMessage: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.updateHistorial.run(
      idHistorial: event.historialId,
      historial: event.request,
    );

    if (response is Success<HistorialPatrullajeModel>) {
      final historialActualizado = response.data;

      final nuevaLista = state.historial.map((item) {
        if (item.id == historialActualizado.id) {
          return historialActualizado;
        }

        return item;
      }).toList();

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,
          actionMessage: 'Historial actualizado correctamente.',
          historial: nuevaLista,
          historialSelected: historialActualizado,
          detailStatus: HistorialDetailStatus.success,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<HistorialPatrullajeModel>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
    }
  }

  // ======================================================
  // 5. ARCHIVAR HISTORIAL
  // ======================================================
  Future<void> _onArchiveHistorial(
    ArchiveHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.actionStatus == HistorialActionStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.loading,
        clearActionMessage: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.archivedHistorial.run(
      event.historialId,
    );

    if (response is Success<bool>) {
      final archivado = response.data;

      if (!archivado) {
        emit(
          state.copyWith(
            actionStatus: HistorialActionStatus.error,
            errorMessage: 'No se pudo archivar el historial.',
          ),
        );

        return;
      }

      final nuevaLista = state.historial
          .where((item) => item.id != event.historialId)
          .toList();

      final selectedFueArchivado =
          state.historialSelected?.id == event.historialId;

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,
          actionMessage: 'Historial archivado correctamente.',
          historial: nuevaLista,
          listStatus: nuevaLista.isEmpty
              ? HistorialListStatus.empty
              : HistorialListStatus.success,
          clearHistorialSelected: selectedFueArchivado,
          detailStatus: selectedFueArchivado
              ? HistorialDetailStatus.initial
              : state.detailStatus,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<bool>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
    }
  }

  // ======================================================
  // 6. LIMPIAR SELECCIONADO
  // ======================================================
  void _onClearSelected(
    ClearHistorialSelectedEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) {
    emit(
      state.copyWith(
        detailStatus: HistorialDetailStatus.initial,
        clearHistorialSelected: true,
        clearError: true,
      ),
    );
  }

  // ======================================================
  // 7. LIMPIAR ESTADO DE ACCIÓN
  // ======================================================
  void _onClearAction(
    ClearHistorialActionEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.initial,
        clearActionMessage: true,
        clearError: true,
      ),
    );
  }
}
