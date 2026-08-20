import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasByZonaUseCase {
  final IncidenteRepository repository;

  const GetIncidenciasByZonaUseCase(this.repository);

  Future<Resource<ApiResponse<IncidenciasZonaPaginated>>> run({
    required int zonaId,
    required IncidenciasZonaQueryParams params,
  }) {
    return repository.getIncidenciasByZona(zonaId: zonaId, params: params);
  }
}
