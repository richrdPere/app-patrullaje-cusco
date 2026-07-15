import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
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
        archivosResponse: Loading(),
        clearArchivoActionResponse: true,
      ),
    );

    try {
      final response = await incidenteUseCases.getArchivosIncidente.run(
        event.incidenciaId,
      );

      if (response is Success<List<IncidenciaArchivoModel>>) {
        final archivos = response.data;

        emit(
          state.copyWith(
            archivosResponse: response,
            archivosIncidencia: archivos,
            incidenciaSeleccionada: _actualizarArchivosDeIncidencia(
              state.incidenciaSeleccionada,
              event.incidenciaId,
              archivos,
            ),
            misIncidencias: _actualizarIncidenciaEnListado(
              incidencias: state.misIncidencias,
              incidenciaId: event.incidenciaId,
              archivos: archivos,
            ),
          ),
        );

        return;
      }

      emit(state.copyWith(archivosResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          archivosResponse: ErrorData<List<IncidenciaArchivoModel>>(
            message: 'No se pudieron obtener los archivos: $error',
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
    if (event.archivos.isEmpty) {
      emit(
        state.copyWith(
          archivoActionResponse: ErrorData<bool>(
            message: 'Debe seleccionar al menos un archivo.',
          ),
        ),
      );

      return;
    }

    emit(state.copyWith(archivoActionResponse: Loading()));

    try {
      final response = await incidenteUseCases.addArchivosIncidencia.run(
        incidenciaId: event.incidenciaId,
        archivos: event.archivos,
      );

      if (response is Success<bool>) {
        emit(
          state.copyWith(
            archivoActionResponse: response,

            // Los archivos locales ya fueron enviados.
            archivosLocales: const [],
          ),
        );

        /*
         * El endpoint de agregar archivos devuelve Resource<bool>,
         * por lo que no tenemos todavía los archivos creados con:
         *
         * - id
         * - urlArchivo
         * - keyS3
         * - mimeType
         *
         * Después de agregar correctamente, consultamos nuevamente
         * los archivos remotos para mantener sincronizado el estado.
         */
        final archivosResponse = await incidenteUseCases.getArchivosIncidente
            .run(event.incidenciaId);

        if (archivosResponse is Success<List<IncidenciaArchivoModel>>) {
          final archivosActualizados = archivosResponse.data;

          emit(
            state.copyWith(
              archivoActionResponse: response,
              archivosResponse: archivosResponse,
              archivosIncidencia: archivosActualizados,
              archivosLocales: const [],
              incidenciaSeleccionada: _actualizarArchivosDeIncidencia(
                state.incidenciaSeleccionada,
                event.incidenciaId,
                archivosActualizados,
              ),
              misIncidencias: _actualizarIncidenciaEnListado(
                incidencias: state.misIncidencias,
                incidenciaId: event.incidenciaId,
                archivos: archivosActualizados,
              ),
            ),
          );
        }

        return;
      }

      emit(state.copyWith(archivoActionResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          archivoActionResponse: ErrorData<bool>(
            message: 'No se pudieron agregar los archivos: $error',
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
    emit(state.copyWith(archivoActionResponse: Loading()));

    try {
      final response = await incidenteUseCases.removeArchivoIncidente.run(
        incidenciaId: event.incidenciaId,
        archivoId: event.archivoId,
      );

      if (response is Success<bool>) {
        final archivosActualizados = state.archivosIncidencia
            .where((archivo) => archivo.id != event.archivoId)
            .toList();

        emit(
          state.copyWith(
            archivoActionResponse: response,
            archivosIncidencia: archivosActualizados,
            incidenciaSeleccionada: _actualizarArchivosDeIncidencia(
              state.incidenciaSeleccionada,
              event.incidenciaId,
              archivosActualizados,
            ),
            misIncidencias: _actualizarIncidenciaEnListado(
              incidencias: state.misIncidencias,
              incidenciaId: event.incidenciaId,
              archivos: archivosActualizados,
            ),
          ),
        );

        return;
      }

      emit(state.copyWith(archivoActionResponse: response));
    } catch (error) {
      emit(
        state.copyWith(
          archivoActionResponse: ErrorData<bool>(
            message: 'No se pudo eliminar el archivo: $error',
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
        clearArchivosResponse: true,
        clearArchivoActionResponse: true,
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  IncidenteModel? _actualizarArchivosDeIncidencia(
    IncidenteModel? incidencia,
    int incidenciaId,
    List<IncidenciaArchivoModel> archivos,
  ) {
    if (incidencia == null || incidencia.id != incidenciaId) {
      return incidencia;
    }

    return incidencia.copyWith(
      evidencias: archivos,
      totalEvidencias: archivos.length,
    );
  }

  List<IncidenteModel> _actualizarIncidenciaEnListado({
    required List<IncidenteModel> incidencias,
    required int incidenciaId,
    required List<IncidenciaArchivoModel> archivos,
  }) {
    return incidencias.map((incidencia) {
      if (incidencia.id != incidenciaId) {
        return incidencia;
      }

      return incidencia.copyWith(
        evidencias: archivos,
        totalEvidencias: archivos.length,
      );
    }).toList();
  }
}
