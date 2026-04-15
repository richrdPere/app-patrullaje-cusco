import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class StartPatrullajeUseCase {
  PatrullajeRepository patrullajeRepository;
  StartPatrullajeUseCase(this.patrullajeRepository);
  
  run(int patrullajeId) => patrullajeRepository.startPatrullaje(patrullajeId);
}
