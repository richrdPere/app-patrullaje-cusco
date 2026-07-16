import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class IsLocationServiceEnableUseCase {
  GeolocatorRepository geolocatorRepository;

  IsLocationServiceEnableUseCase(this.geolocatorRepository);

  Future<bool> run() => geolocatorRepository.isLocationServiceEnabled();
}
