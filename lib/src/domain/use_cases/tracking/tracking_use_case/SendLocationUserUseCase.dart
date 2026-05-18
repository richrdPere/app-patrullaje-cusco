import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class SendLocationUserUseCase {
  TrackingRepository trackingRepository;

  SendLocationUserUseCase(this.trackingRepository);

  run(LocationEntity location, int patrullajeId) =>
      trackingRepository.sendLocation(location, patrullajeId);
}
