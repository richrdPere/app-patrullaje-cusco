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
      Position position = await geolocatorUseCases.findPosition.run();

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
          // markers: {marker.markerId: marker},
        ),
      );

      print('Position LAT ${position.latitude}');
      print('Position lng ${position.longitude}');
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
      if (_isLoadingAddress) return;

      // 🔥 evitar llamadas innecesarias
      if (state.cameraPosition.zoom < 15) return;

      _isLoadingAddress = true;

      try {
        PlacemarkData placemarkData = await geolocatorUseCases.getPlaceMarkData
            .run(state.cameraPosition);

        emit(
          state.copyWith(
            placemarkData: placemarkData,
            pickUpLatLng: LatLng(placemarkData.lat, placemarkData.lng),
            pickUpDescription: placemarkData.address,
          ),
        );
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
        ),
      );
    });

    on<OnAutoCompleteDestinationSelected>((event, emit) {
      emit(
        state.copyWith(
          destinationLatLng: LatLng(event.lat, event.lng),
          destinationDescription: event.destinationDescription,
        ),
      );
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
  }
}
