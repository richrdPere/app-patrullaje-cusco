import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class UpdateHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;

  UpdateHistorialUseCase(this.historialRepository);

  run(HistorialPatrullajeModel historial) =>
      historialRepository.editarHistorial(historial);
}
