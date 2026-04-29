import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class ListenPatrullajeEndUseCase {
  PatrullajeRepository patrullajeRepository;
  ListenPatrullajeEndUseCase(this.patrullajeRepository);
  
 run() => patrullajeRepository.listenPatrullajeFinalizado();
}