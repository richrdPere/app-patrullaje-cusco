import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetIncidenciaUseCase {

  final IncidenteRepository incidenteRepository;

  GetIncidenciaUseCase(
    this.incidenteRepository,
  );

  Future<IncidenteModel> run(
    int incidenciaId,
  ) {
    return incidenteRepository.getIncidencia(
      incidenciaId,
    );
  }
}