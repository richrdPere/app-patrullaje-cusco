import 'dart:io';
import 'package:flutter/material.dart';
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
    Duration interval = const Duration(seconds: 5),
  }) async* {
    try {
      await _validateLocationAccess();

      final safeDistanceFilter = distanceFilter < 0 ? 0 : distanceFilter;

      final LocationSettings settings;

      if (Platform.isAndroid) {
        settings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: safeDistanceFilter,
          intervalDuration: interval,
        );
      } else if (Platform.isIOS) {
        settings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: safeDistanceFilter,
          activityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      } else {
        settings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: safeDistanceFilter,
        );
      }

      await for (final position in Geolocator.getPositionStream(
        locationSettings: settings,
      )) {
        final location = _mapPositionToEntity(position, tipo: tipo);

        debugPrint(
          '📍 Geolocator emitió: '
          '${position.latitude}, '
          '${position.longitude} | '
          'precisión: ${position.accuracy} m | '
          'velocidad: ${position.speed} m/s | '
          'fecha: ${position.timestamp}',
        );
        yield location;
      }
    } on LocationServiceDisabledException {
      throw const LocationServiceDisabledFailure();
    } on PermissionDeniedException {
      throw const LocationPermissionDeniedFailure();
    } on LocationServiceDisabledFailure {
      rethrow;
    } on LocationPermissionDeniedFailure {
      rethrow;
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
