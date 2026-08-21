import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetParaSiguienteTurnoUC {
  final HistorialPatrullajeRepository historialRepository;
  GetParaSiguienteTurnoUC(this.historialRepository);

  Future<Resource<ApiResponse<SiguienteTurnoData>>> run({
    required SiguienteTurnoQueryParams params,
  }) => historialRepository.getParaSiguienteTurno(params: params);
}
