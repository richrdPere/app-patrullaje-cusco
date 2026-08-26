import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

abstract class IncidenteEvent extends Equatable {
  const IncidenteEvent();

  @override
  List<Object?> get props => [];
}

// ======================================================
// GENERAL
// ======================================================

/// Restablece todo el estado del módulo de incidencias.
class ResetIncidenteEvent extends IncidenteEvent {
  const ResetIncidenteEvent();
}

/// Limpia únicamente el error o respuesta de acción actual.
class LimpiarErrorIncidenteEvent extends IncidenteEvent {
  const LimpiarErrorIncidenteEvent();
}

/// Limpia la respuesta generada por crear, agregar o eliminar archivos.
class LimpiarAccionIncidenteEvent extends IncidenteEvent {
  const LimpiarAccionIncidenteEvent();
}

// ======================================================
// INCIDENCIAS
// ======================================================

/// Crea una nueva incidencia.
class CrearIncidenteEvent extends IncidenteEvent {
  final RegisterIncidenciaRequest request;

  const CrearIncidenteEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Crea o configura un reporte rápido desde la interfaz.
///
/// Este evento puede utilizarse para completar automáticamente el tipo
/// de incidencia antes de enviar CrearIncidenteEvent.
class ReporteRapidoEvent extends IncidenteEvent {
  final IncidenteRapidoEnum tipo;

  const ReporteRapidoEvent(this.tipo);

  @override
  List<Object?> get props => [tipo];
}

/// Obtiene las incidencias registradas por el usuario autenticado.
class ObtenerMisIncidenciasEvent extends IncidenteEvent {
  final MisIncidenciasQueryParams params;
  final bool refresh;

