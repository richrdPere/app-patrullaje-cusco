import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class GetLocationUseCase {
  TrackingRepository trackingRepository;
  GetLocationUseCase(this.trackingRepository);

  run() => trackingRepository.getLocationStream();
}

