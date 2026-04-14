import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_state.dart';

class MapaIncidentBloc extends Bloc<MapaIncidentEvent, MapaIncidentState> {
  GeolocatorUseCases geolocatorUseCases;

  MapaIncidentBloc(this.geolocatorUseCases) : super(MapaIncidentState()) {
    on<MapaIncidentInitEvent>((event, emit) async {
      Completer<GoogleMapController> controller =
          Completer<GoogleMapController>();

      emit(
        state.copyWith(
          controller: controller,
          pickUpLatLng: event.pickUpLatLng,
          destinationLatLng: event.destinationLatLng,
          pickUpDescription: event.pickUpDescription,
          destinationDescription: event.destinationDescription,
        ),
      );

      BitmapDescriptor pickUpDescriptor = await geolocatorUseCases.createMarker
          .run('assets/img/pin_white.png');

      BitmapDescriptor destinationDescriptor = await geolocatorUseCases
          .createMarker
          .run('assets/img/flag.png');

      Marker markerPickUp = await geolocatorUseCases.getMarker.run(
        'pickup',
        state.pickUpLatLng!.latitude,
        state.pickUpLatLng!.longitude,
        'Lugar Actual',
        'Debe moverse acorde a sus funciones asignadas',
        pickUpDescriptor,
      );

      Marker markerDestination = await geolocatorUseCases.getMarker.run(
        'destination',
        state.destinationLatLng!.latitude,
        state.destinationLatLng!.longitude,
        'Lugar del Incidente',
        'Debe acudir al lugar inmediatamente',
        destinationDescriptor,
      );

      emit(
        state.copyWith(
          markers: {
            markerPickUp.markerId: markerPickUp,
            markerDestination.markerId: markerDestination,
          },
        ),
      );
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

    on<AddPolyline>((event, emit) async {
      List<LatLng> polylineCoordinates = await geolocatorUseCases.getPolyline
          .run(state.pickUpLatLng!, state.destinationLatLng!);

      PolylineId id = const PolylineId("MyRoute");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blueAccent,
        points: polylineCoordinates,
        width: 6,
      );
      emit(state.copyWith(polylines: {id: polyline}));
    });
  }
}
