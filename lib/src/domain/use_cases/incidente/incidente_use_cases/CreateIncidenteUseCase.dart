import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class CreateIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  CreateIncidenteUseCase(this.incidenteRepository);

  run(IncidenteModel params) => incidenteRepository.crearIncidencia(params);
}
