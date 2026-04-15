import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/bitmap.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

class GeolocatorRepositoryImpl implements GeolocatorRepository {
  @override
  Future<Position> findPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('La ubicacion no esta activada');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permiso no otorgado por el usuario');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permino no otorgado por el usuario permanentemente');

      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(
      configuration,
      path,
    );

    return descriptor;
  }

  @override
  Marker getMarker(
    String markerId,
    double lat,
    double lng,
    String title,
    String content,
    BitmapDescriptor imageMarker,
  ) {
    MarkerId id = MarkerId(markerId);

    Marker marker = Marker(
      markerId: id,
      icon: imageMarker,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: content),
    );

    return marker;
  }

  @override
  Future<PlacemarkData?> getPlacemarkData(CameraPosition cameraPosition) async {
    try {
      double lat = cameraPosition.target.latitude;
      double lng = cameraPosition.target.longitude;

      List<Placemark> placemarkList = await placemarkFromCoordinates(lat, lng);

      if (placemarkList.isNotEmpty) {
        String direction = placemarkList[0].thoroughfare!;
        String street = placemarkList[0].subThoroughfare!;
        String city = placemarkList[0].locality!;
        String department = placemarkList[0].administrativeArea!;
        PlacemarkData placemarkData = PlacemarkData(
          address: '$direction, $street, $city, $department',
          lat: lat,
          lng: lng,
        );

        return placemarkData;
      }
    } catch (e) {
      print('ERROR: ${e}');
      return null;
    }
    return null;
  }

  @override
  Future<List<LatLng>> getPolyline(
    LatLng pickUpLatLng,
    LatLng destinationLatLng,
  ) async {
    final String apiKey = url_backend.Environment.googleMapsAPI;
    final polylinePoints = PolylinePoints(apiKey: apiKey);

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        // googleApiKey: apiKey,
        request: PolylineRequest(
          origin: PointLatLng(pickUpLatLng.latitude, pickUpLatLng.longitude),
          destination: PointLatLng(
            destinationLatLng.latitude,
            destinationLatLng.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) {
        return [];
      }

      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } catch (e) {
      print('ERROR POLYLINE: $e');
      return [];
    }
  }

  @override
  Stream<LocationEntity> getLocationStream() async* {
    // 1. Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente');
    }

    // 2. Configuración del stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // precisión alta
      distanceFilter: 5, // metros (envía cada 5m de movimiento)
    );

    // 3. Stream del GPS
    Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );

    // 4. Convertir Position → LocationEntity
    await for (final position in positionStream) {
      yield LocationEntity(
        latitud: position.latitude,
        longitud: position.longitude,
        velocidad: position.speed,
        precision: position.accuracy,
        tipo: 'TRACKING',
        fechaHora: position.timestamp,
      );
    }
  }
}
