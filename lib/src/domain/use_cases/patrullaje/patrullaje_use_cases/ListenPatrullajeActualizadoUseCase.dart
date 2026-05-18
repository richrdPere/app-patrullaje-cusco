import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class ListenPatrullajeActualizadoUseCase {
  PatrullajeRepository patrullajeRepository;

  ListenPatrullajeActualizadoUseCase(this.patrullajeRepository);

  run() => patrullajeRepository.listenPatrullajeActualizado();
}
