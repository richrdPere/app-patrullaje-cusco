import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class RemoveEvidenciaIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  RemoveEvidenciaIncidenteUseCase(this.incidenteRepository);

  Future<void> run(int evidenciaId) {
    return incidenteRepository.removeEvidencia(evidenciaId);
  }
}
