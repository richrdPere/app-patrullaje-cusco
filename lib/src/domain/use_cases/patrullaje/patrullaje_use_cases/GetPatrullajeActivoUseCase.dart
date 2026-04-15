import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class GetPatrullajeActivoUseCase {
  PatrullajeRepository patrullajeRepository;

  GetPatrullajeActivoUseCase(this.patrullajeRepository);

  run() => patrullajeRepository.getPatrullajeActivo();
}
