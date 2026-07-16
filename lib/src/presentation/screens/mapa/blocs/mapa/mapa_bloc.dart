import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geocoding/GeocodingUsesCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/directions/DirectionsUsesCase.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  // ======================================================
  // CASOS DE USO
  // ======================================================

  final GeolocatorUseCases geolocatorUseCases;
  final GeocodingUsesCases geocodingUsesCases;
  final DirectionsUsesCase directionsUsesCase;

  // ======================================================
  // CONTROLADOR DEL MAPA
  // ======================================================

  GoogleMapController? _mapController;

  // Evita ejecutar varias consultas de geocodificación simultáneas.
  bool _isLoadingAddress = false;

  MapaBloc(
    this.geolocatorUseCases,
    this.geocodingUsesCases,
    this.directionsUsesCase,
  ) : super(const MapaState()) {
    // ======================================================
    // INICIALIZACIÓN
    // ======================================================

    on<MapaInitEvent>(_onMapaInit);
    on<MapControllerCreatedEvent>(_onMapControllerCreated);

    // ======================================================
    // UBICACIÓN
    // ======================================================

    on<FindCurrentPositionEvent>(_onFindCurrentPosition);
    on<UseCurrentLocationEvent>(_onUseCurrentLocation);

    // ======================================================
    // CÁMARA
    // ======================================================

    on<CenterMapOnLocationEvent>(_onCenterMapOnLocation);
    on<MapCameraMovedEvent>(_onMapCameraMoved);
    on<MapCameraIdleEvent>(_onMapCameraIdle);

    // ======================================================
    // SELECCIÓN MANUAL
    // ======================================================
    on<TogglePickingLocationEvent>(_onTogglePickingLocation);
    on<SetPickingLocationEvent>(_onSetPickingLocation);
    on<ConfirmPickedLocationEvent>(_onConfirmPickedLocation);

    // ======================================================
    // AUTOCENTRADO
    // ======================================================
    on<ToggleAutoCenterEvent>(_onToggleAutoCenter);
    on<SetAutoCenterEvent>(_onSetAutoCenter);

    // ======================================================
    // ORIGEN Y DESTINO
    // ======================================================
    on<PickUpLocationSelectedEvent>(_onPickUpLocationSelected);
    on<DestinationLocationSelectedEvent>(_onDestinationLocationSelected);
    on<ClearSelectedLocationsEvent>(_onClearSelectedLocations);

    // ======================================================
    // ZONA ASIGNADA
    // ======================================================

    on<DrawAssignedZoneEvent>(_onDrawAssignedZone);
    on<ClearAssignedZoneEvent>(_onClearAssignedZone);

    // ======================================================
    // RUTA
    // ======================================================

    on<DrawRouteEvent>(_onDrawRoute);
    on<ClearRouteEvent>(_onClearRoute);

    // ======================================================
    // TRACKING
    // ======================================================

    on<UpdateTrackingLocationEvent>(_onUpdateTrackingLocation);

    // ======================================================
    // GEOCODIFICACIÓN
    // ======================================================

    on<GetAddressFromLocationEvent>(_onGetAddressFromLocation);

    // ======================================================
    // LIMPIEZA
    // ======================================================

    on<ClearTemporaryMapDataEvent>(_onClearTemporaryMapData);
  }

  // ======================================================
  // 1. INICIALIZACIÓN DEL MAPA
  // ======================================================

  Future<void> _onMapaInit(MapaInitEvent event, Emitter<MapaState> emit) async {
    emit(state.copyWith(status: MapaStatus.loading, errorMessage: null));

    try {
      // 1. Verificar si el servicio GPS está activo.
      final serviceEnabled = await geolocatorUseCases.isLocationServiceEnable
          .run();

      if (!serviceEnabled) {
        emit(
          state.copyWith(
            status: MapaStatus.error,
            isLocationServiceEnabled: false,
            errorMessage:
                'El servicio de ubicación está desactivado. '
                'Activa el GPS para continuar.',
          ),
        );

        return;
      }

      // 2. Verificar el permiso actual.
      var permission = await geolocatorUseCases.checkLocationPermission.run();

      // 3. Solicitarlo únicamente si fue denegado.
      if (permission == LocationPermissionStatus.denied) {
        permission = await geolocatorUseCases.requestLocationPermission.run();
      }

      // 4. Validar que el permiso permita acceder a la ubicación.
      if (!_isPermissionGranted(permission)) {
        emit(
          state.copyWith(
            status: MapaStatus.error,
            isLocationServiceEnabled: true,
            permissionStatus: permission,
            errorMessage: _permissionMessage(permission),
          ),
        );

        return;
      }

      // 5. Intentar recuperar una ubicación rápida almacenada.
      final lastKnownLocation = await geolocatorUseCases.getLastKnowLocation
          .run(tipo: 'MANUAL');

      emit(
        state.copyWith(
          status: MapaStatus.success,
          isLocationServiceEnabled: true,
          permissionStatus: permission,
          currentLocation: lastKnownLocation,
          cameraTargetLocation: lastKnownLocation,
          errorMessage: null,
        ),
      );

      // 6. Obtener una ubicación actual más precisa.
      add(const FindCurrentPositionEvent(tipo: 'MANUAL'));
    } catch (error) {
      emit(
        state.copyWith(
          status: MapaStatus.error,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  // ======================================================
  // 2. REGISTRO DEL CONTROLADOR
  // ======================================================

  Future<void> _onMapControllerCreated(
    MapControllerCreatedEvent event,
    Emitter<MapaState> emit,
  ) async {
    _mapController = event.controller;

    final location = state.displayedLocation;

    if (location == null) return;

    await _animateCamera(location: location, zoom: state.cameraPosition.zoom);
  }

  // ======================================================
  // 3. OBTENER UBICACIÓN ACTUAL
  // ======================================================

  Future<void> _onFindCurrentPosition(
    FindCurrentPositionEvent event,
    Emitter<MapaState> emit,
  ) async {
    emit(
      state.copyWith(
        locationStatus: MapaLocationStatus.loading,
        locationErrorMessage: null,
      ),
    );

    try {
      final location = await geolocatorUseCases.getCurrentLocation.run(
        tipo: event.tipo,
      );

      final placemark = await _getPlacemarkSafely(location);

      final marker = _createCurrentLocationMarker(location);

      final markers = Map<MarkerId, Marker>.from(state.markers)
        ..[marker.markerId] = marker;

      /*
       * Se establece la ubicación actual como origen solamente cuando
       * todavía no existe un origen seleccionado.
       */
      final pickUpLocation = state.pickUpLocation ?? location;

      final pickUpDescription = state.pickUpLocation == null
          ? placemark?.address ?? 'Mi ubicación actual'
          : state.pickUpDescription;

      emit(
        state.copyWith(
          status: MapaStatus.success,
          locationStatus: MapaLocationStatus.success,
          currentLocation: location,
          cameraTargetLocation: location,
          cameraPosition: CameraPosition(
            target: LatLng(location.latitud, location.longitud),
            zoom: 17,
          ),
          pickUpLocation: pickUpLocation,
          pickUpDescription: pickUpDescription,
          placemarkData: placemark,
          markers: markers,
          isPickingLocation: false,
          locationErrorMessage: null,
        ),
      );

      add(CenterMapOnLocationEvent(location: location, zoom: 17));
    } catch (error) {
      emit(
        state.copyWith(
          locationStatus: MapaLocationStatus.error,
          locationErrorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  // ======================================================
  // 4. USAR UBICACIÓN ACTUAL COMO ORIGEN
  // ======================================================

  Future<void> _onUseCurrentLocation(
    UseCurrentLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    emit(
      state.copyWith(
        locationStatus: MapaLocationStatus.loading,
        locationErrorMessage: null,
      ),
    );

    try {
      final location = await geolocatorUseCases.getCurrentLocation.run(
        tipo: event.tipo,
      );

      final placemark = await _getPlacemarkSafely(location);

      final marker = _createCurrentLocationMarker(location);

      final markers = Map<MarkerId, Marker>.from(state.markers)
        ..[marker.markerId] = marker;

      emit(
        state.copyWith(
          locationStatus: MapaLocationStatus.success,
          currentLocation: location,
          pickUpLocation: location,
          pickUpDescription: placemark?.address ?? 'Mi ubicación actual',
          placemarkData: placemark,

          // Al cambiar el origen, limpiamos ruta y destino.
          destinationLocation: null,
          destinationDescription: '',
          routePoints: const [],
          polylines: const <PolylineId, Polyline>{},
          routeStatus: MapaRouteStatus.initial,
          routeErrorMessage: null,

          markers: markers,
          isPickingLocation: false,
          locationErrorMessage: null,
        ),
      );

      add(CenterMapOnLocationEvent(location: location, zoom: 17));
    } catch (error) {
      emit(
        state.copyWith(
          locationStatus: MapaLocationStatus.error,
          locationErrorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  // ======================================================
  // 5. CENTRAR LA CÁMARA
  // ======================================================

  Future<void> _onCenterMapOnLocation(
    CenterMapOnLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    final cameraPosition = CameraPosition(
      target: LatLng(event.location.latitud, event.location.longitud),
      zoom: event.zoom,
      bearing: 0,
    );

    emit(
      state.copyWith(
        cameraPosition: cameraPosition,
        cameraTargetLocation: event.location,
      ),
    );

    await _animateCamera(location: event.location, zoom: event.zoom);
  }

  // ======================================================
  // 6. MOVIMIENTO DE LA CÁMARA
  // ======================================================

  void _onMapCameraMoved(MapCameraMovedEvent event, Emitter<MapaState> emit) {
    final location = LocationEntity(
      latitud: event.latitud,
      longitud: event.longitud,
      fechaHora: DateTime.now(),
      tipo: 'MANUAL',
    );

    emit(
      state.copyWith(
        cameraPosition: CameraPosition(
          target: LatLng(event.latitud, event.longitud),
          zoom: event.zoom,
        ),
        cameraTargetLocation: location,
      ),
    );
  }

  // ======================================================
  // 7. CÁMARA DETENIDA
  // ======================================================
  Future<void> _onMapCameraIdle(
    MapCameraIdleEvent event,
    Emitter<MapaState> emit,
  ) async {
    // Solo procesamos el centro de la cámara mientras
    // el usuario está seleccionando un destino.
    if (!state.isPickingLocation) return;

    if (_isLoadingAddress) return;

    // Evita geocodificar cuando el mapa está demasiado alejado.
    if (state.cameraPosition.zoom < 15) return;

    final selectedLocation = state.cameraTargetLocation;

    if (selectedLocation == null) return;

    _isLoadingAddress = true;

    emit(
      state.copyWith(
        geocodingStatus: MapaGeocodingStatus.loading,
        geocodingErrorMessage: null,
      ),
    );

    try {
      final placemark = await geocodingUsesCases.getPlacemarkFromLocation.run(
        selectedLocation,
      );

      if (placemark == null) {
        emit(
          state.copyWith(
            geocodingStatus: MapaGeocodingStatus.empty,

            // Es un destino provisional hasta que el usuario confirme.
            destinationLocation: selectedLocation,
            destinationDescription: 'Ubicación seleccionada',

            placemarkData: null,
            geocodingErrorMessage: null,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          geocodingStatus: MapaGeocodingStatus.success,

          // Destino provisional.
          destinationLocation: selectedLocation,
          destinationDescription: placemark.address,
          placemarkData: placemark,
          geocodingErrorMessage: null,
        ),
      );

      // final origin = state.pickUpLocation;

      // if (origin != null) {
      //   add(DrawRouteEvent(origin: origin, destination: selectedLocation));
      // }
    } catch (error) {
      emit(
        state.copyWith(
          geocodingStatus: MapaGeocodingStatus.error,
          destinationLocation: selectedLocation,
          destinationDescription: 'Ubicación seleccionada',
          geocodingErrorMessage: _getErrorMessage(error),
        ),
      );
    } finally {
      _isLoadingAddress = false;
    }
  }

  // ======================================================
  // 8. ACTIVAR O DESACTIVAR SELECCIÓN
  // ======================================================
  void _onTogglePickingLocation(
    TogglePickingLocationEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(state.copyWith(isPickingLocation: !state.isPickingLocation));
  }

  void _onSetPickingLocation(
    SetPickingLocationEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(state.copyWith(isPickingLocation: event.enabled));
  }

  // ======================================================
  // 9. CONFIRMAR UBICACIÓN SELECCIONADA
  // ======================================================
  Future<void> _onConfirmPickedLocation(
    ConfirmPickedLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    final selectedLocation =
        state.destinationLocation ?? state.cameraTargetLocation;

    if (selectedLocation == null) {
      emit(
        state.copyWith(
          locationErrorMessage:
              'No se pudo determinar la ubicación seleccionada.',
        ),
      );

      return;
    }

    final origin =
        state.pickUpLocation ?? state.trackingLocation ?? state.currentLocation;

    final description = state.destinationDescription.trim().isNotEmpty
        ? state.destinationDescription
        : state.placemarkData?.address ?? 'Ubicación seleccionada';

    /*
   * Primero se desactiva el modo selección.
   *
   * De esta manera, cuando _fitCameraToRoute mueva la cámara,
   * MapCameraIdleEvent no volverá a interpretar el centro
   * como un destino nuevo.
   */
    emit(
      state.copyWith(
        destinationLocation: selectedLocation,
        destinationDescription: description,
        isPickingLocation: false,
        isAutoCentering: false,
        locationErrorMessage: null,
      ),
    );

    if (origin == null) {
      emit(
        state.copyWith(
          routeStatus: MapaRouteStatus.error,
          routeErrorMessage: 'No se pudo determinar la ubicación de origen.',
        ),
      );

      return;
    }

    // add(GetAddressFromLocationEvent(location: selectedLocation));
    add(DrawRouteEvent(origin: origin, destination: selectedLocation));
  }

  // ======================================================
  // 10. AUTOCENTRADO
  // ======================================================

  void _onToggleAutoCenter(
    ToggleAutoCenterEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(state.copyWith(isAutoCentering: !state.isAutoCentering));
  }

  void _onSetAutoCenter(SetAutoCenterEvent event, Emitter<MapaState> emit) {
    emit(state.copyWith(isAutoCentering: event.enabled));
  }

  // ======================================================
  // 11. SELECCIONAR ORIGEN
  // ======================================================

  void _onPickUpLocationSelected(
    PickUpLocationSelectedEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(
      state.copyWith(
        pickUpLocation: event.location,
        pickUpDescription: event.description,
        isPickingLocation: true,

        // Una ruta anterior deja de ser válida al cambiar el origen.
        routePoints: const [],
        polylines: const <PolylineId, Polyline>{},
        routeStatus: MapaRouteStatus.initial,
        routeErrorMessage: null,
      ),
    );

    add(CenterMapOnLocationEvent(location: event.location, zoom: 17));
  }

  // ======================================================
  // 12. SELECCIONAR DESTINO
  // ======================================================

  void _onDestinationLocationSelected(
    DestinationLocationSelectedEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(
      state.copyWith(
        destinationLocation: event.location,
        destinationDescription: event.description,
        isPickingLocation: false,
      ),
    );

    final origin = state.pickUpLocation;

    if (origin == null) return;

    add(DrawRouteEvent(origin: origin, destination: event.location));
  }

  // ======================================================
  // 13. LIMPIAR ORIGEN Y DESTINO
  // ======================================================

  void _onClearSelectedLocations(
    ClearSelectedLocationsEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(
      state.copyWith(
        pickUpLocation: null,
        destinationLocation: null,
        pickUpDescription: '',
        destinationDescription: '',
        placemarkData: null,

        routePoints: const [],
        polylines: const <PolylineId, Polyline>{},
        routeStatus: MapaRouteStatus.initial,
        routeErrorMessage: null,
      ),
    );
  }

  // ======================================================
  // 14. DIBUJAR ZONA ASIGNADA
  // ======================================================

  void _onDrawAssignedZone(
    DrawAssignedZoneEvent event,
    Emitter<MapaState> emit,
  ) {
    if (event.coordenadas.length < 3) {
      emit(state.copyWith(polygons: const <Polygon>{}));

      return;
    }

    debugPrint("Dibujando zona: ${event.coordenadas}");

    final points = event.coordenadas
        .map((coordinate) {
          return LatLng(coordinate.lat, coordinate.lng);
        })
        .toList(growable: false);

    final polygon = Polygon(
      polygonId: const PolygonId('zona_asignada'),
      points: points,
      strokeWidth: 3,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withValues(alpha: 0.20),
    );

    emit(state.copyWith(polygons: <Polygon>{polygon}));
  }

  // ======================================================
  // 15. LIMPIAR ZONA ASIGNADA
  // ======================================================

  void _onClearAssignedZone(
    ClearAssignedZoneEvent event,
    Emitter<MapaState> emit,
  ) {
    emit(state.copyWith(polygons: const <Polygon>{}));
  }

  // ======================================================
  // 16. CALCULAR Y DIBUJAR RUTA
  // ======================================================
  Future<void> _onDrawRoute(
    DrawRouteEvent event,
    Emitter<MapaState> emit,
  ) async {
    emit(
      state.copyWith(
        routeStatus: MapaRouteStatus.loading,
        routeErrorMessage: null,
        routePoints: const <LocationEntity>[],
        polylines: const <PolylineId, Polyline>{},
      ),
    );

    try {
      final routePoints = await directionsUsesCase.getRoute.run(
        origin: event.origin,
        destination: event.destination,
      );

      if (routePoints.isEmpty) {
        emit(
          state.copyWith(
            routeStatus: MapaRouteStatus.empty,
            routePoints: const <LocationEntity>[],
            polylines: const <PolylineId, Polyline>{},
            routeErrorMessage: null,
          ),
        );

        return;
      }

      final googleMapPoints = routePoints
          .map((location) => LatLng(location.latitud, location.longitud))
          .toList(growable: false);

      if (googleMapPoints.length < 2) {
        emit(
          state.copyWith(
            routeStatus: MapaRouteStatus.empty,
            routePoints: List<LocationEntity>.unmodifiable(routePoints),
            polylines: const <PolylineId, Polyline>{},
            routeErrorMessage:
                'No se puede dibujar una ruta con un solo punto.',
          ),
        );

        return;
      }

      const polylineId = PolylineId('route');

      final polyline = Polyline(
        polylineId: polylineId,
        points: googleMapPoints,
        width: 6,
        color: Colors.blueAccent,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      );

      final updatedPolylines = <PolylineId, Polyline>{polylineId: polyline};

      emit(
        state.copyWith(
          routeStatus: MapaRouteStatus.success,
          routePoints: List<LocationEntity>.unmodifiable(routePoints),
          polylines: updatedPolylines,
          routeErrorMessage: null,
        ),
      );

      await _fitCameraToRoute(googleMapPoints);
    } catch (error, stackTrace) {
      debugPrint('❌ Error dibujando ruta: $error');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(
          routeStatus: MapaRouteStatus.error,
          routeErrorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  // ======================================================
  // 17. LIMPIAR RUTA
  // ======================================================

  void _onClearRoute(ClearRouteEvent event, Emitter<MapaState> emit) {
    emit(
      state.copyWith(
        routePoints: const <LocationEntity>[],
        polylines: const <PolylineId, Polyline>{},
        routeStatus: MapaRouteStatus.initial,
        routeErrorMessage: null,
      ),
    );
  }

  // ======================================================
  // 18. ACTUALIZAR TRACKING
  // ======================================================
  Future<void> _onUpdateTrackingLocation(
    UpdateTrackingLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    final marker = Marker(
      markerId: const MarkerId('tracking'),
      position: LatLng(event.location.latitud, event.location.longitud),
      infoWindow: InfoWindow(
        title: 'Mi ubicación',
        snippet: _trackingMarkerDescription(event.location),
      ),
      anchor: const Offset(0.5, 0.5),
    );

    final markers = Map<MarkerId, Marker>.from(state.markers)
      ..[marker.markerId] = marker;

    emit(state.copyWith(trackingLocation: event.location, markers: markers));

    if (state.isAutoCentering) {
      await _animateCamera(location: event.location, zoom: 17);
    }
  }

  // ======================================================
  // 19. OBTENER DIRECCIÓN
  // ======================================================

  Future<void> _onGetAddressFromLocation(
    GetAddressFromLocationEvent event,
    Emitter<MapaState> emit,
  ) async {
    if (_isLoadingAddress) return;

    _isLoadingAddress = true;

    emit(
      state.copyWith(
        geocodingStatus: MapaGeocodingStatus.loading,
        geocodingErrorMessage: null,
      ),
    );

    try {
      final placemark = await geocodingUsesCases.getPlacemarkFromLocation.run(
        event.location,
      );

      if (placemark == null) {
        emit(
          state.copyWith(
            geocodingStatus: MapaGeocodingStatus.empty,
            placemarkData: null,
            destinationLocation: event.location,
            destinationDescription: 'Ubicación seleccionada',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          geocodingStatus: MapaGeocodingStatus.success,
          placemarkData: placemark,
          destinationLocation: event.location,
          destinationDescription: placemark.address,
          geocodingErrorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          geocodingStatus: MapaGeocodingStatus.error,
          geocodingErrorMessage: _getErrorMessage(error),
        ),
      );
    } finally {
      _isLoadingAddress = false;
    }
  }

  // ======================================================
  // 20. LIMPIEZA GENERAL
  // ======================================================

  void _onClearTemporaryMapData(
    ClearTemporaryMapDataEvent event,
    Emitter<MapaState> emit,
  ) {
    final trackingMarker = state.markers[const MarkerId('tracking')];

    final currentLocationMarker =
        state.markers[const MarkerId('current_location')];

    final persistentMarkers = <MarkerId, Marker>{};

    if (trackingMarker != null) {
      persistentMarkers[trackingMarker.markerId] = trackingMarker;
    }

    if (currentLocationMarker != null) {
      persistentMarkers[currentLocationMarker.markerId] = currentLocationMarker;
    }

    emit(
      state.copyWith(
        pickUpLocation: null,
        destinationLocation: null,
        pickUpDescription: '',
        destinationDescription: '',
        placemarkData: null,

        routePoints: const <LocationEntity>[],
        polylines: const <PolylineId, Polyline>{},
        routeStatus: MapaRouteStatus.initial,
        routeErrorMessage: null,

        geocodingStatus: MapaGeocodingStatus.initial,
        geocodingErrorMessage: null,

        markers: persistentMarkers,
        isPickingLocation: false,
      ),
    );
  }

  // ======================================================
  // HELPERS: GOOGLE MAPS
  // ======================================================

  Future<void> _animateCamera({
    required LocationEntity location,
    double zoom = 17,
  }) async {
    final controller = _mapController;

    if (controller == null) return;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitud, location.longitud),
            zoom: zoom,
            bearing: 0,
          ),
        ),
      );
    } catch (_) {
      // El controlador puede dejar de estar disponible cuando se
      // destruye la vista. No interrumpimos el flujo del BLoC.
    }
  }

  Future<void> _fitCameraToRoute(List<LatLng> points) async {
    final controller = _mapController;

    if (controller == null || points.isEmpty) return;

    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 17),
      );

      return;
    }

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLatitude) {
        minLatitude = point.latitude;
      }

      if (point.latitude > maxLatitude) {
        maxLatitude = point.latitude;
      }

      if (point.longitude < minLongitude) {
        minLongitude = point.longitude;
      }

      if (point.longitude > maxLongitude) {
        maxLongitude = point.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );

    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (_) {
      // Puede fallar si GoogleMap todavía no terminó su layout.
    }
  }

  // ======================================================
  // HELPERS: MARCADORES
  // ======================================================

  Marker _createCurrentLocationMarker(LocationEntity location) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(location.latitud, location.longitud),
      infoWindow: const InfoWindow(title: 'Mi ubicación actual'),
    );
  }

  String _trackingMarkerDescription(LocationEntity location) {
    final values = <String>[];

    if (location.velocidad != null) {
      final speedKmh = location.velocidad! * 3.6;

      values.add('${speedKmh.toStringAsFixed(1)} km/h');
    }

    if (location.precision != null) {
      values.add('Precisión ${location.precision!.toStringAsFixed(1)} m');
    }

    if (values.isEmpty) {
      return 'Seguimiento activo';
    }

    return values.join(' · ');
  }

  // ======================================================
  // HELPERS: GEOCODIFICACIÓN
  // ======================================================

  Future<dynamic> _getPlacemarkSafely(LocationEntity location) async {
    try {
      return await geocodingUsesCases.getPlacemarkFromLocation.run(location);
    } catch (_) {
      return null;
    }
  }

  // ======================================================
  // HELPERS: PERMISOS
  // ======================================================

  bool _isPermissionGranted(LocationPermissionStatus permission) {
    return permission == LocationPermissionStatus.whileInUse ||
        permission == LocationPermissionStatus.always;
  }

  String _permissionMessage(LocationPermissionStatus permission) {
    switch (permission) {
      case LocationPermissionStatus.denied:
        return 'El permiso de ubicación fue denegado.';

      case LocationPermissionStatus.deniedForever:
        return 'El permiso de ubicación fue denegado permanentemente. '
            'Debes habilitarlo desde la configuración de la aplicación.';

      case LocationPermissionStatus.unableToDetermine:
        return 'No se pudo determinar el estado del permiso de ubicación.';

      case LocationPermissionStatus.whileInUse:
      case LocationPermissionStatus.always:
        return '';
    }
  }

  // ======================================================
  // HELPERS: ERRORES
  // ======================================================

  String _getErrorMessage(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message.isEmpty ? 'Ocurrió un error inesperado.' : message;
  }

  // ======================================================
  // CERRAR BLOC
  // ======================================================

  @override
  Future<void> close() {
    _mapController?.dispose();
    _mapController = null;

    return super.close();
  }
}
