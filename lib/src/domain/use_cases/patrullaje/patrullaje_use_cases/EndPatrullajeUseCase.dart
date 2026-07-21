import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class EndPatrullajeUseCase {
  PatrullajeRepository patrullajeRepository;
  EndPatrullajeUseCase(this.patrullajeRepository);

  run({required int patrullajeId, String? observacionFinal}) =>
      patrullajeRepository.endPatrullaje(
        patrullajeId: patrullajeId,
        observacionFinal: observacionFinal,
      );
}
