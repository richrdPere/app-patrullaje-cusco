import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

abstract class IncidenteEvent {
  const IncidenteEvent();
}

// GENERAL
class ResetIncidenteEvent extends IncidenteEvent {
  const ResetIncidenteEvent();
}

class LimpiarErrorEvent extends IncidenteEvent {
  const LimpiarErrorEvent();
}

// INCIDENTE
class CrearIncidenteEvent extends IncidenteEvent {
  final IncidenteModel params;

  const CrearIncidenteEvent(this.params);
}

class ReporteRapidoEvent extends IncidenteEvent {
  final IncidenteRapidoEnum tipo;

  const ReporteRapidoEvent(this.tipo);
}

// MEDIA
class TomarFotoEvent extends IncidenteEvent {
  const TomarFotoEvent();
}

class SeleccionarImagenEvent extends IncidenteEvent {
  const SeleccionarImagenEvent();
}

class IniciarGrabacionVideoEvent extends IncidenteEvent {
  const IniciarGrabacionVideoEvent();
}

class DetenerGrabacionVideoEvent extends IncidenteEvent {
  const DetenerGrabacionVideoEvent();
}

class IniciarGrabacionAudioEvent extends IncidenteEvent {
  const IniciarGrabacionAudioEvent();
}

class DetenerGrabacionAudioEvent extends IncidenteEvent {
  const DetenerGrabacionAudioEvent();
}

class EliminarArchivoEvent extends IncidenteEvent {
  final int index;

  const EliminarArchivoEvent(this.index);
}

class LimpiarArchivosEvent extends IncidenteEvent {
  const LimpiarArchivosEvent();
}

class SeleccionarVideoEvent extends IncidenteEvent {
  const SeleccionarVideoEvent();
}

// LOCATION
class ObtenerUbicacionEvent extends IncidenteEvent {
  const ObtenerUbicacionEvent();
}

// UI
class CambiarTabEvent extends IncidenteEvent {
  final IncidenteTabEnum tab;

  const CambiarTabEvent(this.tab);
}

class ExpandirSheetEvent extends IncidenteEvent {
  const ExpandirSheetEvent();
}

class ContraerSheetEvent extends IncidenteEvent {
  const ContraerSheetEvent();
}

// CONTEXTUAL
class ObtenerIncidentesCercanosEvent extends IncidenteEvent {
  const ObtenerIncidentesCercanosEvent();
}
