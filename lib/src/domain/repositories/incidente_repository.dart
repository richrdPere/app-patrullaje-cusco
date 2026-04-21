import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

abstract class IncidenteRepository {
  Future<IncidenteModel> crearIncidencia(IncidenteModel incidente);
}
