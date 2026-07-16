// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';
// import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

abstract class GeolocatorRepository {
  /// 1. Verifica si el GPS o servicio de ubicación está encendido.
  Future<bool> isLocationServiceEnabled();

  /// 2. Obtiene el estado actual del permiso de ubicación.
  Future<LocationPermissionStatus> checkLocationPermission();

  /// 3. Solicita el permiso de ubicación al usuario.
  Future<LocationPermissionStatus> requestLocationPermission();

  /// 4. Abre la configuración de ubicación del dispositivo.
  Future<bool> openLocationSettings();

  /// 5. Abre la configuración de la aplicación.
  Future<bool> openAppSettings();

  /// 6. Obtiene la ubicación actual del dispositivo.
  Future<LocationEntity> getCurrentLocation({String tipo = 'MANUAL'});

  /// 7. Obtiene la última ubicación conocida, si existe.
  Future<LocationEntity?> getLastKnownLocation({String tipo = 'MANUAL'});

  /// 8. Emite las ubicaciones del dispositivo durante el seguimiento.
  Stream<LocationEntity> getLocationStream({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 5),
  });
}

// abstract class GeolocatorRepository {
//   Future<Position> findPosition();
//   Future<BitmapDescriptor> createMarkerFromAsset(String path);
//   Marker getMarker(
//     String markerId,
//     double lat,
//     double lng,
//     String title,
//     String content,
//     BitmapDescriptor imageMarker,
//   );

//   Future<PlacemarkData?> getPlacemarkData(CameraPosition cameraPosition);
//   Future<List<LatLng>> getPolyline(
//     LatLng pickUpLatLng,
//     LatLng destinationLatLng,
//   );

//   Stream<LocationEntity> getLocationStream();
// }
