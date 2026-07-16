import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

// ======================================================
// ESTADOS DE INICIALIZACIÓN
// ======================================================

enum MapaStatus { initial, loading, success, error }

// ======================================================
// ESTADOS DE OBTENCIÓN DE UBICACIÓN
// ======================================================

enum MapaLocationStatus { initial, loading, success, error }

// ======================================================
// ESTADOS DE GEOCODIFICACIÓN
// ======================================================

enum MapaGeocodingStatus { initial, loading, success, empty, error }

// ======================================================
// ESTADOS DE CÁLCULO DE RUTA
// ======================================================

enum MapaRouteStatus { initial, loading, success, empty, error }

class MapaState extends Equatable {
  // ======================================================
  // ESTADO GENERAL
  // ======================================================

  final MapaStatus status;
  final String? errorMessage;

  // ======================================================
  // SERVICIO Y PERMISOS DE UBICACIÓN
  // ======================================================

  final bool isLocationServiceEnabled;
  final LocationPermissionStatus permissionStatus;

  // ======================================================
  // UBICACIÓN DEL DISPOSITIVO
  // ======================================================

  /// Ubicación puntual obtenida desde GeolocatorRepository.
  ///
  /// Puede utilizarse para registrar una incidencia, seleccionar
  /// un origen o centrar inicialmente el mapa.
  final LocationEntity? currentLocation;

  /// Última ubicación recibida durante el seguimiento del patrullaje.
  final LocationEntity? trackingLocation;

  final MapaLocationStatus locationStatus;
  final String? locationErrorMessage;

  // ======================================================
  // CÁMARA
  // ======================================================

  final CameraPosition cameraPosition;

  /// Ubicación correspondiente al punto central actual de la cámara.
  ///
  /// Se actualiza mientras el usuario desplaza el mapa.
  final LocationEntity? cameraTargetLocation;

  // ======================================================
  // GEOCODIFICACIÓN
  // ======================================================

  final PlacemarkData? placemarkData;
  final MapaGeocodingStatus geocodingStatus;
  final String? geocodingErrorMessage;

  // ======================================================
  // SELECCIÓN DE ORIGEN Y DESTINO
  // ======================================================

  final LocationEntity? pickUpLocation;
  final LocationEntity? destinationLocation;

  final String pickUpDescription;
  final String destinationDescription;

  // ======================================================
  // ELEMENTOS VISUALES DE GOOGLE MAPS
  // ======================================================

  final Map<MarkerId, Marker> markers;
  final Set<Polygon> polygons;
  final Map<PolylineId, Polyline> polylines;

  // ======================================================
  // RUTA
  // ======================================================

  /// Puntos originales de dominio que conforman la ruta.
  ///
  /// Se conservan independientemente del Polyline de Google Maps.
  final List<LocationEntity> routePoints;

  final MapaRouteStatus routeStatus;
  final String? routeErrorMessage;

  // ======================================================
  // CONTROLES DEL MAPA
  // ======================================================

  /// Indica si el usuario está seleccionando una ubicación
  /// moviendo el mapa.
  final bool isPickingLocation;

  /// Indica si la cámara debe seguir automáticamente
  /// la ubicación de tracking.
  final bool isAutoCentering;

  const MapaState({
    // Estado general
    this.status = MapaStatus.initial,
    this.errorMessage,

    // Servicio y permisos
    this.isLocationServiceEnabled = false,
    this.permissionStatus = LocationPermissionStatus.unableToDetermine,

    // Ubicación
    this.currentLocation,
    this.trackingLocation,
    this.locationStatus = MapaLocationStatus.initial,
    this.locationErrorMessage,

    // Cámara
    this.cameraPosition = const CameraPosition(
      target: LatLng(-13.5179185199147, -71.97836101065464),
      zoom: 15,
    ),
    this.cameraTargetLocation,

    // Geocodificación
    this.placemarkData,
    this.geocodingStatus = MapaGeocodingStatus.initial,
    this.geocodingErrorMessage,

    // Origen y destino
    this.pickUpLocation,
    this.destinationLocation,
    this.pickUpDescription = '',
    this.destinationDescription = '',

    // Elementos visuales
    this.markers = const <MarkerId, Marker>{},
    this.polygons = const <Polygon>{},
    this.polylines = const <PolylineId, Polyline>{},

    // Ruta
    this.routePoints = const <LocationEntity>[],
    this.routeStatus = MapaRouteStatus.initial,
    this.routeErrorMessage,

    // Controles
    this.isPickingLocation = false,
    this.isAutoCentering = true,
  });

