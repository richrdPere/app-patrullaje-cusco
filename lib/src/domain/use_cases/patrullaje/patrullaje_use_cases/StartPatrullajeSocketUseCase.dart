import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class StartPatrullajeSocketUseCase {
  PatrullajeRepository patrullajeRepository;
  StartPatrullajeSocketUseCase(this.patrullajeRepository);

  run(int patrullajeId) =>
      patrullajeRepository.iniciarPatrullajeSocket(patrullajeId);
}
