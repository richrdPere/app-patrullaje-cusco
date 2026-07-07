import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/incidencia_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

class IncidenteState extends Equatable {
  // GENERAL
  final bool isLoading;
  final bool success;
  final String? error;

  // INCIDENTE
  final IncidenteModel? incidencia;
  final IncidenteModel? incidenciaSeleccionada;
  final List<IncidenciaArchivoModel> evidencias;
  final bool loadingEvidencias;

  // INCIDENTES CERCANOS
  final List<IncidenteModel> nearbyIncidents;
  final bool loadingNearby;

  // MAPA DE INCIDENTES
  final List<IncidenteModel> mapaIncidentes;
  final bool loadingMapa;

  // DASHBOARD
  final Map<String, dynamic>? dashboard;
  final bool loadingDashboard;

  // MEDIA
  final List<File> archivos;

  final bool loadingMedia;
  final bool recordingVideo;
  final bool recordingAudio;

  // LOCATION
  final double? latitud;
  final double? longitud;
  final String? direccion;

  final bool loadingLocation;

  // UI
  final IncidenteTabEnum currentTab;
  final bool isSheetExpanded;

  const IncidenteState({
    this.isLoading = false,
    this.success = false,
    this.error,

    // Incidencias
    this.incidencia,
    this.incidenciaSeleccionada,

    // Evidencias
    this.evidencias = const [],
    this.loadingEvidencias = false,

    // Media local
    this.archivos = const [],
    this.loadingMedia = false,
    this.recordingVideo = false,
    this.recordingAudio = false,

    // Ubicación
    this.latitud,
    this.longitud,
    this.direccion,
    this.loadingLocation = false,

    // UI
    this.currentTab = IncidenteTabEnum.incidente,
    this.isSheetExpanded = false,

    // Cercanos
    this.nearbyIncidents = const [],
    this.loadingNearby = false,

    // Mapa
    this.mapaIncidentes = const [],
    this.loadingMapa = false,

    // Dashboard
    this.dashboard,
    this.loadingDashboard = false,
  });

  IncidenteState copyWith({
    bool? isLoading,
    bool? success,
    String? error,

    // Incidencias
    IncidenteModel? incidencia,
    IncidenteModel? incidenciaSeleccionada,

    // Evidencias
    List<IncidenciaArchivoModel>? evidencias,
    bool? loadingEvidencias,

    // Media
    List<File>? archivos,
    bool? loadingMedia,
    bool? recordingVideo,
    bool? recordingAudio,

    // Ubicación
    double? latitud,
    double? longitud,
    String? direccion,
    bool? loadingLocation,

    // UI
    IncidenteTabEnum? currentTab,
    bool? isSheetExpanded,

    // Cercanos
    List<IncidenteModel>? nearbyIncidents,
    bool? loadingNearby,

    // Mapa
    List<IncidenteModel>? mapaIncidentes,
    bool? loadingMapa,

    // Dashboard
    Map<String, dynamic>? dashboard,
    bool? loadingDashboard,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,

      // Incidencias
      incidencia: incidencia ?? this.incidencia,
      incidenciaSeleccionada:
          incidenciaSeleccionada ?? this.incidenciaSeleccionada,

      // Evidencias
      evidencias: evidencias ?? this.evidencias,
      loadingEvidencias: loadingEvidencias ?? this.loadingEvidencias,

      // Media
      archivos: archivos ?? this.archivos,
      loadingMedia: loadingMedia ?? this.loadingMedia,
      recordingVideo: recordingVideo ?? this.recordingVideo,
      recordingAudio: recordingAudio ?? this.recordingAudio,

      // Ubicación
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,
      loadingLocation: loadingLocation ?? this.loadingLocation,

      // UI
      currentTab: currentTab ?? this.currentTab,
      isSheetExpanded: isSheetExpanded ?? this.isSheetExpanded,

      // Cercanos
      nearbyIncidents: nearbyIncidents ?? this.nearbyIncidents,
      loadingNearby: loadingNearby ?? this.loadingNearby,

      // Mapa
      mapaIncidentes: mapaIncidentes ?? this.mapaIncidentes,
      loadingMapa: loadingMapa ?? this.loadingMapa,

      // Dashboard
      dashboard: dashboard ?? this.dashboard,
      loadingDashboard: loadingDashboard ?? this.loadingDashboard,
    );
  }

  @override
  List<Object?> get props => [
    // General
    isLoading,
    success,
    error,

    // Incidencias
    incidencia,
    incidenciaSeleccionada,

    // Evidencias
    evidencias,
    loadingEvidencias,

    // Media
    archivos,
    loadingMedia,
    recordingVideo,
    recordingAudio,

    // Ubicación
    latitud,
    longitud,
    direccion,
    loadingLocation,

    // UI
    currentTab,
    isSheetExpanded,

    // Cercanos
    nearbyIncidents,
    loadingNearby,

    // Mapa
    mapaIncidentes,
    loadingMapa,

    // Dashboard
    dashboard,
    loadingDashboard,
  ];
}
