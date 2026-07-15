import 'dart:io';

import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class MediaHandlers {
  final MultimediasUseCases mediaUseCases;

  static const int maxArchivos = 5;

  const MediaHandlers({required this.mediaUseCases});

  // ======================================================
  // 1. TOMAR FOTOGRAFÍA
  // ======================================================
  Future<void> onTomarFoto(
    TomarFotoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!_puedeSeleccionarArchivo(state, emit)) {
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.takePhoto.run();

      await _procesarArchivoSeleccionado(
        response: response,
        emit: emit,
        state: state,
        tiposPermitidos: TipoArchivoPermitido.imagen,
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadingMedia: false,
          mediaError: 'No se pudo tomar la fotografía: $error',
        ),
      );
    }
  }

  // ======================================================
  // 2. SELECCIONAR IMAGEN
  // ======================================================
  Future<void> onSeleccionarImagen(
    SeleccionarImagenEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!_puedeSeleccionarArchivo(state, emit)) {
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.pickImage.run();

      await _procesarArchivoSeleccionado(
        response: response,
        emit: emit,
        state: state,
        tiposPermitidos: TipoArchivoPermitido.imagen,
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadingMedia: false,
          mediaError: 'No se pudo seleccionar la imagen: $error',
        ),
      );
    }
  }

  // ======================================================
  // 3. SELECCIONAR VIDEO
  // ======================================================
  Future<void> onSeleccionarVideo(
    SeleccionarVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!_puedeSeleccionarArchivo(state, emit)) {
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.pickVideo.run();

      await _procesarArchivoSeleccionado(
        response: response,
        emit: emit,
        state: state,
        tiposPermitidos: TipoArchivoPermitido.video,
      );
    } catch (error) {
      emit(
        state.copyWith(
          loadingMedia: false,
          mediaError: 'No se pudo seleccionar el video: $error',
        ),
      );
    }
  }

  // ======================================================
  // 4. INICIAR GRABACIÓN DE VIDEO
  // ======================================================
  Future<void> onIniciarGrabacionVideo(
    IniciarGrabacionVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (state.loadingMedia || state.recordingVideo || state.recordingAudio) {
      return;
    }

    if (state.archivosLocales.length >= maxArchivos) {
      emit(
        state.copyWith(
          mediaError:
              'Solo se permiten hasta $maxArchivos archivos por incidencia.',
        ),
      );
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.startVideoRecording.run();

      if (response is Success<bool> && response.data) {
        emit(
          state.copyWith(
            recordingVideo: true,
            recordingAudio: false,
            loadingMedia: false,
            clearMediaError: true,
          ),
        );

        return;
      }

      if (response is ErrorData<bool>) {
        emit(
          state.copyWith(
            recordingVideo: false,
            loadingMedia: false,
            mediaError: response.message,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          recordingVideo: false,
          loadingMedia: false,
          mediaError: 'No se pudo iniciar la grabación de video.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          recordingVideo: false,
          loadingMedia: false,
          mediaError: 'No se pudo iniciar la grabación de video: $error',
        ),
      );
    }
  }

  // ======================================================
  // 5. DETENER GRABACIÓN DE VIDEO
  // ======================================================
  Future<void> onDetenerGrabacionVideo(
    DetenerGrabacionVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!state.recordingVideo || state.loadingMedia) {
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.stopVideoRecording.run();

      await _procesarArchivoSeleccionado(
        response: response,
        emit: emit,
        state: state,
        tiposPermitidos: TipoArchivoPermitido.video,
        finalizarGrabacionVideo: true,
      );
    } catch (error) {
      emit(
        state.copyWith(
          recordingVideo: false,
          loadingMedia: false,
          mediaError: 'No se pudo detener la grabación de video: $error',
        ),
      );
    }
  }

  // ======================================================
  // 6. INICIAR GRABACIÓN DE AUDIO
  // ======================================================
  Future<void> onIniciarGrabacionAudio(
    IniciarGrabacionAudioEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    /*
     * Por ahora se bloquea porque el backend actual no permite
     * archivos de audio en Multer.
     *
     * Cuando agregues m4a, aac, mp3 o wav al backend,
     * puedes reemplazar este bloque por la implementación
     * de startAudioRecording.
     */
    emit(
      state.copyWith(
        recordingAudio: false,
        mediaError:
            'El registro de audio todavía no está habilitado '
            'en el servidor.',
      ),
    );
  }

  // ======================================================
  // 7. DETENER GRABACIÓN DE AUDIO
  // ======================================================
  Future<void> onDetenerGrabacionAudio(
    DetenerGrabacionAudioEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (!state.recordingAudio || state.loadingMedia) {
      return;
    }

    emit(state.copyWith(loadingMedia: true, clearMediaError: true));

    try {
      final response = await mediaUseCases.stopAudioRecording.run();

      await _procesarArchivoSeleccionado(
        response: response,
        emit: emit,
        state: state,
        tiposPermitidos: TipoArchivoPermitido.audio,
        finalizarGrabacionAudio: true,
      );
    } catch (error) {
      emit(
        state.copyWith(
          recordingAudio: false,
          loadingMedia: false,
          mediaError: 'No se pudo detener la grabación de audio: $error',
        ),
      );
    }
  }

  // ======================================================
  // 8. ELIMINAR ARCHIVO LOCAL
  // ======================================================
  Future<void> onEliminarArchivoLocal(
    EliminarArchivoLocalEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    if (event.index < 0 || event.index >= state.archivosLocales.length) {
      emit(state.copyWith(mediaError: 'El archivo seleccionado no es válido.'));

      return;
    }

    final archivosActualizados = List<File>.from(state.archivosLocales)
      ..removeAt(event.index);

    emit(
      state.copyWith(
        archivosLocales: archivosActualizados,
        clearMediaError: true,
      ),
    );
  }

  // ======================================================
  // 9. LIMPIAR ARCHIVOS LOCALES
  // ======================================================
  Future<void> onLimpiarArchivosLocales(
    LimpiarArchivosLocalesEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    /*
     * No se deberían limpiar archivos mientras existe una
     * grabación activa, porque el archivo todavía está en proceso.
     */
    if (state.recordingVideo || state.recordingAudio) {
      emit(
        state.copyWith(
          mediaError:
              'Debe detener la grabación antes de limpiar los archivos.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        archivosLocales: const [],
        loadingMedia: false,
        recordingVideo: false,
        recordingAudio: false,
        clearMediaError: true,
      ),
    );
  }

  // ======================================================
  // PROCESAR RESPUESTA DE ARCHIVO
  // ======================================================
  Future<void> _procesarArchivoSeleccionado({
    required Resource<File?> response,
    required Emitter<IncidenteState> emit,
    required IncidenteState state,
    required TipoArchivoPermitido tiposPermitidos,
    bool finalizarGrabacionVideo = false,
    bool finalizarGrabacionAudio = false,
  }) async {
    if (response is ErrorData<File?>) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          mediaError: response.message,
        ),
      );

      return;
    }

    if (response is! Success<File?>) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          mediaError: 'No se pudo procesar el archivo multimedia.',
        ),
      );

      return;
    }

    final archivo = response.data;

    /*
     * El usuario cerró la cámara o galería.
     * No representa un error.
     */
    if (archivo == null) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          clearMediaError: true,
        ),
      );

      return;
    }

    final validacion = await _validarArchivo(archivo, tiposPermitidos);

    if (validacion != null) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          mediaError: validacion,
        ),
      );

      return;
    }

    final resultado = _agregarArchivoSinDuplicar(
      archivosActuales: state.archivosLocales,
      nuevoArchivo: archivo,
    );

    if (resultado.duplicado) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          mediaError: 'El archivo seleccionado ya fue agregado.',
        ),
      );

      return;
    }

    if (resultado.limiteAlcanzado) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: finalizarGrabacionVideo
              ? false
              : state.recordingVideo,
          recordingAudio: finalizarGrabacionAudio
              ? false
              : state.recordingAudio,
          mediaError:
              'Solo se permiten hasta $maxArchivos archivos por incidencia.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        archivosLocales: resultado.archivos,
        loadingMedia: false,
        recordingVideo: finalizarGrabacionVideo ? false : state.recordingVideo,
        recordingAudio: finalizarGrabacionAudio ? false : state.recordingAudio,
        clearMediaError: true,
      ),
    );
  }

  // ======================================================
  // VALIDAR SI PUEDE SELECCIONAR
  // ======================================================
  bool _puedeSeleccionarArchivo(
    IncidenteState state,
    Emitter<IncidenteState> emit,
  ) {
    if (state.loadingMedia || state.recordingVideo || state.recordingAudio) {
      return false;
    }

    if (state.archivosLocales.length >= maxArchivos) {
      emit(
        state.copyWith(
          mediaError:
              'Solo se permiten hasta $maxArchivos archivos por incidencia.',
        ),
      );

      return false;
    }

    return true;
  }

  // ======================================================
  // VALIDAR ARCHIVO
  // ======================================================
  Future<String?> _validarArchivo(
    File archivo,
    TipoArchivoPermitido tipo,
  ) async {
    if (!await archivo.exists()) {
      return 'El archivo seleccionado no existe o ya no está disponible.';
    }

    final extension = _obtenerExtension(archivo.path);

    switch (tipo) {
      case TipoArchivoPermitido.imagen:
        const extensionesPermitidas = {'jpg', 'jpeg', 'png', 'heic', 'heif'};

        if (!extensionesPermitidas.contains(extension)) {
          return 'Formato de imagen no permitido.';
        }

        break;

      case TipoArchivoPermitido.video:
        const extensionesPermitidas = {'mp4', 'mov'};

        if (!extensionesPermitidas.contains(extension)) {
          return 'Formato de video no permitido.';
        }

        break;

      case TipoArchivoPermitido.audio:
        const extensionesPermitidas = {'m4a', 'aac', 'mp3', 'wav'};

        if (!extensionesPermitidas.contains(extension)) {
          return 'Formato de audio no permitido.';
        }

        break;
    }

    final size = await archivo.length();

    if (size <= 0) {
      return 'El archivo seleccionado está vacío.';
    }

    return null;
  }

  String _obtenerExtension(String filePath) {
    final nombre = filePath.toLowerCase();
    final posicionPunto = nombre.lastIndexOf('.');

    if (posicionPunto == -1 || posicionPunto == nombre.length - 1) {
      return '';
    }

    return nombre.substring(posicionPunto + 1);
  }

  // ======================================================
  // AGREGAR SIN DUPLICAR
  // ======================================================
  _ResultadoAgregarArchivo _agregarArchivoSinDuplicar({
    required List<File> archivosActuales,
    required File nuevoArchivo,
  }) {
    if (archivosActuales.length >= maxArchivos) {
      return _ResultadoAgregarArchivo(
        archivos: archivosActuales,
        limiteAlcanzado: true,
      );
    }

    final existe = archivosActuales.any(
      (archivo) => archivo.path == nuevoArchivo.path,
    );

    if (existe) {
      return _ResultadoAgregarArchivo(
        archivos: archivosActuales,
        duplicado: true,
      );
    }

    return _ResultadoAgregarArchivo(
      archivos: [...archivosActuales, nuevoArchivo],
    );
  }
}

// ======================================================
// TIPOS AUXILIARES
// ======================================================
enum TipoArchivoPermitido { imagen, video, audio }

class _ResultadoAgregarArchivo {
  final List<File> archivos;
  final bool duplicado;
  final bool limiteAlcanzado;

  const _ResultadoAgregarArchivo({
    required this.archivos,
    this.duplicado = false,
    this.limiteAlcanzado = false,
  });
}
