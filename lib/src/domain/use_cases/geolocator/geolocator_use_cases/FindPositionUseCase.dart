import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class FindPositionUseCase {
  GeolocatorRepository geolocatorRepository;

  FindPositionUseCase(this.geolocatorRepository);

  run() => geolocatorRepository.findPosition();
}
