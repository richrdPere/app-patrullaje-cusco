import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class GetHistorialByIdUseCase {
  final HistorialPatrullajeRepository historialRepository;
  GetHistorialByIdUseCase(this.historialRepository);

  run(int patrullajeId) =>
      historialRepository.getHistorialByPatrullaje(patrullajeId);
}