  // ======================================================
  // GETTERS
  // ======================================================

  /// Indica si la aplicación tiene un permiso válido
  /// para acceder a la ubicación.
  bool get hasLocationPermission {
    return permissionStatus == LocationPermissionStatus.whileInUse ||
        permissionStatus == LocationPermissionStatus.always;
  }

  /// Indica si el mapa puede obtener la ubicación del dispositivo.
  bool get canAccessLocation {
    return isLocationServiceEnabled && hasLocationPermission;
  }

  /// Indica si existe un origen y un destino válidos.
  bool get canDrawRoute {
    return pickUpLocation != null && destinationLocation != null;
  }

  /// Indica si existe una ruta dibujada.
  bool get hasRoute {
    return routePoints.isNotEmpty || polylines.isNotEmpty;
  }

  /// Indica si existe una zona asignada dibujada.
  bool get hasAssignedZone {
    return polygons.isNotEmpty;
  }

  /// Devuelve la ubicación que debería utilizarse como referencia
  /// principal en el mapa.
  ///
  /// Se prioriza el tracking porque representa la ubicación más reciente
  /// durante un patrullaje activo.
  LocationEntity? get displayedLocation {
    return trackingLocation ?? currentLocation;
  }

  // ======================================================
  // COPY WITH
  // ======================================================

  static const Object _undefined = Object();

  MapaState copyWith({
    // Estado general
    MapaStatus? status,
    Object? errorMessage = _undefined,

    // Servicio y permisos
    bool? isLocationServiceEnabled,
    LocationPermissionStatus? permissionStatus,

    // Ubicación
    Object? currentLocation = _undefined,
    Object? trackingLocation = _undefined,
    MapaLocationStatus? locationStatus,
    Object? locationErrorMessage = _undefined,

    // Cámara
    CameraPosition? cameraPosition,
    Object? cameraTargetLocation = _undefined,

    // Geocodificación
    Object? placemarkData = _undefined,
    MapaGeocodingStatus? geocodingStatus,
    Object? geocodingErrorMessage = _undefined,

    // Origen y destino
    Object? pickUpLocation = _undefined,
    Object? destinationLocation = _undefined,
    String? pickUpDescription,
    String? destinationDescription,

    // Elementos visuales
    Map<MarkerId, Marker>? markers,
    Set<Polygon>? polygons,
    Map<PolylineId, Polyline>? polylines,

    // Ruta
    List<LocationEntity>? routePoints,
    MapaRouteStatus? routeStatus,
    Object? routeErrorMessage = _undefined,

    // Controles
    bool? isPickingLocation,
    bool? isAutoCentering,
  }) {
    return MapaState(
      // Estado general
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _undefined)
          ? this.errorMessage
          : errorMessage as String?,

      // Servicio y permisos
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,

      // Ubicación
      currentLocation: identical(currentLocation, _undefined)
          ? this.currentLocation
          : currentLocation as LocationEntity?,
      trackingLocation: identical(trackingLocation, _undefined)
          ? this.trackingLocation
          : trackingLocation as LocationEntity?,
      locationStatus: locationStatus ?? this.locationStatus,
      locationErrorMessage: identical(locationErrorMessage, _undefined)
          ? this.locationErrorMessage
          : locationErrorMessage as String?,

      // Cámara
      cameraPosition: cameraPosition ?? this.cameraPosition,
      cameraTargetLocation: identical(cameraTargetLocation, _undefined)
          ? this.cameraTargetLocation
          : cameraTargetLocation as LocationEntity?,

      // Geocodificación
      placemarkData: identical(placemarkData, _undefined)
          ? this.placemarkData
          : placemarkData as PlacemarkData?,
      geocodingStatus: geocodingStatus ?? this.geocodingStatus,
      geocodingErrorMessage: identical(geocodingErrorMessage, _undefined)
          ? this.geocodingErrorMessage
          : geocodingErrorMessage as String?,

      // Origen y destino
      pickUpLocation: identical(pickUpLocation, _undefined)
          ? this.pickUpLocation
          : pickUpLocation as LocationEntity?,
      destinationLocation: identical(destinationLocation, _undefined)
          ? this.destinationLocation
          : destinationLocation as LocationEntity?,
      pickUpDescription: pickUpDescription ?? this.pickUpDescription,
      destinationDescription:
          destinationDescription ?? this.destinationDescription,

      // Elementos visuales
      markers: markers ?? this.markers,
      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,

      // Ruta
      routePoints: routePoints ?? this.routePoints,
      routeStatus: routeStatus ?? this.routeStatus,
      routeErrorMessage: identical(routeErrorMessage, _undefined)
          ? this.routeErrorMessage
          : routeErrorMessage as String?,

      // Controles
      isPickingLocation: isPickingLocation ?? this.isPickingLocation,
      isAutoCentering: isAutoCentering ?? this.isAutoCentering,
    );
  }

  // ======================================================
  // EQUATABLE
  // ======================================================

  @override
  List<Object?> get props => [
    status,
    errorMessage,

    isLocationServiceEnabled,
    permissionStatus,

    currentLocation,
    trackingLocation,
    locationStatus,
    locationErrorMessage,

    cameraPosition,
    cameraTargetLocation,

    placemarkData,
    geocodingStatus,
    geocodingErrorMessage,

    pickUpLocation,
    destinationLocation,
    pickUpDescription,
    destinationDescription,

    markers,
    polygons,
    polylines,

    routePoints,
    routeStatus,
    routeErrorMessage,

    isPickingLocation,
    isAutoCentering,
  ];
}
// import 'dart:async';

