import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/placemarkData.dart';

import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class GetPlacemarkFromLocationUseCase {
  GeocodingRepository geocodingRepository;

  GetPlacemarkFromLocationUseCase(this.geocodingRepository);

  Future<PlacemarkData?> run(LocationEntity location) =>
      geocodingRepository.getPlacemarkFromLocation(location);
}
