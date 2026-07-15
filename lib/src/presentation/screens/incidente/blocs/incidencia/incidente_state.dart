import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

class IncidenteState extends Equatable {
  // ======================================================
  // RESPUESTAS DE ACCIONES
  // ======================================================

  /// Respuesta al crear una incidencia.
  final Resource<IncidenteModel>? createResponse;

  /// Respuesta al agregar o eliminar archivos.
  final Resource<bool>? archivoActionResponse;

  // ======================================================
  // MIS INCIDENCIAS
  // ======================================================

  final List<IncidenteModel> misIncidencias;
  final Resource<List<IncidenteModel>>? misIncidenciasResponse;

  final int page;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;

  // ======================================================
  // DETALLE DE INCIDENCIA
  // ======================================================
  final IncidenteModel? incidenciaSeleccionada;
  final Resource<IncidenteModel>? detalleResponse;

  // ======================================================
  // ARCHIVOS REMOTOS
  // ======================================================
  final List<IncidenciaArchivoModel> archivosIncidencia;
  final Resource<List<IncidenciaArchivoModel>>? archivosResponse;

  // ======================================================
  // INCIDENTES CERCANOS
  // ======================================================
  final List<IncidenteModel> incidentesCercanos;
  final Resource<List<IncidenteModel>>? cercanosResponse;

  // ======================================================
  // ARCHIVOS LOCALES
  // ======================================================
  final List<File> archivosLocales;

  final bool loadingMedia;
  final bool recordingVideo;
  final bool recordingAudio;
  final String? mediaError;

  // ======================================================
  // UBICACIÓN
  // ======================================================
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final bool loadingLocation;

  // ======================================================
  // INTERFAZ
  // ======================================================
  final IncidenteTabEnum currentTab;
  final bool isSheetExpanded;

  const IncidenteState({
    // Respuestas
    this.createResponse,
    this.archivoActionResponse,

    // Mis incidencias
    this.misIncidencias = const [],
    this.misIncidenciasResponse,
    this.page = 1,
    this.limit = 10,
    this.hasMore = true,
    this.isLoadingMore = false,

    // Detalle
    this.incidenciaSeleccionada,
    this.detalleResponse,

    // Archivos remotos
    this.archivosIncidencia = const [],
    this.archivosResponse,

    // Cercanos
    this.incidentesCercanos = const [],
    this.cercanosResponse,

    // Archivos locales
    this.archivosLocales = const [],
    this.loadingMedia = false,
    this.recordingVideo = false,
    this.recordingAudio = false,
    this.mediaError,

    // Ubicación
    this.latitud,
    this.longitud,
    this.direccion,
    this.loadingLocation = false,

    // UI
    this.currentTab = IncidenteTabEnum.incidente,
    this.isSheetExpanded = false,
  });

  // ======================================================
  // HELPERS
  // ======================================================

  bool get isCreating => createResponse is Loading;

  bool get isLoadingMisIncidencias =>
      misIncidenciasResponse is Loading && page == 1;

  bool get isLoadingDetalle => detalleResponse is Loading;

  bool get isLoadingArchivos => archivosResponse is Loading;

  bool get isProcessingArchivo => archivoActionResponse is Loading;

  bool get isLoadingCercanos => cercanosResponse is Loading;

  bool get tieneUbicacion => latitud != null && longitud != null;

  bool get tieneArchivosLocales => archivosLocales.isNotEmpty;

  bool get tieneIncidenciaSeleccionada => incidenciaSeleccionada != null;

  // ======================================================
  // COPY WITH
  // ======================================================

