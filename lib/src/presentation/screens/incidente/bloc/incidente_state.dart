import 'dart:io';

import 'package:equatable/equatable.dart';
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

  // CONTEXTUAL
  final List<IncidenteModel> nearbyIncidents;
  final bool loadingNearby;

  const IncidenteState({
    this.isLoading = false,
    this.success = false,
    this.error,
    this.incidencia,
    this.archivos = const [],
    this.latitud,
    this.longitud,
    this.direccion,
    this.loadingLocation = false,
    this.currentTab = IncidenteTabEnum.incidente,
    this.isSheetExpanded = false,
    this.nearbyIncidents = const [],
    this.loadingNearby = false,
    this.loadingMedia = false,
    this.recordingVideo = false,
    this.recordingAudio = false,
  });

  IncidenteState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    IncidenteModel? incidencia,
    List<File>? archivos,

    double? latitud,
    double? longitud,
    String? direccion,

    bool? loadingLocation,

    IncidenteTabEnum? currentTab,
    bool? isSheetExpanded,

    List<IncidenteModel>? nearbyIncidents,
    bool? loadingNearby,

    bool? loadingMedia,
    bool? recordingVideo,
    bool? recordingAudio,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
      incidencia: incidencia ?? this.incidencia,
      archivos: archivos ?? this.archivos,

      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,

      loadingLocation: loadingLocation ?? this.loadingLocation,

      currentTab: currentTab ?? this.currentTab,
      isSheetExpanded: isSheetExpanded ?? this.isSheetExpanded,

      nearbyIncidents: nearbyIncidents ?? this.nearbyIncidents,
      loadingNearby: loadingNearby ?? this.loadingNearby,

      loadingMedia: loadingMedia ?? this.loadingMedia,
      recordingVideo: recordingVideo ?? this.recordingVideo,
      recordingAudio: recordingAudio ?? this.recordingAudio,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    success,
    error,
    incidencia,
    archivos,

    latitud,
    longitud,
    direccion,

    loadingLocation,

    currentTab,
    isSheetExpanded,

    nearbyIncidents,
    loadingNearby,

    loadingMedia,
    recordingVideo,
    recordingAudio,
  ];
}
