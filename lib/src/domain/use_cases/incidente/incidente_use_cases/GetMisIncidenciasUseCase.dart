import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetMisIncidenciasUseCase {
  final IncidenteRepository incidenteRepository;

  GetMisIncidenciasUseCase(this.incidenteRepository);

  run({int page = 1, int limit = 10, String incluirArchivos = 'false'}) {
    return incidenteRepository.getMisIncidencias(
      page: page,
      limit: limit,
      incluirArchivos: incluirArchivos,
    );
  }
}
