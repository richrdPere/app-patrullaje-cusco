import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class GetHistorialByPatrullajeUseCase {
  final HistorialPatrullajeRepository historialRepository;

  GetHistorialByPatrullajeUseCase(this.historialRepository);

  run(int patrullajeId) =>
      historialRepository.getHistorialByPatrullaje(patrullajeId);
}
