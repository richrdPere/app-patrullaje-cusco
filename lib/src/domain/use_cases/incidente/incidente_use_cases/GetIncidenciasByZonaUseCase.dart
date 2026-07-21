import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasByZonaUseCase {
  final IncidenteRepository repository;

  const GetIncidenciasByZonaUseCase(this.repository);

  Future<Resource<List<IncidenteModel>>> run({required int zonaId}) {
    return repository.getIncidenciasByZona(zonaId: zonaId);
  }
}
