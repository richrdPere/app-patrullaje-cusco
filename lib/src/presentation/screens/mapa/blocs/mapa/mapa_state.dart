import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

class MapaState extends Equatable {
  final Completer<GoogleMapController>? controller;
  final Position? position;
  final CameraPosition cameraPosition;
  final PlacemarkData? placemarkData;
  final Map<MarkerId, Marker> markers;
  final LatLng? pickUpLatLng;
  final LatLng? destinationLatLng;
  final String pickUpDescription;
  final String destinationDescription;

  final Set<Polygon> polygons;
  final Map<PolylineId, Polyline> polylines;
  final bool isPickingLocation;
  final bool isAutoCentering;

  const MapaState({
    this.position,
    this.controller,
    this.placemarkData,
    this.cameraPosition = const CameraPosition(
      target: LatLng(-13.5179185199147, -71.97836101065464),
      zoom: 15.0,
    ),
    this.pickUpLatLng,
    this.destinationLatLng,
    this.pickUpDescription = '',
    this.destinationDescription = '',
    this.markers = const <MarkerId, Marker>{},

    this.polygons = const {},
    this.polylines = const {},
    this.isPickingLocation = true,
    this.isAutoCentering = true,
  });

  MapaState copyWith({
    Position? position,
    Completer<GoogleMapController>? controller,
    CameraPosition? cameraPosition,
    PlacemarkData? placemarkData,
    Map<MarkerId, Marker>? markers,
    LatLng? pickUpLatLng,
    LatLng? destinationLatLng,
    String? pickUpDescription,
    String? destinationDescription,
    Set<Polygon>? polygons,
    Map<PolylineId, Polyline>? polylines,
    bool? isPickingLocation,
    bool? isAutoCentering,
  }) {
    return MapaState(
      position: position ?? this.position,
      markers: markers ?? this.markers,
      controller: controller ?? this.controller,
      cameraPosition: cameraPosition ?? this.cameraPosition,
      placemarkData: placemarkData ?? this.placemarkData,
      pickUpLatLng: pickUpLatLng ?? this.pickUpLatLng,
      destinationLatLng: destinationLatLng ?? this.destinationLatLng,
      pickUpDescription: pickUpDescription ?? this.pickUpDescription,
      destinationDescription:
          destinationDescription ?? this.destinationDescription,

      polygons: polygons ?? this.polygons,
      polylines: polylines ?? this.polylines,
      isPickingLocation: isPickingLocation ?? this.isPickingLocation,
      isAutoCentering: isAutoCentering ?? this.isAutoCentering,
    );
  }

  @override
  List<Object?> get props => [
    position,
    markers,
    controller,
    cameraPosition,
    placemarkData,
    pickUpLatLng,
    destinationLatLng,
    pickUpDescription,
    destinationDescription,
    polygons,
    polylines,
    isPickingLocation,
    isAutoCentering,
  ];
}
