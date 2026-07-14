import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ArchivarHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;
  ArchivarHistorialUseCase(this.historialRepository);

  Future<Resource<bool>> run(int historialId) =>
      historialRepository.archivedHistorial(historialId);
}
