import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

class IncidenteState extends Equatable {
  // CREAR INCIDENCIA
  final Resource<ApiResponse<RegisterIncidenciaData>>? createResponse;

  // ACCIONES SOBRE ARCHIVOS
  final Resource<ApiResponse<AgregarArchivosIncidenciaData>>?
  agregarArchivosResponse;

  final Resource<void>? eliminarArchivoResponse;

  // MIS INCIDENCIAS
  final Resource<ApiResponse<MisIncidenciasPaginated>>? misIncidenciasResponse;

  final List<IncidenciaListadoData> misIncidencias;

  final MisIncidenciasQueryParams misIncidenciasParams;

  final int misIncidenciasPage;
  final int misIncidenciasLimit;
  final int misIncidenciasTotalItems;
  final int misIncidenciasTotalPages;

  final bool misIncidenciasHasMore;
  final bool isLoadingMoreMisIncidencias;

  // DETALLE DE INCIDENCIA
  final IncidenciaDetalleData? incidenciaSeleccionada;

  final Resource<ApiResponse<IncidenciaDetalleData>>? detalleResponse;

  // ARCHIVOS REMOTOS
  final List<IncidenciaArchivoData> archivosIncidencia;

  final Resource<ApiResponse<IncidenciaArchivosData>>? archivosResponse;

  final int totalArchivosIncidencia;
  final int totalEvidenciasIncidencia;

  // INCIDENCIAS CERCANAS
  final List<IncidenciaCercanaData> incidentesCercanos;

  final Resource<ApiResponse<IncidenciasCercanasData>>? cercanosResponse;

  final IncidenciasCercanasQueryParams? cercanosParams;

  final double cercanosRadioMetros;
  final int cercanosTotal;

  // INCIDENCIAS POR PATRULLAJE
  final List<IncidenciaDetalleData> incidenciasPatrullaje;

  final Resource<ApiResponse<IncidenciasPatrullajePaginated>>?
  incidenciasPatrullajeResponse;

  final IncidenciasPatrullajeQueryParams incidenciasPatrullajeParams;

  final int? contextoPatrullajeId;

  final int patrullajePage;
  final int patrullajeLimit;
  final int patrullajeTotalItems;
  final int patrullajeTotalPages;

  final bool patrullajeHasMore;
  final bool isLoadingMorePatrullaje;

  // INCIDENCIAS POR ZONA
  final List<IncidenciaDetalleData> incidenciasZona;

  final Resource<ApiResponse<IncidenciasZonaPaginated>>?
  incidenciasZonaResponse;

  final IncidenciasZonaQueryParams incidenciasZonaParams;

  final int? contextoZonaId;

  final int zonaPage;
  final int zonaLimit;
  final int zonaTotalItems;
  final int zonaTotalPages;

  final bool zonaHasMore;
  final bool isLoadingMoreZona;

  // ARCHIVOS LOCALES
  final List<File> archivosLocales;

  final bool loadingMedia;
  final bool recordingVideo;
  final bool recordingAudio;
  final String? mediaError;

  // UBICACIÓN
  final double? latitud;
  final double? longitud;
  final String? direccion;
  final bool loadingLocation;


  // INTERFAZ
  final IncidenteTabEnum currentTab;
  final bool isSheetExpanded;

