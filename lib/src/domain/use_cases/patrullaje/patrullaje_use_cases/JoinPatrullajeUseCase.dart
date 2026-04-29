import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
class JoinPatrullajeUseCase {
  PatrullajeRepository patrullajeRepository;
  JoinPatrullajeUseCase(this.patrullajeRepository);
  
 run(int patrullajeId) => patrullajeRepository.joinPatrullaje(patrullajeId);
}