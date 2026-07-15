import 'package:sis_patrullaje_cusco/src/data/models/incidencia/register_incidencia_req.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class CreateIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  CreateIncidenteUseCase(this.incidenteRepository);

  run(RegisterIncidenciaRequest params) =>
      incidenteRepository.newIncidencia(params);
}
