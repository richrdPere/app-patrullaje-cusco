import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class ContextHandlers {
  final IncidenteUseCases incidenteUseCases;

  const ContextHandlers({required this.incidenteUseCases});

  // ======================================================
  // 1. OBTENER INCIDENCIAS CERCANAS
  // ======================================================
  Future<void> onObtenerIncidentesCercanos(
    ObtenerIncidentesCercanosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.isLoadingCercanos) {
      return;
    }

    emit(
      state.copyWith(
        cercanosResponse: Loading<ApiResponse<IncidenciasCercanasData>>(),
        cercanosParams: event.params,
      ),
    );

    try {
      final response = await incidenteUseCases.getIncidenciasCercanas.run(
        params: event.params,
      );

      if (response is Success<ApiResponse<IncidenciasCercanasData>>) {
        final cercanasData = response.data.data;

        if (cercanasData == null) {
          emit(
            state.copyWith(
              cercanosResponse: ErrorData<ApiResponse<IncidenciasCercanasData>>(
                message: 'La respuesta no contiene incidencias cercanas.',
              ),
            ),
          );

          return;
        }

        final incidencias = _eliminarDuplicadosCercanos(cercanasData.items);

        emit(
          state.copyWith(
            cercanosResponse: response,
            cercanosParams: event.params,
            incidentesCercanos: incidencias,
            cercanosRadioMetros: cercanasData.radioMetros,
            cercanosTotal: cercanasData.total,
          ),
        );

        return;
      }

      emit(state.copyWith(cercanosResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          cercanosResponse: ErrorData<ApiResponse<IncidenciasCercanasData>>(
            message: 'No se pudieron obtener las incidencias cercanas.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // 2. LIMPIAR INCIDENCIAS CERCANAS
  // ======================================================

  Future<void> onLimpiarIncidentesCercanos(
    LimpiarIncidentesCercanosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        incidentesCercanos: const [],
        cercanosTotal: 0,
        cercanosRadioMetros: 0,
        clearCercanosResponse: true,
        clearCercanosParams: true,
      ),
    );
  }

  // ======================================================
  // 3. OBTENER INCIDENCIAS POR PATRULLAJE
  // ======================================================

  Future<void> onObtenerIncidenciasPatrullaje(
    ObtenerIncidenciasPatrullajeEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final params = event.params;

    final cargarDesdeInicio =
        params.page == 1 ||
        event.refresh ||
        state.contextoPatrullajeId != event.patrullajeId;

    if (cargarDesdeInicio && state.isLoadingIncidenciasPatrullaje) {
      return;
    }

    if (!cargarDesdeInicio && state.isLoadingMorePatrullaje) {
      return;
    }

    emit(
      state.copyWith(
        incidenciasPatrullajeResponse: cargarDesdeInicio
            ? Loading<ApiResponse<IncidenciasPatrullajePaginated>>()
            : state.incidenciasPatrullajeResponse,
        incidenciasPatrullajeParams: params,
        contextoPatrullajeId: event.patrullajeId,
        patrullajePage: params.page,
        patrullajeLimit: params.limit,
        patrullajeHasMore: cargarDesdeInicio ? true : state.patrullajeHasMore,
        isLoadingMorePatrullaje: !cargarDesdeInicio,
      ),
    );

    try {
      final response = await incidenteUseCases.getIncidenciasByPatrullaje.run(
        patrullajeId: event.patrullajeId,
        params: params,
      );

      if (response is Success<ApiResponse<IncidenciasPatrullajePaginated>>) {
        final paginated = response.data.data;

        if (paginated == null) {
          emit(
            state.copyWith(
              incidenciasPatrullajeResponse:
                  ErrorData<ApiResponse<IncidenciasPatrullajePaginated>>(
                    message:
                        'La respuesta no contiene incidencias del patrullaje.',
                  ),
              isLoadingMorePatrullaje: false,
            ),
          );

          return;
        }

        final items = cargarDesdeInicio
            ? paginated.items
            : _combinarDetallesSinDuplicados(
                state.incidenciasPatrullaje,
                paginated.items,
              );

        emit(
          state.copyWith(
            incidenciasPatrullajeResponse: response,
            incidenciasPatrullaje: items,
            incidenciasPatrullajeParams: params,
            contextoPatrullajeId: event.patrullajeId,
            patrullajePage: paginated.page,
            patrullajeLimit: paginated.limit,
            patrullajeTotalItems: paginated.total,
            patrullajeTotalPages: paginated.totalPages,
            patrullajeHasMore: paginated.hasNextPage,
            isLoadingMorePatrullaje: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          incidenciasPatrullajeResponse: response,
          isLoadingMorePatrullaje: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          incidenciasPatrullajeResponse:
              ErrorData<ApiResponse<IncidenciasPatrullajePaginated>>(
                message:
                    'No se pudieron obtener las incidencias del patrullaje.',
                error: error.toString(),
              ),
          isLoadingMorePatrullaje: false,
        ),
      );
    }
  }

  // ======================================================
  // 4. CARGAR MÁS INCIDENCIAS DEL PATRULLAJE
  // ======================================================

  Future<void> onCargarMasIncidenciasPatrullaje(
    CargarMasIncidenciasPatrullajeEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final patrullajeId = state.contextoPatrullajeId;

    if (patrullajeId == null ||
        !state.patrullajeHasMore ||
        state.isLoadingMorePatrullaje ||
        state.isLoadingIncidenciasPatrullaje) {
      return;
    }

    final params = state.incidenciasPatrullajeParams.copyWith(
      page: state.patrullajePage + 1,
    );

    await onObtenerIncidenciasPatrullaje(
      ObtenerIncidenciasPatrullajeEvent(
        patrullajeId: patrullajeId,
        params: params,
      ),
      emit,
      state,
    );
  }

  // ======================================================
  // 5. LIMPIAR INCIDENCIAS DEL PATRULLAJE
  // ======================================================

  Future<void> onLimpiarIncidenciasPatrullaje(
    LimpiarIncidenciasPatrullajeEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        incidenciasPatrullaje: const [],
        incidenciasPatrullajeParams: const IncidenciasPatrullajeQueryParams(),
        clearIncidenciasPatrullajeResponse: true,
        clearContextoPatrullajeId: true,
        patrullajePage: 1,
        patrullajeLimit: 10,
        patrullajeTotalItems: 0,
        patrullajeTotalPages: 0,
        patrullajeHasMore: true,
        isLoadingMorePatrullaje: false,
      ),
    );
  }

  // ======================================================
  // 6. OBTENER INCIDENCIAS POR ZONA
  // ======================================================

  Future<void> onObtenerIncidenciasZona(
    ObtenerIncidenciasZonaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final params = event.params;

    final cargarDesdeInicio =
        params.page == 1 ||
        event.refresh ||
        state.contextoZonaId != event.zonaId;

    if (cargarDesdeInicio && state.isLoadingIncidenciasZona) {
      return;
    }

    if (!cargarDesdeInicio && state.isLoadingMoreZona) {
      return;
    }

    emit(
      state.copyWith(
        incidenciasZonaResponse: cargarDesdeInicio
            ? Loading<ApiResponse<IncidenciasZonaPaginated>>()
            : state.incidenciasZonaResponse,
        incidenciasZonaParams: params,
        contextoZonaId: event.zonaId,
        zonaPage: params.page,
        zonaLimit: params.limit,
        zonaHasMore: cargarDesdeInicio ? true : state.zonaHasMore,
        isLoadingMoreZona: !cargarDesdeInicio,
      ),
    );

    try {
      final response = await incidenteUseCases.getIncidenciasByZona.run(
        zonaId: event.zonaId,
        params: params,
      );

      if (response is Success<ApiResponse<IncidenciasZonaPaginated>>) {
        final paginated = response.data.data;

        if (paginated == null) {
          emit(
            state.copyWith(
              incidenciasZonaResponse:
                  ErrorData<ApiResponse<IncidenciasZonaPaginated>>(
                    message: 'La respuesta no contiene incidencias de la zona.',
                  ),
              isLoadingMoreZona: false,
            ),
          );

          return;
        }

        final items = cargarDesdeInicio
            ? paginated.items
            : _combinarDetallesSinDuplicados(
                state.incidenciasZona,
                paginated.items,
              );

        emit(
          state.copyWith(
            incidenciasZonaResponse: response,
            incidenciasZona: items,
            incidenciasZonaParams: params,
            contextoZonaId: event.zonaId,
            zonaPage: paginated.page,
            zonaLimit: paginated.limit,
            zonaTotalItems: paginated.total,
            zonaTotalPages: paginated.totalPages,
            zonaHasMore: paginated.hasNextPage,
            isLoadingMoreZona: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          incidenciasZonaResponse: response,
          isLoadingMoreZona: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          incidenciasZonaResponse:
              ErrorData<ApiResponse<IncidenciasZonaPaginated>>(
                message: 'No se pudieron obtener las incidencias de la zona.',
                error: error.toString(),
              ),
          isLoadingMoreZona: false,
        ),
      );
    }
  }

  // ======================================================
  // 7. CARGAR MÁS INCIDENCIAS DE LA ZONA
  // ======================================================

  Future<void> onCargarMasIncidenciasZona(
    CargarMasIncidenciasZonaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final zonaId = state.contextoZonaId;

    if (zonaId == null ||
        !state.zonaHasMore ||
        state.isLoadingMoreZona ||
        state.isLoadingIncidenciasZona) {
      return;
    }

    final params = state.incidenciasZonaParams.copyWith(
      page: state.zonaPage + 1,
    );

    await onObtenerIncidenciasZona(
      ObtenerIncidenciasZonaEvent(zonaId: zonaId, params: params),
      emit,
      state,
    );
  }

  // ======================================================
  // 8. LIMPIAR INCIDENCIAS DE LA ZONA
  // ======================================================

  Future<void> onLimpiarIncidenciasZona(
    LimpiarIncidenciasZonaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        incidenciasZona: const [],
        incidenciasZonaParams: const IncidenciasZonaQueryParams(),
        clearIncidenciasZonaResponse: true,
        clearContextoZonaId: true,
        zonaPage: 1,
        zonaLimit: 10,
        zonaTotalItems: 0,
        zonaTotalPages: 0,
        zonaHasMore: true,
        isLoadingMoreZona: false,
      ),
    );
  }

  // ======================================================
  // 9. OBTENER CONTEXTO OPERATIVO
  // ======================================================
  Future<void> onObtenerIncidenciasContexto(
    ObtenerIncidenciasContextoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        incidenciasPatrullajeResponse:
            Loading<ApiResponse<IncidenciasPatrullajePaginated>>(),
        incidenciasZonaResponse:
            Loading<ApiResponse<IncidenciasZonaPaginated>>(),
        incidenciasPatrullajeParams: event.patrullajeParams,
        incidenciasZonaParams: event.zonaParams,
        contextoPatrullajeId: event.patrullajeId,
        contextoZonaId: event.zonaId,
        patrullajePage: event.patrullajeParams.page,
        zonaPage: event.zonaParams.page,
        isLoadingMorePatrullaje: false,
        isLoadingMoreZona: false,
      ),
    );

    try {
      final responses = await Future.wait<dynamic>([
        incidenteUseCases.getIncidenciasByPatrullaje.run(
          patrullajeId: event.patrullajeId,
          params: event.patrullajeParams,
        ),

        incidenteUseCases.getIncidenciasByZona.run(
          zonaId: event.zonaId,
          params: event.zonaParams,
        ),
      ]);

      final patrullajeResponse = responses[0];

      final zonaResponse = responses[1];

      var newState = state.copyWith(
        contextoPatrullajeId: event.patrullajeId,
        contextoZonaId: event.zonaId,
        incidenciasPatrullajeParams: event.patrullajeParams,
        incidenciasZonaParams: event.zonaParams,
      );

      // Patrullaje
      if (patrullajeResponse
          is Success<ApiResponse<IncidenciasPatrullajePaginated>>) {
        final paginated = patrullajeResponse.data.data;

        if (paginated != null) {
          newState = newState.copyWith(
            incidenciasPatrullajeResponse: patrullajeResponse,
            incidenciasPatrullaje: paginated.items,
            patrullajePage: paginated.page,
            patrullajeLimit: paginated.limit,
            patrullajeTotalItems: paginated.total,
            patrullajeTotalPages: paginated.totalPages,
            patrullajeHasMore: paginated.hasNextPage,
          );
        }
      } else {
        newState = newState.copyWith(
          incidenciasPatrullajeResponse: patrullajeResponse,
        );
      }

      // Zona
      if (zonaResponse is Success<ApiResponse<IncidenciasZonaPaginated>>) {
        final paginated = zonaResponse.data.data;

        if (paginated != null) {
          newState = newState.copyWith(
            incidenciasZonaResponse: zonaResponse,
            incidenciasZona: paginated.items,
            zonaPage: paginated.page,
            zonaLimit: paginated.limit,
            zonaTotalItems: paginated.total,
            zonaTotalPages: paginated.totalPages,
            zonaHasMore: paginated.hasNextPage,
          );
        }
      } else {
        newState = newState.copyWith(incidenciasZonaResponse: zonaResponse);
      }

      emit(
        newState.copyWith(
          isLoadingMorePatrullaje: false,
          isLoadingMoreZona: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          incidenciasPatrullajeResponse:
              ErrorData<ApiResponse<IncidenciasPatrullajePaginated>>(
                message: 'No se pudo obtener el contexto del patrullaje.',
                error: error.toString(),
              ),
          incidenciasZonaResponse:
              ErrorData<ApiResponse<IncidenciasZonaPaginated>>(
                message: 'No se pudo obtener el contexto de la zona.',
                error: error.toString(),
              ),
          isLoadingMorePatrullaje: false,
          isLoadingMoreZona: false,
        ),
      );
    }
  }

  // ======================================================
  // 10. LIMPIAR CONTEXTO OPERATIVO
  // ======================================================
  Future<void> onLimpiarIncidenciasContexto(
    LimpiarIncidenciasContextoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        incidenciasPatrullaje: const [],
        incidenciasZona: const [],
        incidenciasPatrullajeParams: const IncidenciasPatrullajeQueryParams(),
        incidenciasZonaParams: const IncidenciasZonaQueryParams(),
        clearIncidenciasPatrullajeResponse: true,
        clearIncidenciasZonaResponse: true,
        clearContextoPatrullajeId: true,
        clearContextoZonaId: true,
        patrullajePage: 1,
        patrullajeLimit: 10,
        patrullajeTotalItems: 0,
        patrullajeTotalPages: 0,
        patrullajeHasMore: true,
        isLoadingMorePatrullaje: false,
        zonaPage: 1,
        zonaLimit: 10,
        zonaTotalItems: 0,
        zonaTotalPages: 0,
        zonaHasMore: true,
        isLoadingMoreZona: false,
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  List<IncidenciaCercanaData> _eliminarDuplicadosCercanos(
    List<IncidenciaCercanaData> incidencias,
  ) {
    final incidenciasPorId = <int, IncidenciaCercanaData>{};

    for (final incidencia in incidencias) {
      incidenciasPorId[incidencia.id] = incidencia;
    }

    final resultado = incidenciasPorId.values.toList();

    resultado.sort((a, b) => a.distanciaMetros.compareTo(b.distanciaMetros));

    return resultado;
  }

  List<IncidenciaDetalleData> _combinarDetallesSinDuplicados(
    List<IncidenciaDetalleData> actuales,
    List<IncidenciaDetalleData> nuevas,
  ) {
    final incidenciasPorId = <int, IncidenciaDetalleData>{};

    for (final incidencia in actuales) {
      incidenciasPorId[incidencia.id] = incidencia;
    }

    for (final incidencia in nuevas) {
      incidenciasPorId[incidencia.id] = incidencia;
    }

    final resultado = incidenciasPorId.values.toList();

    resultado.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return resultado;
  }
}
