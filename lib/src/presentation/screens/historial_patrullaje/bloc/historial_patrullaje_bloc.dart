import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'historial_patrullaje_event.dart';
import 'historial_patrullaje_state.dart';

class HistorialPatrullajeBloc
    extends Bloc<HistorialPatrullajeEvent, HistorialPatrullajeState> {
  final HistorialPatrullajeUseCases historialUseCases;

  HistorialPatrullajeBloc(this.historialUseCases)
    : super(const HistorialPatrullajeState()) {
    // Consultas
    on<LoadHistorialPatrullajeEvent>(_onLoadHistorial);
    on<LoadHistorialDetalleEvent>(_onLoadDetalle);
    on<LoadContextoZonaEvent>(_onLoadContextoZona);
    on<LoadSiguienteTurnoEvent>(_onLoadSiguienteTurno);

    // Acciones
    on<CreateHistorialEvent>(_onCreateHistorial);
    on<CreateObservacionConArchivosEvent>(_onCreateObservacionConArchivos);
    on<UpdateHistorialEvent>(_onUpdateHistorial);
    on<ArchiveHistorialEvent>(_onArchiveHistorial);

    // Limpieza
    on<ClearHistorialSelectedEvent>(_onClearSelected);
    on<ClearContextoZonaEvent>(_onClearContextoZona);
    on<ClearSiguienteTurnoEvent>(_onClearSiguienteTurno);
    on<ClearHistorialActionEvent>(_onClearAction);
  }

  // ========================================================
  // 1. OBTENER HISTORIAL POR PATRULLAJE
  // ========================================================
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
      patrullajeId: event.patrullajeId,
    );

    if (response is Success<ApiResponse<List<HistorialPatrullajeData>>>) {
      final apiResponse = response.data;

      final historial = apiResponse.data ?? <HistorialPatrullajeData>[];

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

    if (response is ErrorData<ApiResponse<List<HistorialPatrullajeData>>>) {
      emit(
        state.copyWith(
          listStatus: HistorialListStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        listStatus: HistorialListStatus.error,

        errorMessage: 'No se pudo interpretar la respuesta del historial.',
      ),
    );
  }

  // ========================================================
  // 2. OBTENER DETALLE
  // ========================================================
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
      historialId: event.historialId,
    );

    if (response is Success<ApiResponse<HistorialDetalleData>>) {
      final detalle = response.data.data;

      if (detalle == null) {
        emit(
          state.copyWith(
            detailStatus: HistorialDetailStatus.error,
            errorMessage: 'El servidor no devolvió el detalle del historial.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          detailStatus: HistorialDetailStatus.success,
          historialSelected: detalle,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<ApiResponse<HistorialDetalleData>>) {
      emit(
        state.copyWith(
          detailStatus: HistorialDetailStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        detailStatus: HistorialDetailStatus.error,
        errorMessage: 'No se pudo interpretar el detalle del historial.',
      ),
    );
  }

  // ========================================================
  // 3. CREAR HISTORIAL
  // ========================================================
  Future<void> _onCreateHistorial(
    CreateHistorialEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.actionStatus == HistorialActionStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.loading,
        clearActionData: true,
        clearActionMessage: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.createHistorial.run(
      request: event.request,
    );

    if (response is Success<ApiResponse<HistorialData>>) {
      final historialCreado = response.data.data;

      if (historialCreado == null) {
        emit(
          state.copyWith(
            actionStatus: HistorialActionStatus.error,
            errorMessage: 'El servidor no devolvió el historial creado.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,
          actionData: historialCreado,
          actionMessage: 'Historial registrado correctamente.',
          clearError: true,
        ),
      );

      /*
       * HistorialData y HistorialPatrullajeData son modelos
       * diferentes. Se vuelve a cargar el listado oficial.
       */
      add(
        LoadHistorialPatrullajeEvent(
          patrullajeId: event.request.patrullajeId,

          refresh: true,
        ),
      );

      return;
    }

    if (response is ErrorData<ApiResponse<HistorialData>>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.error,
        errorMessage: 'No se pudo interpretar la respuesta de creación.',
      ),
    );
  }

  // ========================================================
  // 4. CREAR OBSERVACIÓN CON ARCHIVOS
  // ========================================================
  Future<void> _onCreateObservacionConArchivos(
    CreateObservacionConArchivosEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.actionStatus == HistorialActionStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.loading,
        clearActionData: true,
        clearActionMessage: true,
        clearError: true,
      ),
    );

    final response = await historialUseCases.createObservacionConArchivos.run(
      request: event.request,
      archivos: event.archivos,
    );

    if (response is Success<ApiResponse<HistorialData>>) {
      final observacion = response.data.data;

      if (observacion == null) {
        emit(
          state.copyWith(
            actionStatus: HistorialActionStatus.error,
            errorMessage: 'El servidor no devolvió la observación creada.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,
          actionData: observacion,
          actionMessage: 'La observación fue registrada correctamente.',
          clearError: true,
        ),
      );

      add(
        LoadHistorialPatrullajeEvent(
          patrullajeId: event.request.patrullajeId,
          refresh: true,
        ),
      );

      return;
    }

    if (response is ErrorData<ApiResponse<HistorialData>>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.error,
        errorMessage: 'No se pudo interpretar la respuesta de la observación.',
      ),
    );
  }

  // ========================================================
  // 5. OBTENER CONTEXTO DE ZONA
  // ========================================================
  Future<void> _onLoadContextoZona(
    LoadContextoZonaEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.contextoZonaStatus == HistorialContextoZonaStatus.loading &&
        !event.refresh) {
      return;
    }

    emit(
      state.copyWith(
        contextoZonaStatus: HistorialContextoZonaStatus.loading,
        clearError: true,
      ),
    );

    final response = await historialUseCases.getContextoZona.run(
      zonaId: event.zonaId,
      params: event.params,
    );

    if (response is Success<ApiResponse<ContextoZonaData>>) {
      final contexto = response.data.data;

      if (contexto == null) {
        emit(
          state.copyWith(
            contextoZonaStatus: HistorialContextoZonaStatus.error,
            errorMessage: 'El servidor no devolvió el contexto de la zona.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          contextoZonaStatus: contexto.historial.isEmpty
              ? HistorialContextoZonaStatus.empty
              : HistorialContextoZonaStatus.success,
          contextoZona: contexto,
          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<ApiResponse<ContextoZonaData>>) {
      emit(
        state.copyWith(
          contextoZonaStatus: HistorialContextoZonaStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        contextoZonaStatus: HistorialContextoZonaStatus.error,
        errorMessage: 'No se pudo interpretar el contexto de la zona.',
      ),
    );
  }

  // ========================================================
  // 6. OBTENER INFORMACIÓN DEL TURNO ANTERIOR
  // ========================================================
  Future<void> _onLoadSiguienteTurno(
    LoadSiguienteTurnoEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) async {
    if (state.siguienteTurnoStatus == HistorialSiguienteTurnoStatus.loading &&
        !event.refresh) {
      return;
    }

    emit(
      state.copyWith(
        siguienteTurnoStatus: HistorialSiguienteTurnoStatus.loading,
        clearError: true,
      ),
    );

    final response = await historialUseCases.getParaSiguienteTurno.run(
      params: event.params,
    );

    if (response is Success<ApiResponse<SiguienteTurnoData>>) {
      final siguienteTurno = response.data.data;

      if (siguienteTurno == null) {
        emit(
          state.copyWith(
            siguienteTurnoStatus: HistorialSiguienteTurnoStatus.error,
            errorMessage:
                'El servidor no devolvió la información del turno anterior.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          siguienteTurnoStatus: siguienteTurno.tieneContextoAnterior
              ? HistorialSiguienteTurnoStatus.success
              : HistorialSiguienteTurnoStatus.empty,

          siguienteTurno: siguienteTurno,

          clearError: true,
        ),
      );

      return;
    }

    if (response is ErrorData<ApiResponse<SiguienteTurnoData>>) {
      emit(
        state.copyWith(
          siguienteTurnoStatus: HistorialSiguienteTurnoStatus.error,

          errorMessage: response.message,

          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        siguienteTurnoStatus: HistorialSiguienteTurnoStatus.error,

        errorMessage:
            'No se pudo interpretar la información del turno anterior.',
      ),
    );
  }

  // ========================================================
  // 7. ACTUALIZAR HISTORIAL
  // ========================================================
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

        clearActionData: true,

        clearActionMessage: true,

        clearError: true,
      ),
    );

    final response = await historialUseCases.updateHistorial.run(
      historialId: event.historialId,

      request: event.request,
    );

    if (response is Success<ApiResponse<HistorialData>>) {
      final historialActualizado = response.data.data;

      if (historialActualizado == null) {
        emit(
          state.copyWith(
            actionStatus: HistorialActionStatus.error,

            errorMessage: 'El servidor no devolvió el historial actualizado.',
          ),
        );

        return;
      }

      final estabaSeleccionado =
          state.historialSelected?.id == event.historialId;

      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.success,

          actionData: historialActualizado,

          actionMessage: 'Historial actualizado correctamente.',

          clearError: true,
        ),
      );

      add(
        LoadHistorialPatrullajeEvent(
          patrullajeId: event.request.patrullajeId,

          refresh: true,
        ),
      );

      if (estabaSeleccionado) {
        add(LoadHistorialDetalleEvent(historialId: event.historialId));
      }

      return;
    }

    if (response is ErrorData<ApiResponse<HistorialData>>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,

          errorMessage: response.message,

          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.error,

        errorMessage: 'No se pudo interpretar la respuesta de actualización.',
      ),
    );
  }

  // ========================================================
  // 8. ARCHIVAR HISTORIAL
  // ========================================================
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

        clearActionData: true,

        clearActionMessage: true,

        clearError: true,
      ),
    );

    final response = await historialUseCases.archivedHistorial.run(
      historialId: event.historialId,
    );

    if (response is Success<ApiResponse<HistorialData>>) {
      final historialArchivado = response.data.data;

      if (historialArchivado == null) {
        emit(
          state.copyWith(
            actionStatus: HistorialActionStatus.error,

            errorMessage: 'El servidor no devolvió el historial archivado.',
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
          actionData: historialArchivado,
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

    if (response is ErrorData<ApiResponse<HistorialData>>) {
      emit(
        state.copyWith(
          actionStatus: HistorialActionStatus.error,
          errorMessage: response.message,
          errorDetail: response.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.error,
        errorMessage: 'No se pudo interpretar la respuesta del archivado.',
      ),
    );
  }

  // ========================================================
  // 9. LIMPIAR HISTORIAL SELECCIONADO
  // ========================================================
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

  // ========================================================
  // 10. LIMPIAR CONTEXTO DE ZONA
  // ========================================================
  void _onClearContextoZona(
    ClearContextoZonaEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) {
    emit(
      state.copyWith(
        contextoZonaStatus: HistorialContextoZonaStatus.initial,
        clearContextoZona: true,
        clearError: true,
      ),
    );
  }

  // ========================================================
  // 11. LIMPIAR SIGUIENTE TURNO
  // ========================================================
  void _onClearSiguienteTurno(
    ClearSiguienteTurnoEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) {
    emit(
      state.copyWith(
        siguienteTurnoStatus: HistorialSiguienteTurnoStatus.initial,
        clearSiguienteTurno: true,
        clearError: true,
      ),
    );
  }

  // ========================================================
  // 12. LIMPIAR ESTADO DE ACCIÓN
  // ========================================================
  void _onClearAction(
    ClearHistorialActionEvent event,
    Emitter<HistorialPatrullajeState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: HistorialActionStatus.initial,
        clearActionData: true,
        clearActionMessage: true,
        clearError: true,
      ),
    );
  }
}
