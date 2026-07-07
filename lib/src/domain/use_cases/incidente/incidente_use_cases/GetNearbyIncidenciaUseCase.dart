import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetNearbyIncidentesUseCase {
  final IncidenteRepository incidenteRepository;

  GetNearbyIncidentesUseCase(this.incidenteRepository);

  Future<List<IncidenteModel>> run({
    required double latitud,
    required double longitud,
    double radioKm = 3,
  }) {
    return incidenteRepository.getIncidenciasCercanas(
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );
  }
}
