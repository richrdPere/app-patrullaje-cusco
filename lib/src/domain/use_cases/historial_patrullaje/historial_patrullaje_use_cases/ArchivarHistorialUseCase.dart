import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class ArchivarHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;

  ArchivarHistorialUseCase(this.historialRepository);

  run(int historialId) => historialRepository.archivedHistorial(historialId);
}
