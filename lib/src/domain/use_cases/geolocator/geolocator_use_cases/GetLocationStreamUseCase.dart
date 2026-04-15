import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class GetLocationStreamUseCase {
  GeolocatorRepository geolocatorRepository;

  GetLocationStreamUseCase(this.geolocatorRepository);

  run() => geolocatorRepository.getLocationStream();
}
