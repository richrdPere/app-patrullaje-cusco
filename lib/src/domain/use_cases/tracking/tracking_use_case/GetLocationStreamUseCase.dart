import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class GetLocationStreamUseCase {
  TrackingRepository trackingRepository;
  GetLocationStreamUseCase(this.trackingRepository);

  run() => trackingRepository.getLocationStream();
}

