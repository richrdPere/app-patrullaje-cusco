import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasCercanasUseCase {
  final IncidenteRepository incidenteRepository;

  GetIncidenciasCercanasUseCase(this.incidenteRepository);

  Future<Resource<List<IncidenteModel>>> run({
    required double latitud,
    required double longitud,
    double radio = 3,
  }) {
    return incidenteRepository.getIncidenciasCercanas(
      latitud: latitud,
      longitud: longitud,
      radio: radio,
    );
  }
}
