import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetIncidenciaByIdUseCase {
  final IncidenteRepository incidenteRepository;

  GetIncidenciaByIdUseCase(this.incidenteRepository);

  run(int incidenciaId) => incidenteRepository.getIncidenciaById(incidenciaId);
}
