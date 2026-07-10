import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class RemoveArchivoIncidenciaUseCase {
  final IncidenteRepository incidenteRepository;

  RemoveArchivoIncidenciaUseCase(this.incidenteRepository);

  Future<Resource<bool>> run({
    required int incidenciaId,
    required int archivoId,
  }) {
    return incidenteRepository.removeArchivoIncidencia(
      incidenciaId: incidenciaId,
      archivoId: archivoId,
    );
  }
}
