import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapaEvent extends Equatable {
  const MapaEvent();

  @override
  List<Object?> get props => [];
}

// ======================================================
// 1. INICIALIZACIÓN DEL MAPA
// ======================================================

/// Inicializa el mapa.
///
/// Este evento puede encargarse de:
/// - Verificar si el GPS está habilitado.
/// - Verificar o solicitar permisos.
/// - Obtener la última ubicación conocida.
/// - Obtener la ubicación actual.
/// - Preparar los elementos iniciales del mapa.
class MapaInitEvent extends MapaEvent {
  const MapaInitEvent();
}

// ======================================================
// 2. UBICACIÓN ACTUAL
// ======================================================

/// Solicita la ubicación actual del dispositivo.
///
/// A diferencia del stream de tracking, esta operación obtiene
/// una ubicación puntual.
class FindCurrentPositionEvent extends MapaEvent {
  /// Tipo de ubicación que se asignará a [LocationEntity].
  ///
  /// Ejemplos:
  /// - MANUAL
  /// - EMERGENCIA
  /// - TRACKING
  final String tipo;

  const FindCurrentPositionEvent({this.tipo = 'MANUAL'});

  @override
  List<Object?> get props => [tipo];
}

/// Indica que el usuario desea utilizar su ubicación actual.
///
/// Puede emplearse para:
/// - Seleccionar la ubicación de una incidencia.
/// - Colocar un punto de origen.
/// - Centrar el mapa.
/// - Completar automáticamente latitud y longitud.
class UseCurrentLocationEvent extends MapaEvent {
  final String tipo;

  const UseCurrentLocationEvent({this.tipo = 'MANUAL'});

  @override
  List<Object?> get props => [tipo];
}

/// Centra la cámara del mapa en una ubicación determinada.
///
/// Este evento no modifica la ubicación del dispositivo.
/// Únicamente solicita que el mapa se desplace visualmente.
class CenterMapOnLocationEvent extends MapaEvent {
  final LocationEntity location;

  /// Zoom que debe utilizar la cámara.
  final double zoom;

  const CenterMapOnLocationEvent({required this.location, this.zoom = 17});

  @override
  List<Object?> get props => [location, zoom];
}

// ======================================================
// 3. MOVIMIENTO DE LA CÁMARA
// ======================================================

/// Notifica que la cámara del mapa se está desplazando.
///
/// Se utilizan valores primitivos para evitar que el evento dependa
/// directamente de [CameraPosition] de Google Maps.
class MapCameraMovedEvent extends MapaEvent {
  final double latitud;
  final double longitud;
  final double zoom;

  const MapCameraMovedEvent({
    required this.latitud,
    required this.longitud,
    required this.zoom,
  });

  @override
  List<Object?> get props => [latitud, longitud, zoom];
}

/// Notifica que la cámara terminó de moverse.
///
/// Puede utilizarse para:
/// - Ejecutar geocodificación inversa.
/// - Actualizar la dirección seleccionada.
/// - Confirmar el punto central del mapa.
class MapCameraIdleEvent extends MapaEvent {
  const MapCameraIdleEvent();
}

// ======================================================
// 4. SELECCIÓN MANUAL DE UBICACIÓN
// ======================================================

/// Activa o desactiva el modo de selección manual.
///
/// Cuando está activo, el usuario puede mover el mapa para elegir
/// una ubicación mediante el punto central de la cámara.
class TogglePickingLocationEvent extends MapaEvent {
  const TogglePickingLocationEvent();
}

/// Establece explícitamente si el modo de selección manual está activo.
///
/// Es más útil que un simple toggle cuando la vista necesita establecer
/// un valor conocido y evitar inconsistencias.
class SetPickingLocationEvent extends MapaEvent {
  final bool enabled;

  const SetPickingLocationEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Confirma la ubicación que actualmente se encuentra seleccionada
/// en el centro del mapa.
class ConfirmPickedLocationEvent extends MapaEvent {
  const ConfirmPickedLocationEvent();
}

// ======================================================
// 5. AUTOCENTRADO
// ======================================================

/// Activa o desactiva el seguimiento automático de la cámara.
///
/// Cuando está habilitado, el mapa puede centrarse automáticamente
/// en cada nueva ubicación emitida por TrackingBloc.
class ToggleAutoCenterEvent extends MapaEvent {
  const ToggleAutoCenterEvent();
}

/// Establece explícitamente el estado del autocentrado.
class SetAutoCenterEvent extends MapaEvent {
  final bool enabled;