  const IncidenteState({
    // Crear
    this.createResponse,

    // Acciones archivos
    this.agregarArchivosResponse,
    this.eliminarArchivoResponse,

    // Mis incidencias
    this.misIncidenciasResponse,
    this.misIncidencias = const [],
    this.misIncidenciasParams = const MisIncidenciasQueryParams(),
    this.misIncidenciasPage = 1,
    this.misIncidenciasLimit = 10,
    this.misIncidenciasTotalItems = 0,
    this.misIncidenciasTotalPages = 0,
    this.misIncidenciasHasMore = true,
    this.isLoadingMoreMisIncidencias = false,

    // Detalle
    this.incidenciaSeleccionada,
    this.detalleResponse,

    // Archivos remotos
    this.archivosIncidencia = const [],
    this.archivosResponse,
    this.totalArchivosIncidencia = 0,
    this.totalEvidenciasIncidencia = 0,

    // Cercanos
    this.incidentesCercanos = const [],
    this.cercanosResponse,
    this.cercanosParams,
    this.cercanosRadioMetros = 0,
    this.cercanosTotal = 0,

    // Patrullaje
    this.incidenciasPatrullaje = const [],
    this.incidenciasPatrullajeResponse,
    this.incidenciasPatrullajeParams = const IncidenciasPatrullajeQueryParams(),
    this.contextoPatrullajeId,
    this.patrullajePage = 1,
    this.patrullajeLimit = 10,
    this.patrullajeTotalItems = 0,
    this.patrullajeTotalPages = 0,
    this.patrullajeHasMore = true,
    this.isLoadingMorePatrullaje = false,

    // Zona
    this.incidenciasZona = const [],
    this.incidenciasZonaResponse,
    this.incidenciasZonaParams = const IncidenciasZonaQueryParams(),
    this.contextoZonaId,
    this.zonaPage = 1,
    this.zonaLimit = 10,
    this.zonaTotalItems = 0,
    this.zonaTotalPages = 0,
    this.zonaHasMore = true,
    this.isLoadingMoreZona = false,

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

    // Interfaz
    this.currentTab = IncidenteTabEnum.incidente,
    this.isSheetExpanded = false,
  });

  // ======================================================
  // HELPERS DE CARGA
  // ======================================================

  bool get isCreating => createResponse is Loading;

  bool get isLoadingMisIncidencias =>
      misIncidenciasResponse is Loading && misIncidenciasPage == 1;

  bool get isLoadingDetalle => detalleResponse is Loading;

  bool get isLoadingArchivos => archivosResponse is Loading;

  bool get isAddingArchivos => agregarArchivosResponse is Loading;

  bool get isDeletingArchivo => eliminarArchivoResponse is Loading;

  bool get isProcessingArchivo => isAddingArchivos || isDeletingArchivo;

  bool get isLoadingCercanos => cercanosResponse is Loading;

  bool get isLoadingIncidenciasPatrullaje =>
      incidenciasPatrullajeResponse is Loading && patrullajePage == 1;

  bool get isLoadingIncidenciasZona =>
      incidenciasZonaResponse is Loading && zonaPage == 1;

  bool get isLoadingContexto =>
      isLoadingIncidenciasPatrullaje || isLoadingIncidenciasZona;

  // ======================================================
  // HELPERS DE DATOS
  // ======================================================

  bool get tieneUbicacion => latitud != null && longitud != null;

  bool get tieneArchivosLocales => archivosLocales.isNotEmpty;

  bool get tieneArchivosRemotos => archivosIncidencia.isNotEmpty;

  bool get tieneIncidenciaSeleccionada => incidenciaSeleccionada != null;

  bool get tieneIncidenciasCercanas => incidentesCercanos.isNotEmpty;

  bool get tieneIncidenciasPatrullaje => incidenciasPatrullaje.isNotEmpty;

  bool get tieneIncidenciasZona => incidenciasZona.isNotEmpty;

  bool get tieneIncidenciasContexto =>
      tieneIncidenciasPatrullaje || tieneIncidenciasZona;

  bool get tieneContextoOperativo =>
      contextoPatrullajeId != null || contextoZonaId != null;

