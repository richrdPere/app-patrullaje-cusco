import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class DirectionsRepository {
  /// Obtiene los puntos que conforman una ruta entre dos ubicaciones.
  Future<List<LocationEntity>> getRoute({
    required LocationEntity origin,
    required LocationEntity destination,
  });
}