  IncidenteState copyWith({
    // Respuestas
    Resource<IncidenteModel>? createResponse,
    bool clearCreateResponse = false,

    Resource<bool>? archivoActionResponse,
    bool clearArchivoActionResponse = false,

    // Mis incidencias
    List<IncidenteModel>? misIncidencias,
    Resource<List<IncidenteModel>>? misIncidenciasResponse,
    bool clearMisIncidenciasResponse = false,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,

    // Detalle
    IncidenteModel? incidenciaSeleccionada,
    bool clearIncidenciaSeleccionada = false,

    Resource<IncidenteModel>? detalleResponse,
    bool clearDetalleResponse = false,

    // Archivos remotos
    List<IncidenciaArchivoModel>? archivosIncidencia,

    Resource<List<IncidenciaArchivoModel>>? archivosResponse,
    bool clearArchivosResponse = false,

    // Cercanos
    List<IncidenteModel>? incidentesCercanos,

    Resource<List<IncidenteModel>>? cercanosResponse,
    bool clearCercanosResponse = false,

    // Archivos locales
    List<File>? archivosLocales,
    bool? loadingMedia,
    bool? recordingVideo,
    bool? recordingAudio,

    String? mediaError,
    bool clearMediaError = false,

    // Ubicación
    double? latitud,
    bool clearLatitud = false,

    double? longitud,
    bool clearLongitud = false,

    String? direccion,
    bool clearDireccion = false,

    bool? loadingLocation,

    // UI
    IncidenteTabEnum? currentTab,
    bool? isSheetExpanded,
  }) {
    return IncidenteState(
      // Respuestas
      createResponse: clearCreateResponse
          ? null
          : createResponse ?? this.createResponse,

      archivoActionResponse: clearArchivoActionResponse
          ? null
          : archivoActionResponse ?? this.archivoActionResponse,

      // Mis incidencias
      misIncidencias: misIncidencias ?? this.misIncidencias,

      misIncidenciasResponse: clearMisIncidenciasResponse
          ? null
          : misIncidenciasResponse ?? this.misIncidenciasResponse,

      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,

      // Detalle
      incidenciaSeleccionada: clearIncidenciaSeleccionada
          ? null
          : incidenciaSeleccionada ?? this.incidenciaSeleccionada,

      detalleResponse: clearDetalleResponse
          ? null
          : detalleResponse ?? this.detalleResponse,

      // Archivos remotos
      archivosIncidencia: archivosIncidencia ?? this.archivosIncidencia,

      archivosResponse: clearArchivosResponse
          ? null
          : archivosResponse ?? this.archivosResponse,

      // Cercanos
      incidentesCercanos: incidentesCercanos ?? this.incidentesCercanos,

      cercanosResponse: clearCercanosResponse
          ? null
          : cercanosResponse ?? this.cercanosResponse,

      // Archivos locales
      archivosLocales: archivosLocales ?? this.archivosLocales,
      loadingMedia: loadingMedia ?? this.loadingMedia,
      recordingVideo: recordingVideo ?? this.recordingVideo,
      recordingAudio: recordingAudio ?? this.recordingAudio,
      mediaError: clearMediaError ? null : mediaError ?? this.mediaError,

      // Ubicación
      latitud: clearLatitud ? null : latitud ?? this.latitud,
      longitud: clearLongitud ? null : longitud ?? this.longitud,
      direccion: clearDireccion ? null : direccion ?? this.direccion,
      loadingLocation: loadingLocation ?? this.loadingLocation,

      // UI
      currentTab: currentTab ?? this.currentTab,
      isSheetExpanded: isSheetExpanded ?? this.isSheetExpanded,
    );
  }

  // ======================================================
  // RESET PARCIAL DEL FORMULARIO
  // ======================================================

  IncidenteState limpiarFormulario() {
    return copyWith(
      archivosLocales: const [],
      loadingMedia: false,
      recordingVideo: false,
      recordingAudio: false,
      clearLatitud: true,
      clearLongitud: true,
      clearDireccion: true,
      currentTab: IncidenteTabEnum.incidente,
      isSheetExpanded: false,
      clearCreateResponse: true,
      clearArchivoActionResponse: true,
    );
  }

  @override
  List<Object?> get props => [
    // Respuestas
    createResponse,
    archivoActionResponse,

    // Mis incidencias
    misIncidencias,
    misIncidenciasResponse,
    page,
    limit,
    hasMore,
    isLoadingMore,

    // Detalle
    incidenciaSeleccionada,
    detalleResponse,

    // Archivos remotos
    archivosIncidencia,
    archivosResponse,

    // Cercanos
    incidentesCercanos,
    cercanosResponse,

    // Archivos locales
    archivosLocales,
    loadingMedia,
    recordingVideo,
    recordingAudio,
    mediaError,

    // Ubicación
    latitud,
    longitud,
    direccion,
    loadingLocation,

    // UI
    currentTab,
    isSheetExpanded,
  ];
}