  // ======================================================
  // COPY WITH
  // ======================================================
  IncidenteState copyWith({
    // Crear
    Resource<ApiResponse<RegisterIncidenciaData>>? createResponse,
    bool clearCreateResponse = false,

    // Agregar archivos
    Resource<ApiResponse<AgregarArchivosIncidenciaData>>?
    agregarArchivosResponse,
    bool clearAgregarArchivosResponse = false,

    // Eliminar archivo
    Resource<void>? eliminarArchivoResponse,
    bool clearEliminarArchivoResponse = false,

    // Mis incidencias
    Resource<ApiResponse<MisIncidenciasPaginated>>? misIncidenciasResponse,
    bool clearMisIncidenciasResponse = false,

    List<IncidenciaListadoData>? misIncidencias,

    MisIncidenciasQueryParams? misIncidenciasParams,

    int? misIncidenciasPage,
    int? misIncidenciasLimit,
    int? misIncidenciasTotalItems,
    int? misIncidenciasTotalPages,

    bool? misIncidenciasHasMore,
    bool? isLoadingMoreMisIncidencias,

    // Detalle
    IncidenciaDetalleData? incidenciaSeleccionada,

    bool clearIncidenciaSeleccionada = false,

    Resource<ApiResponse<IncidenciaDetalleData>>? detalleResponse,

    bool clearDetalleResponse = false,

    // Archivos remotos
    List<IncidenciaArchivoData>? archivosIncidencia,

    Resource<ApiResponse<IncidenciaArchivosData>>? archivosResponse,

    bool clearArchivosResponse = false,

    int? totalArchivosIncidencia,
    int? totalEvidenciasIncidencia,

    // Cercanos
    List<IncidenciaCercanaData>? incidentesCercanos,

    Resource<ApiResponse<IncidenciasCercanasData>>? cercanosResponse,

    bool clearCercanosResponse = false,

    IncidenciasCercanasQueryParams? cercanosParams,

    bool clearCercanosParams = false,

    double? cercanosRadioMetros,
    int? cercanosTotal,

    // Patrullaje
    List<IncidenciaDetalleData>? incidenciasPatrullaje,

    Resource<ApiResponse<IncidenciasPatrullajePaginated>>?
    incidenciasPatrullajeResponse,

    bool clearIncidenciasPatrullajeResponse = false,

    IncidenciasPatrullajeQueryParams? incidenciasPatrullajeParams,

    int? contextoPatrullajeId,
    bool clearContextoPatrullajeId = false,

    int? patrullajePage,
    int? patrullajeLimit,
    int? patrullajeTotalItems,
    int? patrullajeTotalPages,

    bool? patrullajeHasMore,
    bool? isLoadingMorePatrullaje,

    // Zona
    List<IncidenciaDetalleData>? incidenciasZona,

    Resource<ApiResponse<IncidenciasZonaPaginated>>? incidenciasZonaResponse,

    bool clearIncidenciasZonaResponse = false,

    IncidenciasZonaQueryParams? incidenciasZonaParams,

    int? contextoZonaId,
    bool clearContextoZonaId = false,

    int? zonaPage,
    int? zonaLimit,
    int? zonaTotalItems,
    int? zonaTotalPages,

    bool? zonaHasMore,
    bool? isLoadingMoreZona,

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

    // Interfaz
    IncidenteTabEnum? currentTab,
    bool? isSheetExpanded,
  }) {
    return IncidenteState(
      // Crear
      createResponse: clearCreateResponse
          ? null
          : createResponse ?? this.createResponse,

      // Agregar archivos
      agregarArchivosResponse: clearAgregarArchivosResponse
          ? null
          : agregarArchivosResponse ?? this.agregarArchivosResponse,

      // Eliminar archivo
      eliminarArchivoResponse: clearEliminarArchivoResponse
          ? null
          : eliminarArchivoResponse ?? this.eliminarArchivoResponse,

      // Mis incidencias
      misIncidenciasResponse: clearMisIncidenciasResponse
          ? null
          : misIncidenciasResponse ?? this.misIncidenciasResponse,

      misIncidencias: misIncidencias ?? this.misIncidencias,

      misIncidenciasParams: misIncidenciasParams ?? this.misIncidenciasParams,

      misIncidenciasPage: misIncidenciasPage ?? this.misIncidenciasPage,

      misIncidenciasLimit: misIncidenciasLimit ?? this.misIncidenciasLimit,

      misIncidenciasTotalItems:
          misIncidenciasTotalItems ?? this.misIncidenciasTotalItems,

      misIncidenciasTotalPages:
          misIncidenciasTotalPages ?? this.misIncidenciasTotalPages,

      misIncidenciasHasMore:
          misIncidenciasHasMore ?? this.misIncidenciasHasMore,

      isLoadingMoreMisIncidencias:
          isLoadingMoreMisIncidencias ?? this.isLoadingMoreMisIncidencias,

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

      totalArchivosIncidencia:
          totalArchivosIncidencia ?? this.totalArchivosIncidencia,

      totalEvidenciasIncidencia:
          totalEvidenciasIncidencia ?? this.totalEvidenciasIncidencia,

      // Cercanos
      incidentesCercanos: incidentesCercanos ?? this.incidentesCercanos,

      cercanosResponse: clearCercanosResponse
          ? null
          : cercanosResponse ?? this.cercanosResponse,

      cercanosParams: clearCercanosParams
          ? null
          : cercanosParams ?? this.cercanosParams,

      cercanosRadioMetros: cercanosRadioMetros ?? this.cercanosRadioMetros,

      cercanosTotal: cercanosTotal ?? this.cercanosTotal,

      // Patrullaje
      incidenciasPatrullaje:
          incidenciasPatrullaje ?? this.incidenciasPatrullaje,

      incidenciasPatrullajeResponse: clearIncidenciasPatrullajeResponse
          ? null
          : incidenciasPatrullajeResponse ?? this.incidenciasPatrullajeResponse,

      incidenciasPatrullajeParams:
          incidenciasPatrullajeParams ?? this.incidenciasPatrullajeParams,

      contextoPatrullajeId: clearContextoPatrullajeId
          ? null
          : contextoPatrullajeId ?? this.contextoPatrullajeId,

      patrullajePage: patrullajePage ?? this.patrullajePage,

      patrullajeLimit: patrullajeLimit ?? this.patrullajeLimit,

      patrullajeTotalItems: patrullajeTotalItems ?? this.patrullajeTotalItems,

      patrullajeTotalPages: patrullajeTotalPages ?? this.patrullajeTotalPages,

      patrullajeHasMore: patrullajeHasMore ?? this.patrullajeHasMore,

      isLoadingMorePatrullaje:
          isLoadingMorePatrullaje ?? this.isLoadingMorePatrullaje,

      // Zona
      incidenciasZona: incidenciasZona ?? this.incidenciasZona,

      incidenciasZonaResponse: clearIncidenciasZonaResponse
          ? null
          : incidenciasZonaResponse ?? this.incidenciasZonaResponse,

      incidenciasZonaParams:
          incidenciasZonaParams ?? this.incidenciasZonaParams,

      contextoZonaId: clearContextoZonaId
          ? null
          : contextoZonaId ?? this.contextoZonaId,

      zonaPage: zonaPage ?? this.zonaPage,

      zonaLimit: zonaLimit ?? this.zonaLimit,

      zonaTotalItems: zonaTotalItems ?? this.zonaTotalItems,

      zonaTotalPages: zonaTotalPages ?? this.zonaTotalPages,

      zonaHasMore: zonaHasMore ?? this.zonaHasMore,

      isLoadingMoreZona: isLoadingMoreZona ?? this.isLoadingMoreZona,

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
  // LIMPIAR FORMULARIO
  // ======================================================

  IncidenteState limpiarFormulario() {
    return copyWith(
      archivosLocales: const [],
      loadingMedia: false,
      recordingVideo: false,
      recordingAudio: false,
      clearMediaError: true,
      clearLatitud: true,
      clearLongitud: true,
      clearDireccion: true,
      currentTab: IncidenteTabEnum.incidente,
      isSheetExpanded: false,
      clearCreateResponse: true,
      clearAgregarArchivosResponse: true,
      clearEliminarArchivoResponse: true,
    );
  }

  // ======================================================
  // PROPS
  // ======================================================

  @override
  List<Object?> get props => [
    // Crear y acciones
    createResponse,
    agregarArchivosResponse,
    eliminarArchivoResponse,

    // Mis incidencias
    misIncidenciasResponse,
    misIncidencias,
    misIncidenciasParams,
    misIncidenciasPage,
    misIncidenciasLimit,
    misIncidenciasTotalItems,
    misIncidenciasTotalPages,
    misIncidenciasHasMore,
    isLoadingMoreMisIncidencias,

    // Detalle
    incidenciaSeleccionada,
    detalleResponse,

    // Archivos remotos
    archivosIncidencia,
    archivosResponse,
    totalArchivosIncidencia,
    totalEvidenciasIncidencia,

    // Cercanos
    incidentesCercanos,
    cercanosResponse,
    cercanosParams,
    cercanosRadioMetros,
    cercanosTotal,

    // Patrullaje
    incidenciasPatrullaje,
    incidenciasPatrullajeResponse,
    incidenciasPatrullajeParams,
    contextoPatrullajeId,
    patrullajePage,
    patrullajeLimit,
    patrullajeTotalItems,
    patrullajeTotalPages,
    patrullajeHasMore,
    isLoadingMorePatrullaje,

    // Zona
    incidenciasZona,
    incidenciasZonaResponse,
    incidenciasZonaParams,
    contextoZonaId,
    zonaPage,
    zonaLimit,
    zonaTotalItems,
    zonaTotalPages,
    zonaHasMore,
    isLoadingMoreZona,

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

    // Interfaz
    currentTab,
    isSheetExpanded,
  ];
}
