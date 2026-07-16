import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class OpenLocationSettingsUseCase {
  GeolocatorRepository geolocatorRepository;
  OpenLocationSettingsUseCase(this.geolocatorRepository);

  Future<bool> run() => geolocatorRepository.openLocationSettings();
}
