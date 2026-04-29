import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class LeavePatrullajeUseCase {
  PatrullajeRepository patrullajeRepository;
  LeavePatrullajeUseCase(this.patrullajeRepository);

  run(int patrullajeId) => patrullajeRepository.leavePatrullaje(patrullajeId);
}
