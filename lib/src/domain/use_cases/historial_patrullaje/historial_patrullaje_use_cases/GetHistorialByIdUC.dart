import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetHistorialByIdUC {
  final HistorialPatrullajeRepository historialRepository;
  GetHistorialByIdUC(this.historialRepository);

  Future<Resource<ApiResponse<HistorialDetalleData>>> run({
    required int historialId,
  }) => historialRepository.getHistorialById(historialId: historialId);
}
