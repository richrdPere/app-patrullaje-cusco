import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/incidente_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class IncidenteRepositoryImpl extends IncidenteRepository {
  final IncidenteService incidenteService;

  IncidenteRepositoryImpl(this.incidenteService);

  @override
  Future<IncidenteModel> crearIncidencia(IncidenteModel params) async {
    final response = await incidenteService.newIncidente(params);

    if (response == null) {
      throw Exception("No se pudo crear la incidencia");
    }

    return response;
  }
}
