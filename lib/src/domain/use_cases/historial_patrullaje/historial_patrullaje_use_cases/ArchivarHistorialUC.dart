import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ArchivarHistorialUC {
  final HistorialPatrullajeRepository historialRepository;
  ArchivarHistorialUC(this.historialRepository);

  Future<Resource<ApiResponse<HistorialData>>> run({
    required int historialId,
  }) => historialRepository.archiveHistorial(historialId: historialId);
}
