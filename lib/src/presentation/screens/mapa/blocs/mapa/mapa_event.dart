import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaEvent {}

class MapaInitEvent extends MapaEvent {}

class FindPosition extends MapaEvent {}

class ChangeMapCameraPosition extends MapaEvent {
  final double lat;
  final double lng;

  ChangeMapCameraPosition({required this.lat, required this.lng});
}

class OnCameraMove extends MapaEvent {
  CameraPosition cameraPosition;

  OnCameraMove({required this.cameraPosition});
}

class OnCameraIdle extends MapaEvent {}

class OnAutoCompletePickUpSelected extends MapaEvent {
  double lat;
  double lng;
  String pickUpDescription;

  OnAutoCompletePickUpSelected({
    required this.lat,
    required this.lng,
    required this.pickUpDescription,
  });
}

class OnAutoCompleteDestinationSelected extends MapaEvent {
  double lat;
  double lng;
  String destinationDescription;

  OnAutoCompleteDestinationSelected({
    required this.lat,
    required this.lng,
    required this.destinationDescription,
  });
}
