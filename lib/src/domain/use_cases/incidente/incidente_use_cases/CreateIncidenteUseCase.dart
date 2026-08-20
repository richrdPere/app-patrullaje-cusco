import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CreateIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  CreateIncidenteUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<RegisterIncidenciaData>>> run({
    required RegisterIncidenciaRequest incidente,
  }) => incidenteRepository.newIncidencia(incidente: incidente);
}
