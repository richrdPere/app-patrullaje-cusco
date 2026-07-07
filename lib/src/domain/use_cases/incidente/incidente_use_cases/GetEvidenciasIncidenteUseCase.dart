import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetEvidenciasIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  GetEvidenciasIncidenteUseCase(this.incidenteRepository);

  Future<List<IncidenciaArchivoModel>> run(int incidenciaId) {
    return incidenteRepository.getEvidencias(incidenciaId);
  }
}
