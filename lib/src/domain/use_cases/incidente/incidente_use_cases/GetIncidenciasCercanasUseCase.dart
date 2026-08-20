import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasCercanasUseCase {
  final IncidenteRepository incidenteRepository;

  GetIncidenciasCercanasUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<IncidenciasCercanasData>>> run({
    required IncidenciasCercanasQueryParams params,
  }) {
    return incidenteRepository.getIncidenciasCercanas(params: params);
  }
}
