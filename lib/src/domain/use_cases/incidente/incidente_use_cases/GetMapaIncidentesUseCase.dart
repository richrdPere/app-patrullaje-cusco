import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetMapaIncidentesUseCase {
  final IncidenteRepository incidenteRepository;

  GetMapaIncidentesUseCase(this.incidenteRepository);

  Future<List<IncidenteModel>> run() {
    return incidenteRepository.getIncidenciasActivasMapa();
  }
}