// import 'package:equatable/equatable.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

// class MapaState extends Equatable {
//   final Completer<GoogleMapController>? controller;
//   final Position? position;
//   final CameraPosition cameraPosition;
//   final PlacemarkData? placemarkData;
//   final Map<MarkerId, Marker> markers;
//   final LatLng? pickUpLatLng;
//   final LatLng? destinationLatLng;
//   final String pickUpDescription;
//   final String destinationDescription;
//   final LatLng? trackingLatLng;

//   final Set<Polygon> polygons;
//   final Map<PolylineId, Polyline> polylines;
//   final bool isPickingLocation;
//   final bool isAutoCentering;

//   const MapaState({
//     this.position,
//     this.controller,
//     this.placemarkData,
//     this.cameraPosition = const CameraPosition(
//       target: LatLng(-13.5179185199147, -71.97836101065464),
//       zoom: 15.0,
//     ),
//     this.pickUpLatLng,
//     this.destinationLatLng,
//     this.pickUpDescription = '',
//     this.destinationDescription = '',
//     this.trackingLatLng,
//     this.markers = const <MarkerId, Marker>{},

//     this.polygons = const {},
//     this.polylines = const {},
//     this.isPickingLocation = true,
//     this.isAutoCentering = true,
//   });

//   MapaState copyWith({
//     Position? position,
//     Completer<GoogleMapController>? controller,
//     CameraPosition? cameraPosition,
//     PlacemarkData? placemarkData,
//     Map<MarkerId, Marker>? markers,
//     LatLng? pickUpLatLng,
//     LatLng? destinationLatLng,
//     String? pickUpDescription,
//     String? destinationDescription,
//     Set<Polygon>? polygons,
//     Map<PolylineId, Polyline>? polylines,
//     bool? isPickingLocation,
//     bool? isAutoCentering,
//     LatLng? trackingLatLng,
//   }) {
//     return MapaState(
//       position: position ?? this.position,
//       markers: markers ?? this.markers,
//       controller: controller ?? this.controller,
//       cameraPosition: cameraPosition ?? this.cameraPosition,
//       placemarkData: placemarkData ?? this.placemarkData,
//       pickUpLatLng: pickUpLatLng ?? this.pickUpLatLng,
//       destinationLatLng: destinationLatLng ?? this.destinationLatLng,
//       pickUpDescription: pickUpDescription ?? this.pickUpDescription,
//       destinationDescription:
//           destinationDescription ?? this.destinationDescription,
//       trackingLatLng: trackingLatLng ?? this.trackingLatLng,

//       polygons: polygons ?? this.polygons,
//       polylines: polylines ?? this.polylines,
//       isPickingLocation: isPickingLocation ?? this.isPickingLocation,
//       isAutoCentering: isAutoCentering ?? this.isAutoCentering,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     position,
//     markers,
//     controller,
//     cameraPosition,
//     placemarkData,
//     pickUpLatLng,
//     destinationLatLng,
//     pickUpDescription,
//     destinationDescription,
//     trackingLatLng,
//     polygons,
//     polylines,
//     isPickingLocation,
//     isAutoCentering,
//   ];
// }
