import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class GetLocationUseCase {
  final TrackingRepository trackingRepository;
  GetLocationUseCase(this.trackingRepository);

  Stream<LocationEntity> run({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 5),
  }) => trackingRepository.getLocationStream(
    tipo: tipo,
    distanceFilter: distanceFilter,
    interval: interval,
  );
}
