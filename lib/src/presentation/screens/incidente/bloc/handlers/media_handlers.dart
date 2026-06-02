import 'dart:io';

import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';

import '../incidente_event.dart';
import '../incidente_state.dart';

class MediaHandlers {
  final MultimediasUseCases mediaUseCases;

  MediaHandlers({required this.mediaUseCases});

  // ==============================
  // FOTO
  // ==============================
  Future<void> onTomarFoto(
    TomarFotoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingMedia: true, error: null));

    try {
      final file = await mediaUseCases.takePhoto.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);

        emit(state.copyWith(archivos: nuevos, loadingMedia: false));
      } else {
        emit(state.copyWith(loadingMedia: false));
      }
    } catch (e) {
      emit(state.copyWith(loadingMedia: false, error: e.toString()));
    }
  }

  // ==============================
  // IMAGEN GALERÍA
  // ==============================
  Future<void> onSeleccionarImagen(
    SeleccionarImagenEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingMedia: true, error: null));

    try {
      final file = await mediaUseCases.pickImage.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);

        emit(state.copyWith(archivos: nuevos, loadingMedia: false));
      } else {
        emit(state.copyWith(loadingMedia: false));
      }
    } catch (e) {
      emit(state.copyWith(loadingMedia: false, error: e.toString()));
    }
  }

  // ==============================
  // VIDEO GALERÍA
  // ==============================
  Future<void> onSeleccionarVideo(
    SeleccionarVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingMedia: true, error: null));

    try {
      final file = await mediaUseCases.pickVideo.run();

      if (file != null) {
        emit(state.copyWith(archivos: [file], loadingMedia: false));
      } else {
        emit(state.copyWith(loadingMedia: false));
      }
    } catch (e) {
      emit(state.copyWith(loadingMedia: false, error: e.toString()));
    }
  }

  // ==============================
  // VIDEO CÁMARA
  // ==============================
  Future<void> onIniciarGrabacionVideo(
    IniciarGrabacionVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(loadingMedia: true, recordingVideo: true, error: null));

    try {
      final file = await mediaUseCases.recordVideo.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);

        emit(
          state.copyWith(
            archivos: nuevos,
            loadingMedia: false,
            recordingVideo: false,
          ),
        );
      } else {
        emit(state.copyWith(loadingMedia: false, recordingVideo: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          loadingMedia: false,
          recordingVideo: false,
          error: e.toString(),
        ),
      );
    }
  }

  // ==============================
  // DETENER VIDEO
  // ==============================
  Future<void> onDetenerGrabacionVideo(
    DetenerGrabacionVideoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(recordingVideo: false));
  }

  // ==============================
  // ELIMINAR ARCHIVO
  // ==============================
  Future<void> onEliminarArchivo(
    EliminarArchivoEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    final nuevos = List<File>.from(state.archivos)..removeAt(event.index);

    emit(state.copyWith(archivos: nuevos));
  }

  // ==============================
  // LIMPIAR ARCHIVOS
  // ==============================
  Future<void> onLimpiarArchivos(
    LimpiarArchivosEvent event,
    Emitter<IncidenteState> emit,
    IncidenteState state,
  ) async {
    emit(state.copyWith(archivos: []));
  }
}
