import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapaIncidentEvent {}

class MapaIncidentInitEvent extends MapaIncidentEvent {
  final LatLng pickUpLatLng;
  final LatLng destinationLatLng;
  final String pickUpDescription;
  final String destinationDescription;

  MapaIncidentInitEvent({
    required this.pickUpLatLng,
    required this.destinationLatLng,
    required this.pickUpDescription,
    required this.destinationDescription,
  });
}

class ChangeMapCameraPosition extends MapaIncidentEvent {
  final double lat;
  final double lng;

  ChangeMapCameraPosition({required this.lat, required this.lng});
}

class AddPolyline extends MapaIncidentEvent {}
