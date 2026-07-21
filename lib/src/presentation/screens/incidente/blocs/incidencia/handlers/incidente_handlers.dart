import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
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
        createResponse: Loading(),
        clearArchivoActionResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.createIncidente.run(
        event.request,
      );

      if (response is Success<IncidenteModel>) {
        final incidenciaCreada = response.data;

        emit(
          state.copyWith(
            createResponse: response,
            incidenciaSeleccionada: incidenciaCreada,

            // Se limpian los archivos locales después de crear.
            archivosLocales: const [],

            // Se actualiza el listado local sin volver a consultar.
            misIncidencias: _agregarIncidenciaSinDuplicar(
              incidenciaCreada,
              state.misIncidencias,
            ),
          ),
        );

        return;
      }

      emit(state.copyWith(createResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          createResponse: ErrorData<IncidenteModel>(
            message: 'No se pudo registrar la incidencia: $error',
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
    final bool cargarDesdeInicio = event.page == 1 || event.refresh;

    emit(
      state.copyWith(
        misIncidenciasResponse: Loading(),
        page: event.page,
        limit: event.limit,
        hasMore: cargarDesdeInicio ? true : state.hasMore,
        isLoadingMore: false,
      ),
    );

    try {
      final response = await incidenteUseCases.getMisIncidencias.run(
        page: event.page,
        limit: event.limit,
        incluirArchivos: event.incluirArchivos,
      );

      if (response is Success<List<IncidenteModel>>) {
        final nuevasIncidencias = response.data;

        final incidenciasActualizadas = cargarDesdeInicio
            ? nuevasIncidencias
            : _combinarIncidenciasSinDuplicados(
                state.misIncidencias,
                nuevasIncidencias,
              );

        emit(
          state.copyWith(
            misIncidenciasResponse: response,
            misIncidencias: incidenciasActualizadas,
            page: event.page,
            limit: event.limit,
            hasMore: nuevasIncidencias.length >= event.limit,
            isLoadingMore: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(misIncidenciasResponse: response, isLoadingMore: false),
      );
    } catch (error) {
      emit(
        state.copyWith(
          misIncidenciasResponse: ErrorData<List<IncidenteModel>>(
            message: 'No se pudieron obtener las incidencias: $error',
          ),
          isLoadingMore: false,
        ),
      );
    }
  }

  // ======================================================
  // 3. CARGAR MÁS INCIDENCIAS
  // ======================================================
  Future<void> onCargarMasMisIncidencias(
    CargarMasMisIncidenciasEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    final int siguientePagina = state.page + 1;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final response = await incidenteUseCases.getMisIncidencias.run(
        page: siguientePagina,
        limit: state.limit,
        incluirArchivos: 'false',
      );

      if (response is Success<List<IncidenteModel>>) {
        final nuevasIncidencias = response.data;

        emit(
          state.copyWith(
            misIncidenciasResponse: response,
            misIncidencias: _combinarIncidenciasSinDuplicados(
              state.misIncidencias,
              nuevasIncidencias,
            ),
            page: siguientePagina,
            hasMore: nuevasIncidencias.length >= state.limit,
            isLoadingMore: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(misIncidenciasResponse: response, isLoadingMore: false),
      );
    } catch (error) {
      emit(
        state.copyWith(
          misIncidenciasResponse: ErrorData<List<IncidenteModel>>(
            message: 'No se pudieron cargar más incidencias: $error',
          ),
          isLoadingMore: false,
        ),
      );
    }
  }

  // ======================================================
  // 4. OBTENER INCIDENCIA POR ID
  // ======================================================
  Future<void> onObtenerIncidenciaPorId(
    ObtenerIncidenciaPorIdEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        detalleResponse: Loading(),
        clearIncidenciaSeleccionada: true,
      ),
    );

    try {
      final response = await incidenteUseCases.getIncidenciaById.run(
        event.incidenciaId,
      );

      if (response is Success<IncidenteModel>) {
        final incidencia = response.data;

        emit(
          state.copyWith(
            detalleResponse: response,
            incidenciaSeleccionada: incidencia,

            // En caso el backend incluya archivos dentro del detalle.
            archivosIncidencia: incidencia.evidencias,
          ),
        );

        return;
      }

      emit(state.copyWith(detalleResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          detalleResponse: ErrorData<IncidenteModel>(
            message: 'No se pudo obtener la incidencia: $error',
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
        clearArchivosResponse: true,
        clearArchivoActionResponse: true,
      ),
    );
  }

  // ======================================================
  // 6. OBTENER INCIDENCIA CONTEXTO
  // ======================================================
  Future<void> onObtenerIncidenciasContexto(
    ObtenerIncidenciasContextoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (event.patrullajeId <= 0 || event.zonaId <= 0) {
      emit(
        state.copyWith(
          contextoResponse: ErrorData<List<IncidenteModel>>(
            message: 'El patrullaje o la zona asignada no son válidos.',
            statusCode: 400,
          ),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        contextoResponse: Loading<List<IncidenteModel>>(),
        contextoPatrullajeId: event.patrullajeId,
        contextoZonaId: event.zonaId,
      ),
    );

    try {
      final responses = await Future.wait<Resource<List<IncidenteModel>>>([
        incidenteUseCases.getIncidenciasByPatrullaje.run(
          patrullajeId: event.patrullajeId,
        ),
        incidenteUseCases.getIncidenciasByZona.run(zonaId: event.zonaId),
      ]);

      final patrullajeResponse = responses[0];
      final zonaResponse = responses[1];

      final incidenciasPatrullaje =
          patrullajeResponse is Success<List<IncidenteModel>>
          ? patrullajeResponse.data
          : <IncidenteModel>[];

      final incidenciasZona = zonaResponse is Success<List<IncidenteModel>>
          ? zonaResponse.data
          : <IncidenteModel>[];

      final ambasConsultasFallaron =
          patrullajeResponse is! Success<List<IncidenteModel>> &&
          zonaResponse is! Success<List<IncidenteModel>>;

      if (ambasConsultasFallaron) {
        emit(
          state.copyWith(
            contextoResponse: ErrorData<List<IncidenteModel>>(
              message: _obtenerMensajeErrorContexto(
                patrullajeResponse,
                zonaResponse,
              ),
            ),
          ),
        );

        return;
      }

      final incidenciasCombinadas = _combinarIncidenciasSinDuplicados(
        incidenciasPatrullaje,
        incidenciasZona,
      );

      emit(
        state.copyWith(
          incidenciasContexto: incidenciasCombinadas,
          contextoResponse: Success<List<IncidenteModel>>(
            incidenciasCombinadas,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          contextoResponse: ErrorData<List<IncidenteModel>>(
            message: 'No se pudieron obtener las incidencias del contexto.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // HELPERS
  // ======================================================
  List<IncidenteModel> _agregarIncidenciaSinDuplicar(
    IncidenteModel nuevaIncidencia,
    List<IncidenteModel> incidenciasActuales,
  ) {
    final incidenciaId = nuevaIncidencia.id;

    if (incidenciaId == null) {
      return [nuevaIncidencia, ...incidenciasActuales];
    }

    final existe = incidenciasActuales.any(
      (incidencia) => incidencia.id == incidenciaId,
    );

    if (existe) {
      return incidenciasActuales
          .map(
            (incidencia) =>
                incidencia.id == incidenciaId ? nuevaIncidencia : incidencia,
          )
          .toList();
    }

    return [nuevaIncidencia, ...incidenciasActuales];
  }

  List<IncidenteModel> _combinarIncidenciasSinDuplicados(
    List<IncidenteModel> actuales,
    List<IncidenteModel> nuevas,
  ) {
    final Map<int, IncidenteModel> incidenciasConId = {};
    final List<IncidenteModel> incidenciasSinId = [];

    for (final incidencia in actuales) {
      final id = incidencia.id;

      if (id == null) {
        incidenciasSinId.add(incidencia);
      } else {
        incidenciasConId[id] = incidencia;
      }
    }

    for (final incidencia in nuevas) {
      final id = incidencia.id;

      if (id == null) {
        incidenciasSinId.add(incidencia);
      } else {
        incidenciasConId[id] = incidencia;
      }
    }

    return [...incidenciasConId.values, ...incidenciasSinId];
  }

  String _obtenerMensajeErrorContexto(
    Resource<List<IncidenteModel>> patrullajeResponse,
    Resource<List<IncidenteModel>> zonaResponse,
  ) {
    if (patrullajeResponse is ErrorData<List<IncidenteModel>>) {
      return patrullajeResponse.message;
    }

    if (zonaResponse is ErrorData<List<IncidenteModel>>) {
      return zonaResponse.message;
    }

    return 'No se pudieron obtener las incidencias del patrullaje o la zona.';
  }
}
