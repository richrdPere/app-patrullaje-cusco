import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class SendLocationUseCase {
  PatrullajeRepository patrullajeRepository;
  SendLocationUseCase(this.patrullajeRepository);

  run(LocationEntity location) => patrullajeRepository.sendLocation(location);
}
