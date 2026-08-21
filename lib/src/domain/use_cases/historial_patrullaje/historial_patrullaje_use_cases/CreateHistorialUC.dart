import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CreateHistorialUC {
  final HistorialPatrullajeRepository historialRepository;
  CreateHistorialUC(this.historialRepository);

  Future<Resource<ApiResponse<HistorialData>>> run({
    required CreateHistorialRequest request,
  }) => historialRepository.createHistorial(request: request);
}
