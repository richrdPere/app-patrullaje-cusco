// import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:injectable/injectable.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/exceptions/directions_exception.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/directions_repository.dart';

// @LazySingleton(as: DirectionsRepository)
class DirectionsRepositoryImpl implements DirectionsRepository {
  final PolylinePoints _polylinePoints;

  DirectionsRepositoryImpl({
    @Named('googleMapsApiKey') required String googleMapsApiKey,
  }) : _polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);

  @override
  Future<List<LocationEntity>> getRoute({
    required LocationEntity origin,
    required LocationEntity destination,
  }) async {
    _validateLocation(origin, locationName: 'origen');

    _validateLocation(destination, locationName: 'destino');

    if (_isSameLocation(origin, destination)) {
      return [origin.copyWith(tipo: 'ROUTE')];
    }

    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitud, origin.longitud),
          destination: PointLatLng(destination.latitud, destination.longitud),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) {
        final errorMessage = result.errorMessage?.trim();

        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw DirectionsApiFailure(
            'No se pudo calcular la ruta: $errorMessage',
          );
        }

        throw const RouteNotFoundFailure();
      }

      final fechaCalculo = DateTime.now();

      return result.points
          .map((point) {
            return LocationEntity(
              latitud: point.latitude,
              longitud: point.longitude,
              fechaHora: fechaCalculo,
              tipo: 'ROUTE',
            );
          })
          .toList(growable: false);
    } on DirectionsException {
      rethrow;
    } catch (error) {
      throw DirectionsApiFailure(
        'Ocurrió un error al consultar la ruta: $error',
      );
    }
  }

  // ======================================================
  // VALIDACIONES
  // ======================================================

  void _validateLocation(
    LocationEntity location, {
    required String locationName,
  }) {
    if (location.latitud.isNaN ||
        location.latitud.isInfinite ||
        location.latitud < -90 ||
        location.latitud > 90) {
      throw InvalidRouteCoordinatesFailure(
        'La latitud de la ubicación de $locationName no es válida.',
      );
    }

    if (location.longitud.isNaN ||
        location.longitud.isInfinite ||
        location.longitud < -180 ||
        location.longitud > 180) {
      throw InvalidRouteCoordinatesFailure(
        'La longitud de la ubicación de $locationName no es válida.',
      );
    }
  }

  bool _isSameLocation(LocationEntity origin, LocationEntity destination) {
    const tolerance = 0.000001;

    final latitudeDifference = (origin.latitud - destination.latitud).abs();

    final longitudeDifference = (origin.longitud - destination.longitud).abs();

    return latitudeDifference <= tolerance && longitudeDifference <= tolerance;
  }
}
