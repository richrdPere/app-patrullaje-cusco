import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class CheckLocationPermissionUseCase {
  GeolocatorRepository geolocatorRepository;

  CheckLocationPermissionUseCase(this.geolocatorRepository);

  Future<LocationPermissionStatus> run() =>
      geolocatorRepository.checkLocationPermission();
}
