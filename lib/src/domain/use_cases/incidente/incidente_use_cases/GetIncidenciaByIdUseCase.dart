import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciaByIdUseCase {
  final IncidenteRepository incidenteRepository;

  GetIncidenciaByIdUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<IncidenciaDetalleData>>> run({
    required int incidenciaId,
  }) => incidenteRepository.getIncidenciaById(incidenciaId: incidenciaId);
}
