import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';

class MapaBloc extends Bloc<MapaEvent, MapaState> {
  GeolocatorUseCases geolocatorUseCases;
  bool _isLoadingAddress = false;

  MapaBloc(this.geolocatorUseCases) : super(MapaState()) {
    on<MapaInitEvent>((event, emit) {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();

      emit(state.copyWith(controller: controller));
    });

    on<FindPosition>((event, emit) async {
      try {
        Position position = await geolocatorUseCases.findPosition.run();

        final latLng = LatLng(position.latitude, position.longitude);

        // Obtener dirección real
        final placemarkData = await geolocatorUseCases.getPlaceMarkData.run(
          CameraPosition(target: latLng, zoom: 15),
        );

        // Mover cámara
        add(
          ChangeMapCameraPosition(
            lat: position.latitude,
            lng: position.longitude,
          ),
        );

        // BitmapDescriptor imageMarker = await geolocatorUseCases.createMarker.run(
        //   'assets/img/location_blue.png',
        // );

        // Marker marker = await geolocatorUseCases.getMarker.run(
        //   'MyLocation',
        //   position.latitude,
        //   position.longitude,
        //   'Mi Posicion',
        //   '',
        //   imageMarker,
        // );

        emit(
          state.copyWith(
            position: position,

            // ORIGEN INICIAL
            // markers: {marker.markerId: marker},
            pickUpLatLng: LatLng(position.latitude, position.longitude),
            pickUpDescription: placemarkData.address,
            placemarkData: placemarkData,

            // DESTINO LIMPIO
            destinationLatLng: null,
            destinationDescription: '',

            // IMPORTANTE
            isPickingLocation: false,
          ),
        );

        print('Position LAT ${position.latitude}');
        print('Position lng ${position.longitude}');
        
      } catch (e) {
        print("ERROR INIT POSITION: $e");

        // fallback mínimo
        emit(
          state.copyWith(
            pickUpDescription: 'Mi ubicación actual',
            destinationDescription: '',
            isPickingLocation: false,
          ),
        );
      }
    });

    on<ChangeMapCameraPosition>((event, emit) async {
      GoogleMapController googleMapController = await state.controller!.future;
      await googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(event.lat, event.lng),
            zoom: 15,
            bearing: 0,
          ),
        ),
      );
    });

    on<OnCameraMove>((event, emit) async {
      emit(state.copyWith(cameraPosition: event.cameraPosition));
    });

    on<OnCameraIdle>((event, emit) async {
      // NO actualizar si no está en modo selección
      if (!state.isPickingLocation) return;

      if (_isLoadingAddress) return;

      // Evitar llamadas innecesarias
      if (state.cameraPosition.zoom < 15) return;

      _isLoadingAddress = true;

      try {
        PlacemarkData placemarkData = await geolocatorUseCases.getPlaceMarkData
            .run(state.cameraPosition);

        final destinationLatLng = LatLng(placemarkData.lat, placemarkData.lng);

        emit(
          state.copyWith(
            placemarkData: placemarkData,
            // pickUpLatLng: LatLng(placemarkData.lat, placemarkData.lng),
            // pickUpDescription: placemarkData.address,

            // AHORA SE GUARDA COMO DESTINO
            destinationLatLng: destinationLatLng,
            destinationDescription: placemarkData.address,
          ),
        );

        // DIBUJAR RUTA AUTOMÁTICAMENTE
        add(DrawRouteEvent());
      } catch (e) {
        print('ERROR GEOCODING: $e');

        emit(
          state.copyWith(
            pickUpLatLng: state.cameraPosition.target,
            pickUpDescription: 'Ubicación seleccionada',
          ),
        );
      }

      _isLoadingAddress = false;
    });

    on<OnAutoCompletePickUpSelected>((event, emit) {
      emit(
        state.copyWith(
          pickUpLatLng: LatLng(event.lat, event.lng),
          pickUpDescription: event.pickUpDescription,

          // Vuelve a activar selección manual
          isPickingLocation: true,
        ),
      );
    });

    on<OnAutoCompleteDestinationSelected>((event, emit) {
      emit(
        state.copyWith(
          destinationLatLng: LatLng(event.lat, event.lng),
          destinationDescription: event.destinationDescription,

          // BLOQUEA actualización por cámara
          isPickingLocation: false,
        ),
      );

      // DISPARA LA RUTA
      add(DrawRouteEvent());
    });

    on<DrawZonaEvent>((event, emit) {
      final List<LatLng> points = event.coordenadas.map((coord) {
        return LatLng(coord.lat, coord.lng);
      }).toList();

      final polygon = Polygon(
        polygonId: const PolygonId("zona"),
        points: points,
        strokeWidth: 3,
        strokeColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
      );

      emit(state.copyWith(polygons: {polygon}));
    });

    on<DrawRouteEvent>((event, emit) async {
      if (state.pickUpLatLng == null || state.destinationLatLng == null) return;

      try {
        final polylineCoordinates = await geolocatorUseCases.getPolyline.run(
          state.pickUpLatLng!,
          state.destinationLatLng!,
        );

        final id = const PolylineId("route");

        final polyline = Polyline(
          polylineId: id,
          color: Colors.blueAccent,
          width: 6,
          points: polylineCoordinates,
        );

        emit(
          state.copyWith(
            polylines: {id: polyline}, // Reemplaza la anterior
          ),
        );
      } catch (e) {
        print("ERROR DRAW ROUTE: $e");
      }
    });

    on<UseCurrentLocationEvent>((event, emit) async {
      final position = await geolocatorUseCases.findPosition.run();

      final latLng = LatLng(position.latitude, position.longitude);

      // Obtener dirección real
      final placemarkData = await geolocatorUseCases.getPlaceMarkData.run(
        CameraPosition(target: latLng, zoom: 15),
      );

      emit(
        state.copyWith(
          position: position,
          pickUpLatLng: latLng,
          pickUpDescription: placemarkData.address, // Dirección real
          placemarkData: placemarkData,
          isPickingLocation: false,
          destinationDescription: '',
          polylines: {},
        ),
      );

      add(ChangeMapCameraPosition(lat: latLng.latitude, lng: latLng.longitude));
    });

    on<TogglePickingLocationEvent>((event, emit) {
      emit(state.copyWith(isPickingLocation: !state.isPickingLocation));
    });

    on<ToggleAutoCenterEvent>((event, emit) {
      emit(state.copyWith(isAutoCentering: !state.isAutoCentering));
    });
  }
}
