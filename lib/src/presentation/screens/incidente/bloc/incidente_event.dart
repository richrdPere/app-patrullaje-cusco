import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

abstract class IncidenteEvent {}

// CREAR INCIDENCIA
class CrearIncidenteEvent extends IncidenteEvent {
  final IncidenteModel params;

  CrearIncidenteEvent(this.params);
}

// MEDIA
class TomarFotoEvent extends IncidenteEvent {}

class GrabarVideoEvent extends IncidenteEvent {}

class SeleccionarImagenEvent extends IncidenteEvent {}

class EliminarArchivoEvent extends IncidenteEvent {
  final int index;

  EliminarArchivoEvent(this.index);
}


// UBICACIÓN
class ObtenerUbicacionEvent extends IncidenteEvent {}