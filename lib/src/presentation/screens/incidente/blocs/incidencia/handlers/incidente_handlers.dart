import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class IncidenteHandlers {
  final IncidenteUseCases incidenteUseCases;

  const IncidenteHandlers({required this.incidenteUseCases});

  // ======================================================
  // 1. CREAR INCIDENCIA
  // ======================================================

  Future<void> onCrearIncidente(
    CrearIncidenteEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        createResponse: Loading<ApiResponse<RegisterIncidenciaData>>(),
        clearAgregarArchivosResponse: true,
        clearEliminarArchivoResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.createIncidente.run(
        incidente: event.request,
      );

      if (response is Success<ApiResponse<RegisterIncidenciaData>>) {
        final registerData = response.data.data;

        if (registerData == null) {
          emit(
            state.copyWith(
              createResponse: ErrorData<ApiResponse<RegisterIncidenciaData>>(
                message: 'El servidor no devolvió la incidencia registrada.',
              ),
            ),
          );

          return;
        }

        final incidenciaId = registerData.incidencia.id;

        /*
         * Primero confirmamos la creación y limpiamos
         * los archivos locales enviados.
         */
        var newState = state.copyWith(
          createResponse: response,
          archivosLocales: const [],
          totalEvidenciasIncidencia: registerData.incidencia.totalEvidencias,
        );

        emit(newState);

        /*
         * La respuesta de creación no contiene usuario,
         * persona, zona ni los IDs de los archivos.
         *
         * Consultamos el detalle completo para mantener
         * sincronizado el estado.
         */
        final detalleResponse = await incidenteUseCases.getIncidenciaById.run(
          incidenciaId: incidenciaId,
        );

        if (detalleResponse is Success<ApiResponse<IncidenciaDetalleData>>) {
          final incidenciaDetalle = detalleResponse.data.data;

          if (incidenciaDetalle != null) {
            final incidenciaListado = _detalleAListado(incidenciaDetalle);

            final yaExiste = newState.misIncidencias.any(
              (incidencia) => incidencia.id == incidenciaDetalle.id,
            );

            final incidenciasActualizadas = _agregarIncidenciaSinDuplicar(
              incidenciaListado,
              newState.misIncidencias,
            );

            final nuevoTotal = yaExiste
                ? newState.misIncidenciasTotalItems
                : newState.misIncidenciasTotalItems + 1;

            final totalPages = nuevoTotal == 0
                ? 0
                : (nuevoTotal / newState.misIncidenciasLimit).ceil();

            newState = newState.copyWith(
              createResponse: response,
              detalleResponse: detalleResponse,
              incidenciaSeleccionada: incidenciaDetalle,
              misIncidencias: incidenciasActualizadas,
              misIncidenciasTotalItems: nuevoTotal,
              misIncidenciasTotalPages: totalPages,
              totalEvidenciasIncidencia: incidenciaDetalle.totalEvidencias,
            );

            emit(newState);
          }
        }

        /*
         * Consultamos los archivos completos porque el
         * detalle no incluye incidencia_id, sereno_id,
         * estado y updatedAt.
         */
        final archivosResponse = await incidenteUseCases.getArchivosIncidente
            .run(incidenciaId: incidenciaId);

        if (archivosResponse is Success<ApiResponse<IncidenciaArchivosData>>) {
          final archivosData = archivosResponse.data.data;

          if (archivosData != null) {
            emit(
              newState.copyWith(
                createResponse: response,
                archivosResponse: archivosResponse,
                archivosIncidencia: archivosData.items,
                totalArchivosIncidencia: archivosData.total,
                totalEvidenciasIncidencia: archivosData.totalEvidencias,
              ),
            );
          }
        }

        return;
      }

      emit(state.copyWith(createResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          createResponse: ErrorData<ApiResponse<RegisterIncidenciaData>>(
            message: 'No se pudo registrar la incidencia.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // 2. OBTENER MIS INCIDENCIAS
  // ======================================================

  Future<void> onObtenerMisIncidencias(
    ObtenerMisIncidenciasEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final params = event.params;

    final cargarDesdeInicio = params.page == 1 || event.refresh;

    if (cargarDesdeInicio && state.isLoadingMisIncidencias) {
      return;
    }

    if (!cargarDesdeInicio && state.isLoadingMoreMisIncidencias) {
      return;
    }

    emit(
      state.copyWith(
        misIncidenciasResponse: cargarDesdeInicio
            ? Loading<ApiResponse<MisIncidenciasPaginated>>()
            : state.misIncidenciasResponse,
        misIncidenciasParams: params,
        misIncidenciasPage: params.page,
        misIncidenciasLimit: params.limit,
        misIncidenciasHasMore: cargarDesdeInicio
            ? true
            : state.misIncidenciasHasMore,
        isLoadingMoreMisIncidencias: !cargarDesdeInicio,
      ),
    );

    try {
      final response = await incidenteUseCases.getMisIncidencias.run(
        params: params,
      );

      if (response is Success<ApiResponse<MisIncidenciasPaginated>>) {
        final paginated = response.data.data;

        if (paginated == null) {
          emit(
            state.copyWith(
              misIncidenciasResponse:
                  ErrorData<ApiResponse<MisIncidenciasPaginated>>(
                    message: 'La respuesta no contiene incidencias.',
                  ),
              isLoadingMoreMisIncidencias: false,
            ),
          );

          return;
        }

        final pagination = paginated.pagination;

        final incidenciasActualizadas = cargarDesdeInicio
            ? paginated.items
            : _combinarIncidenciasSinDuplicados(
                state.misIncidencias,
                paginated.items,
              );

        emit(
          state.copyWith(
            misIncidenciasResponse: response,
            misIncidencias: incidenciasActualizadas,
            misIncidenciasParams: params,
            misIncidenciasPage: pagination.page,
            misIncidenciasLimit: pagination.limit,
            misIncidenciasTotalItems: pagination.totalItems,
            misIncidenciasTotalPages: pagination.totalPages,
            misIncidenciasHasMore: pagination.hasNextPage,
            isLoadingMoreMisIncidencias: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          misIncidenciasResponse: response,
          isLoadingMoreMisIncidencias: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          misIncidenciasResponse:
              ErrorData<ApiResponse<MisIncidenciasPaginated>>(
                message: 'No se pudieron obtener las incidencias.',
                error: error.toString(),
              ),
          isLoadingMoreMisIncidencias: false,
        ),
      );
    }
  }

  // ======================================================
  // 3. CARGAR MÁS MIS INCIDENCIAS
  // ======================================================

  Future<void> onCargarMasMisIncidencias(
    CargarMasMisIncidenciasEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.isLoadingMoreMisIncidencias ||
        state.isLoadingMisIncidencias ||
        !state.misIncidenciasHasMore) {
      return;
    }

    final params = state.misIncidenciasParams.copyWith(
      page: state.misIncidenciasPage + 1,
    );

    await onObtenerMisIncidencias(
      ObtenerMisIncidenciasEvent(params: params),
      emit,
      state,
    );
  }

  // ======================================================
  // 4. OBTENER INCIDENCIA POR ID
  // ======================================================

  Future<void> onObtenerIncidenciaPorId(
    ObtenerIncidenciaPorIdEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (event.incidenciaId <= 0) {
      emit(
        state.copyWith(
          detalleResponse: ErrorData<ApiResponse<IncidenciaDetalleData>>(
            message: 'El identificador de la incidencia no es válido.',
            statusCode: 400,
          ),
          clearIncidenciaSeleccionada: true,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        detalleResponse: Loading<ApiResponse<IncidenciaDetalleData>>(),
        clearIncidenciaSeleccionada: true,
        archivosIncidencia: const [],
        totalArchivosIncidencia: 0,
        totalEvidenciasIncidencia: 0,
        clearArchivosResponse: true,
        clearAgregarArchivosResponse: true,
        clearEliminarArchivoResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.getIncidenciaById.run(
        incidenciaId: event.incidenciaId,
      );

      if (response is Success<ApiResponse<IncidenciaDetalleData>>) {
        final incidencia = response.data.data;

        if (incidencia == null) {
          emit(
            state.copyWith(
              detalleResponse: ErrorData<ApiResponse<IncidenciaDetalleData>>(
                message:
                    'La respuesta no contiene el detalle de la incidencia.',
              ),
            ),
          );

          return;
        }

        var newState = state.copyWith(
          detalleResponse: response,
          incidenciaSeleccionada: incidencia,
          totalEvidenciasIncidencia: incidencia.totalEvidencias,
        );

        emit(newState);

        /*
         * Consultar archivos completos para administrar
         * posteriormente eliminación y actualización.
         */
        final archivosResponse = await incidenteUseCases.getArchivosIncidente
            .run(incidenciaId: event.incidenciaId);

        if (archivosResponse is Success<ApiResponse<IncidenciaArchivosData>>) {
          final archivosData = archivosResponse.data.data;

          if (archivosData != null) {
            newState = newState.copyWith(
              archivosResponse: archivosResponse,
              archivosIncidencia: archivosData.items,
              totalArchivosIncidencia: archivosData.total,
              totalEvidenciasIncidencia: archivosData.totalEvidencias,
            );

            emit(newState);
          }
        } else {
          emit(newState.copyWith(archivosResponse: archivosResponse));
        }

        return;
      }

      emit(state.copyWith(detalleResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          detalleResponse: ErrorData<ApiResponse<IncidenciaDetalleData>>(
            message: 'No se pudo obtener la incidencia.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // 5. LIMPIAR INCIDENCIA SELECCIONADA
  // ======================================================

  Future<void> onLimpiarIncidenciaSeleccionada(
    LimpiarIncidenciaSeleccionadaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        clearIncidenciaSeleccionada: true,
        clearDetalleResponse: true,
        archivosIncidencia: const [],
        totalArchivosIncidencia: 0,
        totalEvidenciasIncidencia: 0,
        clearArchivosResponse: true,
        clearAgregarArchivosResponse: true,
        clearEliminarArchivoResponse: true,
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================

  IncidenciaListadoData _detalleAListado(IncidenciaDetalleData detalle) {
    return IncidenciaListadoData(
      id: detalle.id,
      usuarioId: detalle.usuarioId,
      patrullajeId: detalle.patrullajeId,
      zonaId: detalle.zonaId,
      tipo: detalle.tipo,
      descripcion: detalle.descripcion,
      latitud: detalle.latitud,
      longitud: detalle.longitud,
      fechaHora: detalle.fechaHora,
      estado: detalle.estado,
      totalEvidencias: detalle.totalEvidencias,
      origen: detalle.origen,
      createdAt: detalle.createdAt,
      updatedAt: detalle.updatedAt,
      usuario: detalle.usuario == null
          ? null
          : IncidenciaUsuarioData(
              id: detalle.usuario!.id,
              username: detalle.usuario!.username,
              persona: detalle.usuario!.persona == null
                  ? null
                  : IncidenciaPersonaData(
                      id: detalle.usuario!.persona!.id,
                      nombres: detalle.usuario!.persona!.nombres,
                      apellidos: detalle.usuario!.persona!.apellidos,
                      fotoPerfil: null,
                    ),
            ),
      zona: detalle.zona == null
          ? null
          : IncidenciaZonaData(
              id: detalle.zona!.id,
              nombre: detalle.zona!.nombre,
            ),
    );
  }

  List<IncidenciaListadoData> _agregarIncidenciaSinDuplicar(
    IncidenciaListadoData nuevaIncidencia,
    List<IncidenciaListadoData> incidenciasActuales,
  ) {
    final incidenciasPorId = <int, IncidenciaListadoData>{};

    incidenciasPorId[nuevaIncidencia.id] = nuevaIncidencia;

    for (final incidencia in incidenciasActuales) {
      incidenciasPorId.putIfAbsent(incidencia.id, () => incidencia);
    }

    final resultado = incidenciasPorId.values.toList();

    resultado.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return resultado;
  }

  List<IncidenciaListadoData> _combinarIncidenciasSinDuplicados(
    List<IncidenciaListadoData> actuales,
    List<IncidenciaListadoData> nuevas,
  ) {
    final incidenciasPorId = <int, IncidenciaListadoData>{};

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