  const ObtenerMisIncidenciasEvent({
    required this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [params, refresh];
}

/// Solicita la siguiente página del listado de incidencias.
class CargarMasMisIncidenciasEvent extends IncidenteEvent {
  const CargarMasMisIncidenciasEvent();
}

/// Obtiene el detalle de una incidencia por ID.
class ObtenerIncidenciaPorIdEvent extends IncidenteEvent {
  final int incidenciaId;

  const ObtenerIncidenciaPorIdEvent(this.incidenciaId);

  @override
  List<Object?> get props => [incidenciaId];
}

/// Limpia la incidencia seleccionada o su detalle.
class LimpiarIncidenciaSeleccionadaEvent extends IncidenteEvent {
  const LimpiarIncidenciaSeleccionadaEvent();
}

/// Obtiene incidencias cercanas a una ubicación.
class ObtenerIncidentesCercanosEvent extends IncidenteEvent {
  final IncidenciasCercanasQueryParams params;
  final bool refresh;

  const ObtenerIncidentesCercanosEvent({
    required this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [params, refresh];
}

/// Limpia el listado de incidencias cercanas.
class LimpiarIncidentesCercanosEvent extends IncidenteEvent {
  const LimpiarIncidentesCercanosEvent();
}

/// Obtener incidencias contexto
class ObtenerIncidenciasContextoEvent extends IncidenteEvent {
  final int patrullajeId;
  final int zonaId;
  final IncidenciasPatrullajeQueryParams patrullajeParams;
  final IncidenciasZonaQueryParams zonaParams;

  const ObtenerIncidenciasContextoEvent({
    required this.patrullajeId,
    required this.zonaId,
    required this.patrullajeParams,
    required this.zonaParams,
  });

  @override
  List<Object?> get props => [patrullajeId, zonaId];
}

/// Limpia las incidencias asociadas al patrullaje y zona activos.
class LimpiarIncidenciasContextoEvent extends IncidenteEvent {
  const LimpiarIncidenciasContextoEvent();
}

// ======================================================
// INCIDENCIAS POR PATRULLAJE
// ======================================================
/// Obtiene las incidencias relacionadas con un patrullaje.
class ObtenerIncidenciasPatrullajeEvent extends IncidenteEvent {
  final int patrullajeId;
  final IncidenciasPatrullajeQueryParams params;
  final bool refresh;

  const ObtenerIncidenciasPatrullajeEvent({
    required this.patrullajeId,
    required this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [patrullajeId, params, refresh];
}

/// Solicita la siguiente página de incidencias
/// del patrullaje actualmente seleccionado.
class CargarMasIncidenciasPatrullajeEvent extends IncidenteEvent {
  const CargarMasIncidenciasPatrullajeEvent();
}

/// Limpia las incidencias del patrullaje.
class LimpiarIncidenciasPatrullajeEvent extends IncidenteEvent {
  const LimpiarIncidenciasPatrullajeEvent();
}

// ======================================================
// INCIDENCIAS POR ZONA
// ======================================================

/// Obtiene las incidencias relacionadas con una zona.
class ObtenerIncidenciasZonaEvent extends IncidenteEvent {
  final int zonaId;
  final IncidenciasZonaQueryParams params;
  final bool refresh;

  const ObtenerIncidenciasZonaEvent({
    required this.zonaId,
    required this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [zonaId, params, refresh];
}

/// Solicita la siguiente página de incidencias
/// de la zona actualmente seleccionada.
class CargarMasIncidenciasZonaEvent extends IncidenteEvent {
  const CargarMasIncidenciasZonaEvent();
}

/// Limpia las incidencias de la zona.
class LimpiarIncidenciasZonaEvent extends IncidenteEvent {
  const LimpiarIncidenciasZonaEvent();
}

// ======================================================
// ARCHIVOS DE INCIDENCIA
// ======================================================

/// Obtiene los archivos asociados a una incidencia.
class ObtenerArchivosIncidenciaEvent extends IncidenteEvent {
  final int incidenciaId;

  const ObtenerArchivosIncidenciaEvent(this.incidenciaId);

  @override
  List<Object?> get props => [incidenciaId];
}

/// Agrega nuevos archivos a una incidencia existente.
class AgregarArchivosIncidenciaEvent extends IncidenteEvent {
  final int incidenciaId;
  final List<File> archivos;

  const AgregarArchivosIncidenciaEvent({
    required this.incidenciaId,
    required this.archivos,
  });

  @override
  List<Object?> get props => [incidenciaId, archivos];
}

/// Elimina un archivo remoto asociado a una incidencia.
class EliminarArchivoIncidenciaEvent extends IncidenteEvent {
  final int incidenciaId;
  final int archivoId;

  const EliminarArchivoIncidenciaEvent({
    required this.incidenciaId,
    required this.archivoId,
  });

  @override
  List<Object?> get props => [incidenciaId, archivoId];
}

/// Limpia los archivos remotos cargados en el detalle.
class LimpiarArchivosIncidenciaEvent extends IncidenteEvent {
  const LimpiarArchivosIncidenciaEvent();
}

// ======================================================
// ARCHIVOS LOCALES / MEDIA
// ======================================================

/// Abre la cámara para tomar una fotografía.
class TomarFotoEvent extends IncidenteEvent {
  const TomarFotoEvent();
}

/// Abre la galería para seleccionar una imagen.
class SeleccionarImagenEvent extends IncidenteEvent {
  const SeleccionarImagenEvent();
}

/// Abre la galería para seleccionar un video.
class SeleccionarVideoEvent extends IncidenteEvent {
  const SeleccionarVideoEvent();
}

/// Inicia la grabación de video.
class IniciarGrabacionVideoEvent extends IncidenteEvent {
  const IniciarGrabacionVideoEvent();
}

/// Detiene la grabación de video.
class DetenerGrabacionVideoEvent extends IncidenteEvent {
  const DetenerGrabacionVideoEvent();
}

/// Inicia la grabación de audio.
class IniciarGrabacionAudioEvent extends IncidenteEvent {
  const IniciarGrabacionAudioEvent();
}

/// Detiene la grabación de audio.
class DetenerGrabacionAudioEvent extends IncidenteEvent {
  const DetenerGrabacionAudioEvent();
}

/// Elimina un archivo seleccionado localmente.
class EliminarArchivoLocalEvent extends IncidenteEvent {
  final int index;

  const EliminarArchivoLocalEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Limpia todos los archivos seleccionados localmente.
class LimpiarArchivosLocalesEvent extends IncidenteEvent {
  const LimpiarArchivosLocalesEvent();
}

// ======================================================
// UBICACIÓN
// ======================================================

/// Obtiene la ubicación actual del dispositivo.
///
/// Este evento se utiliza para completar el formulario de incidencia.
/// Las incidencias cercanas se consultan después utilizando
/// ObtenerIncidentesCercanosEvent.
class ObtenerUbicacionEvent extends IncidenteEvent {
  const ObtenerUbicacionEvent();
}

// ======================================================
// INTERFAZ
// ======================================================

class CambiarTabIncidenteEvent extends IncidenteEvent {
  final IncidenteTabEnum tab;

  const CambiarTabIncidenteEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class ExpandirSheetIncidenteEvent extends IncidenteEvent {
  const ExpandirSheetIncidenteEvent();
}

class ContraerSheetIncidenteEvent extends IncidenteEvent {
  const ContraerSheetIncidenteEvent();
}

// ======================================================
// SELECTOR DE INCIDENCIAS PARA OCURRENCIA
// ======================================================

/// Obtiene incidencias que pueden asociarse a una ocurrencia.
class ObtenerIncidenciasSeleccionablesEvent extends IncidenteEvent {
  final MisIncidenciasQueryParams params;
  final bool refresh;

  const ObtenerIncidenciasSeleccionablesEvent({
    required this.params,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [params, refresh];
}

/// Carga la siguiente página del selector.
class CargarMasIncidenciasSeleccionablesEvent extends IncidenteEvent {
  const CargarMasIncidenciasSeleccionablesEvent();
}

/// Limpia el listado utilizado por el selector.
class LimpiarIncidenciasSeleccionablesEvent extends IncidenteEvent {
  const LimpiarIncidenciasSeleccionablesEvent();
}