  const SetAutoCenterEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

// ======================================================
// 6. PUNTO DE ORIGEN
// ======================================================

/// Registra el punto de origen seleccionado mediante autocompletado.
///
/// El punto de origen puede ser:
/// - La ubicación actual del sereno.
/// - Una dirección buscada.
/// - Un punto seleccionado manualmente.
class PickUpLocationSelectedEvent extends MapaEvent {
  final LocationEntity location;
  final String description;

  const PickUpLocationSelectedEvent({
    required this.location,
    required this.description,
  });

  @override
  List<Object?> get props => [location, description];
}

// ======================================================
// 7. PUNTO DE DESTINO
// ======================================================

/// Registra el punto de destino seleccionado mediante autocompletado.
///
/// Después de establecer este punto se puede solicitar el cálculo
/// de la ruta mediante [DrawRouteEvent].
class DestinationLocationSelectedEvent extends MapaEvent {
  final LocationEntity location;
  final String description;

  const DestinationLocationSelectedEvent({
    required this.location,
    required this.description,
  });

  @override
  List<Object?> get props => [location, description];
}

/// Elimina el punto de origen y el punto de destino seleccionados.
class ClearSelectedLocationsEvent extends MapaEvent {
  const ClearSelectedLocationsEvent();
}

// ======================================================
// 8. ZONA ASIGNADA
// ======================================================

/// Dibuja en el mapa la zona asignada al patrullaje.
///
/// Las coordenadas pertenecen al polígono definido en el backend.
class DrawAssignedZoneEvent extends MapaEvent {
  final List<Coordenada> coordenadas;

  const DrawAssignedZoneEvent({required this.coordenadas});

  @override
  List<Object?> get props => [coordenadas];
}

/// Elimina del mapa el polígono de la zona asignada.
class ClearAssignedZoneEvent extends MapaEvent {
  const ClearAssignedZoneEvent();
}

// ======================================================
// 9. CÁLCULO Y DIBUJO DE RUTA
// ======================================================

/// Solicita calcular una ruta entre un origen y un destino.
///
/// El bloc utilizará [DirectionsUsesCase] para obtener una lista
/// de [LocationEntity] con los puntos de la ruta.
class DrawRouteEvent extends MapaEvent {
  final LocationEntity origin;
  final LocationEntity destination;

  const DrawRouteEvent({required this.origin, required this.destination});

  @override
  List<Object?> get props => [origin, destination];
}

/// Elimina del estado los puntos de la ruta actualmente dibujada.
class ClearRouteEvent extends MapaEvent {
  const ClearRouteEvent();
}

// ======================================================
// 10. TRACKING DEL SERENO
// ======================================================

/// Actualiza en el mapa la última ubicación recibida del sereno.
///
/// Este evento normalmente será enviado desde:
/// - TrackingBloc.
/// - HomePage.
/// - Un BlocListener.
/// - Un stream de ubicación.
///
/// No vuelve a consultar el GPS. Solo recibe una ubicación ya obtenida.
class UpdateTrackingLocationEvent extends MapaEvent {
  final LocationEntity location;

  const UpdateTrackingLocationEvent({required this.location});

  @override
  List<Object?> get props => [location];
}

// ======================================================
// 11. DIRECCIÓN MEDIANTE GEOCODIFICACIÓN
// ======================================================

/// Solicita obtener una dirección descriptiva para una ubicación.
///
/// Utiliza [GeocodingUsesCases] y puede ejecutarse después de:
/// - Mover la cámara.
/// - Elegir una ubicación.
/// - Obtener la ubicación actual.
class GetAddressFromLocationEvent extends MapaEvent {
  final LocationEntity location;

  const GetAddressFromLocationEvent({required this.location});

  @override
  List<Object?> get props => [location];
}

// ======================================================
// 12. LIMPIEZA DEL MAPA
// ======================================================

/// Limpia los elementos temporales del mapa.
///
/// Puede eliminar:
/// - Ruta.
/// - Origen.
/// - Destino.
/// - Ubicación seleccionada.
/// - Dirección seleccionada.
///
/// No necesariamente elimina la zona asignada ni la ubicación del sereno.
class ClearTemporaryMapDataEvent extends MapaEvent {
  const ClearTemporaryMapDataEvent();
}

/// Registra el controlador creado por el widget GoogleMap.
///
/// El controlador se almacena internamente en MapaBloc y no forma
/// parte del estado porque es un objeto mutable de presentación.
class MapControllerCreatedEvent extends MapaEvent {
  final GoogleMapController controller;

  const MapControllerCreatedEvent({required this.controller});

  @override
  List<Object?> get props => [controller];
}
