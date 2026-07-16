import 'package:geolocator/geolocator.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';
import 'package:sis_patrullaje_cusco/src/domain/exceptions/location_exception.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';


class GeolocatorRepositoryImpl implements GeolocatorRepository {
  
  // ======================================================
  // 1. SERVICIO DE UBICACIÓN
  // ======================================================
  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (error) {
      throw Exception(
        'No se pudo verificar si el servicio de ubicación está activo: $error',
      );
    }
  }

  // ======================================================
  // 2. PERMISOS
  // ======================================================
  @override
  Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      return _mapPermissionStatus(permission);
    } catch (_) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      return _mapPermissionStatus(permission);
    } catch (_) {
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  // ======================================================
  // 3. CONFIGURACIÓN
  // ======================================================
  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  // ======================================================
  // 4. UBICACIÓN ACTUAL
  // ======================================================
  @override
  Future<LocationEntity> getCurrentLocation({String tipo = 'MANUAL'}) async {
    await _validateLocationAccess();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return _mapPositionToEntity(position, tipo: tipo);
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } on PermissionDeniedException {
      throw const LocationPermissionDeniedFailure();
    } catch (error) {
      throw LocationUnknownFailure(
        'No se pudo obtener la ubicación actual: $error',
      );
    }
  }

  // ======================================================
  // 5. ÚLTIMA UBICACIÓN CONOCIDA
  // ======================================================
  @override
  Future<LocationEntity?> getLastKnownLocation({String tipo = 'MANUAL'}) async {
    try {
      final permission = await checkLocationPermission();

      if (!permission.isGranted) {
        return null;
      }

      final position = await Geolocator.getLastKnownPosition();

      if (position == null) {
        return null;
      }

      return _mapPositionToEntity(position, tipo: tipo);
    } catch (_) {
      return null;
    }
  }

  // ======================================================
  // 6. STREAM DE UBICACIÓN
  // ======================================================
  @override
  Stream<LocationEntity> getLocationStream({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
  }) async* {
    await _validateLocationAccess();

    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter < 0 ? 0 : distanceFilter,
    );

    try {
      await for (final position in Geolocator.getPositionStream(
        locationSettings: settings,
      )) {
        yield _mapPositionToEntity(position, tipo: tipo);
      }
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } on PermissionDeniedException {
      throw const LocationPermissionDeniedFailure();
    } catch (error) {
      throw LocationUnknownFailure(
        'Ocurrió un error durante el seguimiento de ubicación: $error',
      );
    }
  }

  // ======================================================
  // 7. VALIDACIÓN DE ACCESO
  // ======================================================
  Future<void> _validateLocationAccess() async {
    final serviceEnabled = await isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledFailure();
    }

    var permission = await checkLocationPermission();

    if (permission == LocationPermissionStatus.denied) {
      permission = await requestLocationPermission();
    }

    switch (permission) {
      case LocationPermissionStatus.whileInUse:
      case LocationPermissionStatus.always:
        return;

      case LocationPermissionStatus.denied:
        throw const LocationPermissionDeniedFailure();

      case LocationPermissionStatus.deniedForever:
        throw const LocationPermissionDeniedForeverFailure();

      case LocationPermissionStatus.unableToDetermine:
        throw const LocationPermissionUnableToDetermineFailure();
    }
  }

  // ======================================================
  // 8. MAPPERS
  // ======================================================
  LocationEntity _mapPositionToEntity(
    Position position, {
    required String tipo,
  }) {
    return LocationEntity(
      latitud: position.latitude,
      longitud: position.longitude,
      velocidad: _normalizeSpeed(position.speed),
      precision: _normalizeAccuracy(position.accuracy),
      fechaHora: position.timestamp,
      tipo: tipo,
    );
  }

  LocationPermissionStatus _mapPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;

      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;

      case LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;

      case LocationPermission.always:
        return LocationPermissionStatus.always;

      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unableToDetermine;
    }
  }

  double? _normalizeSpeed(double speed) {
    if (speed.isNaN || speed.isInfinite || speed < 0) {
      return null;
    }

    return speed;
  }

  double? _normalizeAccuracy(double accuracy) {
    if (accuracy.isNaN || accuracy.isInfinite || accuracy < 0) {
      return null;
    }

    return accuracy;
  }
}

