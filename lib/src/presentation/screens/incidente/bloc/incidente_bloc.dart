import 'dart:io';

import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

class IncidenteBloc extends Bloc<IncidenteEvent, IncidenteState> {
  final IncidenteUseCases incidenteUseCases;
  final GeolocatorUseCases geolocatorUseCases;
  final MultimediasUseCases mediaUseCases;
  final HistorialPatrullajeUseCases historialUseCases;

  IncidenteBloc(
    this.incidenteUseCases,
    this.geolocatorUseCases,
    this.mediaUseCases,
    this.historialUseCases,
  ) : super(IncidenteState()) {
    on<CrearIncidenteEvent>(_onCrearIncidente);
    on<TomarFotoEvent>(_onTomarFoto);
    on<GrabarVideoEvent>(_onGrabarVideo);
    on<SeleccionarImagenEvent>(_onSeleccionarImagen);
    on<EliminarArchivoEvent>(_onEliminarArchivo);
    on<ObtenerUbicacionEvent>(_onObtenerUbicacion);
  }

  // ==============================
  // CREAR INCIDENCIA
  // ==============================
  Future<void> _onCrearIncidente(
    CrearIncidenteEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    // LOADING
    emit(state.copyWith(isLoading: true, error: null, success: false));

    try {
      // 1. REGISTRAR INCIDENCIA
      final incidencia = await incidenteUseCases.createIncidente.run(
        event.params,
      );

      print("INCIDENCIA BLOC: ${incidencia}");

      // 2. REGISTRAR HISTORIAL AUTOMÁTICO
      final historial = _buildHistorialFromIncidencia(incidencia);

      await historialUseCases.registerResumenHistorial.run(historial);

      print("✅ HISTORIAL REGISTRADO");

      // 3. SUCCESS
      emit(
        state.copyWith(isLoading: false, success: true, incidencia: incidencia),
      );
    } catch (e) {
      // ERROR
      emit(
        state.copyWith(isLoading: false, success: false, error: e.toString()),
      );
    }
  }

  // ==============================
  // FOTO
  // ==============================
  Future<void> _onTomarFoto(
    TomarFotoEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    try {
      final file = await mediaUseCases.takePhoto.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);
        emit(state.copyWith(archivos: nuevos));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ==============================
  // VIDEO
  // ==============================
  Future<void> _onGrabarVideo(
    GrabarVideoEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    try {
      final file = await mediaUseCases.recordVideo.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);
        emit(state.copyWith(archivos: nuevos));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ==============================
  // GALERÍA
  // ==============================
  Future<void> _onSeleccionarImagen(
    SeleccionarImagenEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    try {
      final file = await mediaUseCases.pickImage.run();

      if (file != null) {
        final nuevos = List<File>.from(state.archivos)..add(file);
        emit(state.copyWith(archivos: nuevos));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ==============================
  // ELIMINAR ARCHIVO
  // ==============================
  Future<void> _onEliminarArchivo(
    EliminarArchivoEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    final nuevos = List<File>.from(state.archivos)..removeAt(event.index);

    emit(state.copyWith(archivos: nuevos));
  }

  // ==============================
  // UBICACIÓN
  // ==============================
  Future<void> _onObtenerUbicacion(
    ObtenerUbicacionEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    try {
      Position pos = await geolocatorUseCases.findPosition.run();

      final placemark = await geolocatorUseCases.getPlaceMarkData.run(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude)),
      );

      emit(
        state.copyWith(
          latitud: pos.latitude,
          longitud: pos.longitude,
          direccion: placemark.address,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  HistorialPatrullajeModel _buildHistorialFromIncidencia(
    IncidenteModel incidencia,
  ) {
    return HistorialPatrullajeModel(
      patrullajeId: incidencia.patrullajeId ?? 0,
      serenoId: incidencia.usuarioId,
      zonaId: incidencia.zonaId ?? 0,
      tipo: "ALERTA",
      titulo: "Incidencia reportada: ${incidencia.tipo}",
      descripcion: incidencia.descripcion,
      prioridad: _mapPrioridad(incidencia.tipo),
      latitud: incidencia.latitud,
      longitud: incidencia.longitud,
      visibleParaSiguienteTurno: true,
      estado: "ACTIVO",
    );
  }

  String _mapPrioridad(String tipo) {
    switch (tipo) {
      case "ROBO":
        return "ALTA";

      case "INCENDIO":
        return "CRITICA";

      case "VIOLENCIA":
        return "ALTA";

      case "ACCIDENTE":
        return "MEDIA";

      case "SOSPECHOSO":
        return "MEDIA";

      default:
        return "BAJA";
    }
  }
}
