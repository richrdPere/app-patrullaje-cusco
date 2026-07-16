import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class OpenAppSettingsUseCase {
  GeolocatorRepository geolocatorRepository;
  OpenAppSettingsUseCase(this.geolocatorRepository);

  Future<bool> run() => geolocatorRepository.openAppSettings();
}
