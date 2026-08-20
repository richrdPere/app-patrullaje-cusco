import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisIncidenciasUseCase {
  final IncidenteRepository incidenteRepository;

  GetMisIncidenciasUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<MisIncidenciasPaginated>>> run({
    required MisIncidenciasQueryParams params,
  }) {
    return incidenteRepository.getMisIncidencias(params: params);
  }
}
