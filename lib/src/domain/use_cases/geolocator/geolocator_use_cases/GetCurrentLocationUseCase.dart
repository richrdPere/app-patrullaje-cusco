import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class GetCurrentLocationUseCase {
  GeolocatorRepository geolocatorRepository;
  GetCurrentLocationUseCase(this.geolocatorRepository);

  Future<LocationEntity> run({String tipo = 'MANUAL'}) =>
      geolocatorRepository.getCurrentLocation(tipo: tipo);
}
