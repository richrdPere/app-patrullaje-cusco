import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class CreateMarkerUseCase {
  GeolocatorRepository geolocatorRepository;

  CreateMarkerUseCase(this.geolocatorRepository);

  run(String path) => geolocatorRepository.createMarkerFromAsset(path);
}