// class GeolocatorRepositoryImpl implements GeolocatorRepository {
//   @override
//   Future<Position> findPosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('La ubicacion no esta activada');
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print('Permiso no otorgado por el usuario');
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       print('Permino no otorgado por el usuario permanentemente');

//       return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.',
//       );
//     }

//     return await Geolocator.getCurrentPosition();
//   }

//   @override
//   Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
//     ImageConfiguration configuration = ImageConfiguration();
//     BitmapDescriptor descriptor = await BitmapDescriptor.fromAssetImage(
//       configuration,
//       path,
//     );

//     return descriptor;
//   }

//   @override
//   Marker getMarker(
//     String markerId,
//     double lat,
//     double lng,
//     String title,
//     String content,
//     BitmapDescriptor imageMarker,
//   ) {
//     MarkerId id = MarkerId(markerId);

//     Marker marker = Marker(
//       markerId: id,
//       icon: imageMarker,
//       position: LatLng(lat, lng),
//       infoWindow: InfoWindow(title: title, snippet: content),
//     );

//     return marker;
//   }

//   @override
//   Future<PlacemarkData?> getPlacemarkData(CameraPosition cameraPosition) async {
//     try {
//       double lat = cameraPosition.target.latitude;
//       double lng = cameraPosition.target.longitude;

//       List<Placemark> placemarkList = await placemarkFromCoordinates(lat, lng);

//       if (placemarkList.isNotEmpty) {
//         String direction = placemarkList[0].thoroughfare!;
//         String street = placemarkList[0].subThoroughfare!;
//         String city = placemarkList[0].locality!;
//         String department = placemarkList[0].administrativeArea!;
//         PlacemarkData placemarkData = PlacemarkData(
//           address: '$direction, $street, $city, $department',
//           lat: lat,
//           lng: lng,
//         );

//         return placemarkData;
//       }
//     } catch (e) {
//       print('ERROR: ${e}');
//       return null;
//     }
//     return null;
//   }

//   @override
//   Future<List<LatLng>> getPolyline(
//     LatLng pickUpLatLng,
//     LatLng destinationLatLng,
//   ) async {
//     final String apiKey = url_backend.Environment.googleMapsAPI;
//     final polylinePoints = PolylinePoints(apiKey: apiKey);

//     try {
//       final result = await polylinePoints.getRouteBetweenCoordinates(
//         // googleApiKey: apiKey,
//         request: PolylineRequest(
//           origin: PointLatLng(pickUpLatLng.latitude, pickUpLatLng.longitude),
//           destination: PointLatLng(
//             destinationLatLng.latitude,
//             destinationLatLng.longitude,
//           ),
//           mode: TravelMode.driving,
//         ),
//       );

//       if (result.points.isEmpty) {
//         return [];
//       }

//       return result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();
//     } catch (e) {
//       print('ERROR POLYLINE: $e');
//       return [];
//     }
//   }

//   @override
//   Stream<LocationEntity> getLocationStream() async* {
//     // 1. Verificar permisos
//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Permisos de ubicación denegados permanentemente');
//     }

//     // 2. Configuración del stream
//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high, // precisión alta
//       distanceFilter: 5, // metros (envía cada 5m de movimiento)
//     );

//     // 3. Stream del GPS
//     Stream<Position> positionStream = Geolocator.getPositionStream(
//       locationSettings: locationSettings,
//     );

//     // 4. Convertir Position → LocationEntity
//     await for (final position in positionStream) {
//       yield LocationEntity(
//         latitud: position.latitude,
//         longitud: position.longitude,
//         velocidad: position.speed,
//         precision: position.accuracy,
//         tipo: 'TRACKING',
//         fechaHora: position.timestamp,
//       );
//     }
//   }
// }
