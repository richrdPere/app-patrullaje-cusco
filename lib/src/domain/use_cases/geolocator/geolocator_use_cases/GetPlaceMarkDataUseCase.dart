import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class GetPlaceMarkDataUseCase {
  GeolocatorRepository geolocatorRepository;

  GetPlaceMarkDataUseCase(this.geolocatorRepository);

  run(CameraPosition cameraPosition) =>
      geolocatorRepository.getPlacemarkData(cameraPosition);
}
