import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetArchivoIncidenciaUseCase {
  final IncidenteRepository incidenteRepository;

  GetArchivoIncidenciaUseCase(this.incidenteRepository);

  run(int incidenciaId) {
    return incidenteRepository.getArchivosIncidencia(incidenciaId);
  }
}
