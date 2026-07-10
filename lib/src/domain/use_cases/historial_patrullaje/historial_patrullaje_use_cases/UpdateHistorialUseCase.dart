import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class UpdateHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;

  UpdateHistorialUseCase(this.historialRepository);

  run(HistorialPatrullajeModel historial) =>
      historialRepository.updateHistorial(historial);
}
