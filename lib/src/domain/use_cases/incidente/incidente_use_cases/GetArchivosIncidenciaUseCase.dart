import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetArchivoIncidenciaUseCase {
  final IncidenteRepository incidenteRepository;

  GetArchivoIncidenciaUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<IncidenciaArchivosData>>> run({
    required int incidenciaId,
  }) {
    return incidenteRepository.getArchivosByIncidencia(
      incidenciaId: incidenciaId,
    );
  }
}
