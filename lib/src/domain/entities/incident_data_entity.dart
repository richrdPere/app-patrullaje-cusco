import 'package:google_maps_flutter/google_maps_flutter.dart';

class IncidentData {
  final LatLng? pickUpLatLng;
  final String pickUpDescription;
  final LatLng? destinationLatLng;
  final String destinationDescription;

  IncidentData({
    required this.pickUpLatLng,
    required this.pickUpDescription,
    required this.destinationLatLng,
    required this.destinationDescription,
  });
}