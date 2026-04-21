import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

abstract class IncidenteEvent {}

class CrearIncidenteEvent extends IncidenteEvent {
  final IncidenteModel params;

  CrearIncidenteEvent(this.params);

  List<Object?> get props => [params];
}
