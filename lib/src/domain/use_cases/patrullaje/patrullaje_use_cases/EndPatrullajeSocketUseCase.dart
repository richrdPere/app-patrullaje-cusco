import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class EndPatrullajeSocketUseCase {
  PatrullajeRepository patrullajeRepository;
  EndPatrullajeSocketUseCase(this.patrullajeRepository);

  run(int patrullajeId) =>
      patrullajeRepository.finalizarPatrullajeSocket(patrullajeId);
}
