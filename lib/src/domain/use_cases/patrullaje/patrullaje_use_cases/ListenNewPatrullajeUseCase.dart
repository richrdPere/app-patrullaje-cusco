import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class ListenNewPatrullajeUseCase {
  PatrullajeRepository patrullajeRepository;
  ListenNewPatrullajeUseCase(this.patrullajeRepository);
  
  run() => patrullajeRepository.listenNuevoPatrullaje();
}