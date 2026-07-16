import 'package:geocoding/geocoding.dart';
// import 'package:injectable/injectable.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/exceptions/geocoding_exception.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geocoding_repository.dart';

// @LazySingleton(as: GeocodingRepository)
class GeocodingRepositoryImpl implements GeocodingRepository {
  const GeocodingRepositoryImpl();

  @override
  Future<PlacemarkData?> getPlacemarkFromLocation(
    LocationEntity location,
  ) async {
    _validateCoordinates(location);

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitud,
        location.longitud,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      return _mapPlacemarkToData(
        placemarks.first,
        location,
      );
    } on NoResultFoundException {
      return null;
    } catch (error) {
      throw GeocodingFailure(
        'No se pudo obtener la dirección de la ubicación: $error',
      );
    }
  }

  // ======================================================
  // MAPPER
  // ======================================================

  PlacemarkData _mapPlacemarkToData(
    Placemark placemark,
    LocationEntity location,
  ) {
    return PlacemarkData(
      address: _buildAddress(placemark),
      street: _cleanValue(placemark.street),
      locality: _cleanValue(placemark.locality),
      subLocality: _cleanValue(placemark.subLocality),
      administrativeArea: _cleanValue(placemark.administrativeArea),
      subAdministrativeArea: _cleanValue(
        placemark.subAdministrativeArea,
      ),
      country: _cleanValue(placemark.country),
      postalCode: _cleanValue(placemark.postalCode),
      latitude: location.latitud,
      longitude: location.longitud,
    );
  }

  // ======================================================
  // DIRECCIÓN FORMATEADA
  // ======================================================

  String _buildAddress(Placemark placemark) {
    final parts = <String>[
      _cleanValue(placemark.street),
      _cleanValue(placemark.subLocality),
      _cleanValue(placemark.locality),
      _cleanValue(placemark.administrativeArea),
      _cleanValue(placemark.country),
    ].where((value) => value.isNotEmpty).toList();

    final uniqueParts = <String>[];

    for (final part in parts) {
      if (!uniqueParts.contains(part)) {
        uniqueParts.add(part);
      }
    }

    return uniqueParts.join(', ');
  }

  // ======================================================
  // VALIDACIONES
  // ======================================================

  void _validateCoordinates(LocationEntity location) {
    if (location.latitud.isNaN ||
        location.latitud.isInfinite ||
        location.latitud < -90 ||
        location.latitud > 90) {
      throw const InvalidCoordinatesFailure(
        'La latitud proporcionada no es válida.',
      );
    }

    if (location.longitud.isNaN ||
        location.longitud.isInfinite ||
        location.longitud < -180 ||
        location.longitud > 180) {
      throw const InvalidCoordinatesFailure(
        'La longitud proporcionada no es válida.',
      );
    }
  }

  String _cleanValue(String? value) {
    return value?.trim() ?? '';
  }
}