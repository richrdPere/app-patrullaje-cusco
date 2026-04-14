import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';

class GetPolylineUseCase {
  GeolocatorRepository geolocatorRepository;

  GetPolylineUseCase(this.geolocatorRepository);

  run(LatLng pickUpLatLng, LatLng destinationLatLng) =>
      geolocatorRepository.getPolyline(pickUpLatLng, destinationLatLng);
}
