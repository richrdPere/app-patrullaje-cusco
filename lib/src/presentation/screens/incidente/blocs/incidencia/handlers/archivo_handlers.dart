import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class ArchivoHandlers {
  final IncidenteUseCases incidenteUseCases;

  const ArchivoHandlers({required this.incidenteUseCases});

  // ======================================================
  // 1. OBTENER ARCHIVOS DE UNA INCIDENCIA
  // ======================================================

  Future<void> onObtenerArchivosIncidencia(
    ObtenerArchivosIncidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
        archivosResponse: Loading<ApiResponse<IncidenciaArchivosData>>(),
        clearAgregarArchivosResponse: true,
        clearEliminarArchivoResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.getArchivosIncidente.run(
        incidenciaId: event.incidenciaId,
      );

      if (response is Success<ApiResponse<IncidenciaArchivosData>>) {
        final archivosData = response.data.data;

        if (archivosData == null) {
          emit(
            state.copyWith(
              archivosResponse: ErrorData<ApiResponse<IncidenciaArchivosData>>(
                message:
                    'La respuesta no contiene los archivos de la incidencia.',
              ),
            ),
          );

          return;
        }

        emit(
          _sincronizarArchivosEnEstado(
            state.copyWith(archivosResponse: response),
            incidenciaId: event.incidenciaId,
            archivosData: archivosData,
          ),
        );

        return;
      }

      emit(state.copyWith(archivosResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          archivosResponse: ErrorData<ApiResponse<IncidenciaArchivosData>>(
            message: 'No se pudieron obtener los archivos.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // 2. AGREGAR ARCHIVOS A UNA INCIDENCIA
  // ======================================================

  Future<void> onAgregarArchivosIncidencia(
    AgregarArchivosIncidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (event.incidenciaId <= 0) {
      emit(
        state.copyWith(
          agregarArchivosResponse:
              ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
                message: 'La incidencia seleccionada no es válida.',
                statusCode: 400,
              ),
        ),
      );

      return;
    }

    if (event.archivos.isEmpty) {
      emit(
        state.copyWith(
          agregarArchivosResponse:
              ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
                message: 'Debe seleccionar al menos un archivo.',
                statusCode: 400,
              ),
        ),
      );

      return;
    }

    if (event.archivos.length > 5) {
      emit(
        state.copyWith(
          agregarArchivosResponse:
              ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
                message: 'Solo se permiten hasta 5 archivos.',
                statusCode: 400,
              ),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        agregarArchivosResponse:
            Loading<ApiResponse<AgregarArchivosIncidenciaData>>(),
        clearEliminarArchivoResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.addArchivosIncidencia.run(
        incidenciaId: event.incidenciaId,
        archivos: event.archivos,
      );

      if (response is Success<ApiResponse<AgregarArchivosIncidenciaData>>) {
        final agregarData = response.data.data;

        /*
         * Se registra primero el resultado de la acción y
         * se limpian los archivos locales enviados.
         */
        final stateAfterAdd = state.copyWith(
          agregarArchivosResponse: response,
          archivosLocales: const [],
          totalEvidenciasIncidencia:
              agregarData?.totalEvidencias ?? state.totalEvidenciasIncidencia,
        );

        emit(stateAfterAdd);

        /*
         * El endpoint de agregar no devuelve el ID
         * generado de cada archivo. Volvemos a consultar
         * para obtener la lista definitiva.
         */
        await _recargarArchivos(
          incidenciaId: event.incidenciaId,
          actionState: stateAfterAdd,
          emit: emit,
        );

        return;
      }

      emit(state.copyWith(agregarArchivosResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          agregarArchivosResponse:
              ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
                message: 'No se pudieron agregar los archivos.',
                error: error.toString(),
              ),
        ),
      );
    }
  }

  // ======================================================
  // 3. ELIMINAR ARCHIVO DE UNA INCIDENCIA
  // ======================================================

  Future<void> onEliminarArchivoIncidencia(
    EliminarArchivoIncidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (event.incidenciaId <= 0 || event.archivoId <= 0) {
      emit(
        state.copyWith(
          eliminarArchivoResponse: ErrorData<void>(
            message: 'La incidencia o el archivo seleccionado no es válido.',
            statusCode: 400,
          ),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        eliminarArchivoResponse: Loading<void>(),
        clearAgregarArchivosResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.removeArchivoIncidente.run(
        incidenciaId: event.incidenciaId,
        archivoId: event.archivoId,
      );

      if (response is Success<void>) {
        /*
         * Eliminación optimista para reflejar de inmediato
         * el cambio en la interfaz.
         */
        final archivosActualizados = state.archivosIncidencia
            .where((archivo) => archivo.id != event.archivoId)
            .toList();

        final optimisticState = _sincronizarListaArchivos(
          state.copyWith(eliminarArchivoResponse: response),
          incidenciaId: event.incidenciaId,
          archivos: archivosActualizados,
          totalEvidencias: archivosActualizados.length,
        );

        emit(optimisticState);

        /*
         * Consulta nuevamente al backend para confirmar
         * los archivos y el total de evidencias.
         */
        await _recargarArchivos(
          incidenciaId: event.incidenciaId,
          actionState: optimisticState,
          emit: emit,
        );

        return;
      }

      emit(state.copyWith(eliminarArchivoResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          eliminarArchivoResponse: ErrorData<void>(
            message: 'No se pudo eliminar el archivo.',
            error: error.toString(),
          ),
        ),
      );
    }
  }

  // ======================================================
  // 4. LIMPIAR ARCHIVOS DE LA INCIDENCIA
  // ======================================================

  Future<void> onLimpiarArchivosIncidencia(
    LimpiarArchivosIncidenciaEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(
      state.copyWith(
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
  // 5. RECARGAR ARCHIVOS DESDE EL BACKEND
  // ======================================================

  Future<void> _recargarArchivos({
    required int incidenciaId,
    required IncidenteState actionState,
    required Emitter<IncidenteState> emit,
  }) async {
    final archivosResponse = await incidenteUseCases.getArchivosIncidente.run(
      incidenciaId: incidenciaId,
    );

    if (archivosResponse is Success<ApiResponse<IncidenciaArchivosData>>) {
      final archivosData = archivosResponse.data.data;

      if (archivosData != null) {
        emit(
          _sincronizarArchivosEnEstado(
            actionState.copyWith(archivosResponse: archivosResponse),
            incidenciaId: incidenciaId,
            archivosData: archivosData,
          ),
        );
      }

      return;
    }

    /*
     * La acción principal fue exitosa, pero no se pudo
     * actualizar el listado remoto. Conservamos el éxito
     * de agregar/eliminar y exponemos el error de recarga.
     */
    emit(actionState.copyWith(archivosResponse: archivosResponse));
  }

  // ======================================================
  // 6. SINCRONIZAR RESPUESTA DE ARCHIVOS
  // ======================================================

  IncidenteState _sincronizarArchivosEnEstado(
    IncidenteState state, {
    required int incidenciaId,
    required IncidenciaArchivosData archivosData,
  }) {
    return _sincronizarListaArchivos(
      state,
      incidenciaId: incidenciaId,
      archivos: archivosData.items,
      totalEvidencias: archivosData.totalEvidencias,
      totalArchivos: archivosData.total,
    );
  }

  // ======================================================
  // 7. SINCRONIZAR LISTAS DEL ESTADO
  // ======================================================

  IncidenteState _sincronizarListaArchivos(
    IncidenteState state, {
    required int incidenciaId,
    required List<IncidenciaArchivoData> archivos,
    required int totalEvidencias,
    int? totalArchivos,
  }) {
    return state.copyWith(
      archivosIncidencia: archivos,
      totalArchivosIncidencia: totalArchivos ?? archivos.length,
      totalEvidenciasIncidencia: totalEvidencias,

      // Detalle seleccionado
      incidenciaSeleccionada: _actualizarDetalle(
        state.incidenciaSeleccionada,
        incidenciaId,
        archivos,
        totalEvidencias,
      ),

      // Mis incidencias
      misIncidencias: _actualizarMisIncidencias(
        state.misIncidencias,
        incidenciaId,
        totalEvidencias,
      ),

      // Incidencias por patrullaje
      incidenciasPatrullaje: _actualizarListaDetalle(
        state.incidenciasPatrullaje,
        incidenciaId,
        archivos,
        totalEvidencias,
      ),

      // Incidencias por zona
      incidenciasZona: _actualizarListaDetalle(
        state.incidenciasZona,
        incidenciaId,
        archivos,
        totalEvidencias,
      ),

      // Incidencias cercanas
      incidentesCercanos: _actualizarIncidenciasCercanas(
        state.incidentesCercanos,
        incidenciaId,
        archivos,
        totalEvidencias,
      ),
    );
  }

  // ======================================================
  // 8. ACTUALIZAR DETALLE
  // ======================================================

  IncidenciaDetalleData? _actualizarDetalle(
    IncidenciaDetalleData? incidencia,
    int incidenciaId,
    List<IncidenciaArchivoData> archivos,
    int totalEvidencias,
  ) {
    if (incidencia == null || incidencia.id != incidenciaId) {
      return incidencia;
    }

    return IncidenciaDetalleData(
      id: incidencia.id,
      usuarioId: incidencia.usuarioId,
      patrullajeId: incidencia.patrullajeId,
      zonaId: incidencia.zonaId,
      tipo: incidencia.tipo,
      descripcion: incidencia.descripcion,
      latitud: incidencia.latitud,
      longitud: incidencia.longitud,
      fechaHora: incidencia.fechaHora,
      estado: incidencia.estado,
      totalEvidencias: totalEvidencias,
      origen: incidencia.origen,
      createdAt: incidencia.createdAt,
      updatedAt: incidencia.updatedAt,
      usuario: incidencia.usuario,
      zona: incidencia.zona,
      patrullaje: incidencia.patrullaje,
      archivos: archivos
          .map(
            (archivo) => IncidenciaDetalleArchivo(
              id: archivo.id,
              urlArchivo: archivo.urlArchivo,
              tipoArchivo: archivo.tipoArchivo,
              mimeType: archivo.mimeType,
              peso: archivo.peso,
            ),
          )
          .toList(),
    );
  }

  // ======================================================
  // 9. ACTUALIZAR LISTA DE DETALLE
  // ======================================================

  List<IncidenciaDetalleData> _actualizarListaDetalle(
    List<IncidenciaDetalleData> incidencias,
    int incidenciaId,
    List<IncidenciaArchivoData> archivos,
    int totalEvidencias,
  ) {
    return incidencias.map((incidencia) {
      return _actualizarDetalle(
            incidencia,
            incidenciaId,
            archivos,
            totalEvidencias,
          ) ??
          incidencia;
    }).toList();
  }

  // ======================================================
  // 10. ACTUALIZAR MIS INCIDENCIAS
  // ======================================================

  List<IncidenciaListadoData> _actualizarMisIncidencias(
    List<IncidenciaListadoData> incidencias,
    int incidenciaId,
    int totalEvidencias,
  ) {
    return incidencias.map((incidencia) {
      if (incidencia.id != incidenciaId) {
        return incidencia;
      }

      return IncidenciaListadoData(
        id: incidencia.id,
        usuarioId: incidencia.usuarioId,
        patrullajeId: incidencia.patrullajeId,
        zonaId: incidencia.zonaId,
        tipo: incidencia.tipo,
        descripcion: incidencia.descripcion,
        latitud: incidencia.latitud,
        longitud: incidencia.longitud,
        fechaHora: incidencia.fechaHora,
        estado: incidencia.estado,
        totalEvidencias: totalEvidencias,
        origen: incidencia.origen,
        createdAt: incidencia.createdAt,
        updatedAt: incidencia.updatedAt,
        usuario: incidencia.usuario,
        zona: incidencia.zona,
      );
    }).toList();
  }

  // ======================================================
  // 11. ACTUALIZAR INCIDENCIAS CERCANAS
  // ======================================================

  List<IncidenciaCercanaData> _actualizarIncidenciasCercanas(
    List<IncidenciaCercanaData> incidencias,
    int incidenciaId,
    List<IncidenciaArchivoData> archivos,
    int totalEvidencias,
  ) {
    return incidencias.map((incidencia) {
      if (incidencia.id != incidenciaId) {
        return incidencia;
      }

      return IncidenciaCercanaData(
        id: incidencia.id,
        usuarioId: incidencia.usuarioId,
        patrullajeId: incidencia.patrullajeId,
        zonaId: incidencia.zonaId,
        tipo: incidencia.tipo,
        descripcion: incidencia.descripcion,
        latitud: incidencia.latitud,
        longitud: incidencia.longitud,
        distanciaMetros: incidencia.distanciaMetros,
        fechaHora: incidencia.fechaHora,
        estado: incidencia.estado,
        totalEvidencias: totalEvidencias,
        origen: incidencia.origen,
        createdAt: incidencia.createdAt,
        updatedAt: incidencia.updatedAt,
        usuario: incidencia.usuario,
        zona: incidencia.zona,
        archivos: archivos
            .map(
              (archivo) => IncidenciaCercanaArchivoData(
                id: archivo.id,
                urlArchivo: archivo.urlArchivo,
                tipoArchivo: archivo.tipoArchivo,
                mimeType: archivo.mimeType,
                peso: archivo.peso,
                createdAt: archivo.createdAt,
              ),
            )
            .toList(),
      );
    }).toList();
  }
}
