import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class UpdateHistorialUC {
  final HistorialPatrullajeRepository historialRepository;
  UpdateHistorialUC(this.historialRepository);

  Future<Resource<ApiResponse<HistorialData>>> run({
    required int historialId,
    required CreateHistorialRequest request,
  }) => historialRepository.updateHistorial(
    historialId: historialId,
    request: request,
  );
}
