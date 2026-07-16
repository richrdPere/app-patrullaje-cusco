import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

abstract class GeocodingRepository {
  /// Obtiene información descriptiva de una dirección mediante coordenadas.
  Future<PlacemarkData?> getPlacemarkFromLocation(LocationEntity location);
}
