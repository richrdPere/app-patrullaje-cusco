import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_event.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/map_templates/google_places_auto_complete.dart';

class MapaContent extends StatefulWidget {
  final MapaState state;

  const MapaContent({super.key, required this.state});

  @override
  State<MapaContent> createState() => _MapaContentState();
}

class _MapaContentState extends State<MapaContent> {
  late final TextEditingController _pickUpController;
  late final TextEditingController _destinationController;

  MapaState get state => widget.state;

  // ======================================================
  // CICLO DE VIDA
  // ======================================================

  @override
  void initState() {
    super.initState();

    _pickUpController = TextEditingController(text: state.pickUpDescription);

    _destinationController = TextEditingController(
      text: state.destinationDescription,
    );
  }

  @override
  void didUpdateWidget(covariant MapaContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.pickUpDescription != state.pickUpDescription) {
      _updateControllerText(
        controller: _pickUpController,
        value: state.pickUpDescription,
      );
    }

    if (oldWidget.state.destinationDescription !=
        state.destinationDescription) {
      _updateControllerText(
        controller: _destinationController,
        value: state.destinationDescription,
      );
    }
  }

  @override
  void dispose() {
    _pickUpController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGoogleMap(context),

        if (!state.isPickingLocation) _buildSearchContainer(context),

        if (state.isPickingLocation) const _CenterLocationMarker(),

        if (state.isPickingLocation) const _SelectionInformation(),

        _buildCurrentLocationButton(context),
        _buildPickingModeButton(context),
        _buildAutoCenterButton(context),

        if (state.isPickingLocation) _buildConfirmLocationButton(context),

        if (!state.isPickingLocation) _buildAlertButton(context),

        if (_isLoading) const _MapaLoadingOverlay(),
      ],
    );
  }

  // ======================================================
  // GOOGLE MAP
  // ======================================================

  Widget _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: state.cameraPosition,

      // ==================================================
      // CONTROLADOR
      // ==================================================
      onMapCreated: (controller) {
        context.read<MapaBloc>().add(
          MapControllerCreatedEvent(controller: controller),
        );
      },

      // ==================================================
      // ELEMENTOS GEOGRÁFICOS
      // ==================================================
      markers: state.markers.values.toSet(),
      polygons: state.polygons,
      polylines: state.polylines.values.toSet(),

      // ==================================================
      // MOVIMIENTO DE CÁMARA
      // ==================================================
      onCameraMove: (cameraPosition) {
        context.read<MapaBloc>().add(
          MapCameraMovedEvent(
            latitud: cameraPosition.target.latitude,
            longitud: cameraPosition.target.longitude,
            zoom: cameraPosition.zoom,
          ),
        );
      },

      onCameraIdle: () {
        context.read<MapaBloc>().add(const MapCameraIdleEvent());
      },

      // ==================================================
      // UBICACIÓN DEL DISPOSITIVO
      // ==================================================
      myLocationEnabled: state.canAccessLocation,
      myLocationButtonEnabled: false,

      // ==================================================
      // CONTROLES Y GESTOS
      // ==================================================
      zoomControlsEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  // ======================================================
  // BUSCADOR DE ORIGEN Y DESTINO
  // ======================================================

  Widget _buildSearchContainer(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Card(
          elevation: 8,
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GooglePlaceAutoComplete(_pickUpController, 'Mi ubicación', (
                  prediction,
                ) {
                  _onPickUpPredictionSelected(context, prediction);
                }),

                const Divider(height: 18),

                GooglePlaceAutoComplete(
                  _destinationController,
                  'Buscar zona o destino',
                  (prediction) {
                    _onDestinationPredictionSelected(context, prediction);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // SELECCIONAR ORIGEN DESDE AUTOCOMPLETE
  // ======================================================

  void _onPickUpPredictionSelected(BuildContext context, dynamic prediction) {
    if (prediction == null) return;

    final latitude = double.tryParse(prediction.lat?.toString() ?? '');

    final longitude = double.tryParse(prediction.lng?.toString() ?? '');

    if (latitude == null || longitude == null) {
      _showInvalidPredictionMessage(context);
      return;
    }

    FocusScope.of(context).unfocus();

    final location = LocationEntity(
      latitud: latitude,
      longitud: longitude,
      fechaHora: DateTime.now(),
      tipo: 'MANUAL',
    );

    context.read<MapaBloc>().add(
      PickUpLocationSelectedEvent(
        location: location,
        description:
            prediction.description?.toString() ?? 'Origen seleccionado',
      ),
    );
  }

  // ======================================================
  // SELECCIONAR DESTINO DESDE AUTOCOMPLETE
  // ======================================================

  void _onDestinationPredictionSelected(
    BuildContext context,
    dynamic prediction,
  ) {
    if (prediction == null) return;

    final latitude = double.tryParse(prediction.lat?.toString() ?? '');

    final longitude = double.tryParse(prediction.lng?.toString() ?? '');

    if (latitude == null || longitude == null) {
      _showInvalidPredictionMessage(context);
      return;
    }

    FocusScope.of(context).unfocus();

    final location = LocationEntity(
      latitud: latitude,
      longitud: longitude,
      fechaHora: DateTime.now(),
      tipo: 'MANUAL',
    );

    context.read<MapaBloc>().add(
      DestinationLocationSelectedEvent(
        location: location,
        description:
            prediction.description?.toString() ?? 'Destino seleccionado',
      ),
    );

    context.read<MapaBloc>().add(
      CenterMapOnLocationEvent(location: location, zoom: 17),
    );
  }

  // ======================================================
  // BOTÓN: USAR UBICACIÓN ACTUAL
  // ======================================================

  Widget _buildCurrentLocationButton(BuildContext context) {
    return Positioned(
      bottom: state.isPickingLocation ? 190 : 170,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'btnCurrentLocation',
        tooltip: 'Usar mi ubicación actual',
        backgroundColor: Colors.white,
        elevation: 6,
        onPressed: state.locationStatus == MapaLocationStatus.loading
            ? null
            : () {
                context.read<MapaBloc>().add(
                  const UseCurrentLocationEvent(tipo: 'MANUAL'),
                );
              },
        child: state.locationStatus == MapaLocationStatus.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.my_location, color: Colors.blue),
      ),
    );
  }

  // ======================================================
  // BOTÓN: MODO SELECCIÓN
  // ======================================================

  Widget _buildPickingModeButton(BuildContext context) {
    return Positioned(
      bottom: state.isPickingLocation ? 120 : 100,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'btnPickingLocation',
        tooltip: state.isPickingLocation
            ? 'Salir del modo selección'
            : 'Seleccionar punto en el mapa',
        backgroundColor: state.isPickingLocation ? Colors.orange : Colors.white,
        elevation: 6,
        onPressed: () {
          context.read<MapaBloc>().add(const TogglePickingLocationEvent());
        },
        child: Icon(
          Icons.place,
          color: state.isPickingLocation ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // ======================================================
  // BOTÓN: AUTOCENTRADO
  // ======================================================

  Widget _buildAutoCenterButton(BuildContext context) {
    return Positioned(
      bottom: state.isPickingLocation ? 260 : 240,
      right: 20,
      child: FloatingActionButton.small(
        heroTag: 'btnAutoCenter',
        tooltip: state.isAutoCentering
            ? 'Desactivar seguimiento de cámara'
            : 'Activar seguimiento de cámara',
        backgroundColor: state.isAutoCentering ? Colors.blue : Colors.white,
        elevation: 5,
        onPressed: () {
          context.read<MapaBloc>().add(const ToggleAutoCenterEvent());
        },
        child: Icon(
          state.isAutoCentering ? Icons.gps_fixed : Icons.gps_not_fixed,
          color: state.isAutoCentering ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // ======================================================
  // BOTÓN: CONFIRMAR UBICACIÓN SELECCIONADA
  // ======================================================

  Widget _buildConfirmLocationButton(BuildContext context) {
    final selectedLocation = state.cameraTargetLocation;

    return Positioned(
      bottom: 42,
      left: 20,
      right: 20,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: selectedLocation == null
                ? null
                : () {
                    _confirmSelectedLocation(context, selectedLocation);
                  },
            icon: state.geocodingStatus == MapaGeocodingStatus.loading
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Confirmar destino',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSelectedLocation(
    BuildContext context,
    LocationEntity selectedLocation,
  ) {
    final mapaBloc = context.read<MapaBloc>();

    mapaBloc.add(GetAddressFromLocationEvent(location: selectedLocation));

    mapaBloc.add(const SetPickingLocationEvent(enabled: false));

    final origin = state.pickUpLocation;

    if (origin != null) {
      mapaBloc.add(
        DrawRouteEvent(origin: origin, destination: selectedLocation),
      );
    }
  }

  // ======================================================
  // BOTÓN: ENVIAR ALERTA
  // ======================================================

  Widget _buildAlertButton(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: 62,
          height: 62,
          child: FloatingActionButton(
            heroTag: 'btnAlert',
            tooltip: 'Enviar alerta',
            backgroundColor: Colors.red,
            elevation: 8,
            onPressed: () {
              _sendAlert(context);
            },
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }

  void _sendAlert(BuildContext context) {
    /*
     * Se prioriza la ubicación de tracking porque es la más reciente
     * durante un patrullaje activo. Si no existe, se utiliza la
     * ubicación puntual actual.
     */
    final location = state.displayedLocation;

    if (location == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No hay una ubicación disponible para enviar la alerta.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.read<MapaBloc>().add(
        const FindCurrentPositionEvent(tipo: 'EMERGENCIA'),
      );

      return;
    }

    context.read<AlertBloc>().add(
      SendAlertEvent(lat: location.latitud, lng: location.longitud),
    );
  }

  // ======================================================
  // ESTADO DE CARGA
  // ======================================================

  bool get _isLoading {
    return state.status == MapaStatus.loading ||
        state.routeStatus == MapaRouteStatus.loading;
  }

  // ======================================================
  // HELPERS
  // ======================================================

  void _updateControllerText({
    required TextEditingController controller,
    required String value,
  }) {
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _showInvalidPredictionMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron obtener las coordenadas del lugar seleccionado.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ======================================================
// MARCADOR CENTRAL
// ======================================================

class _CenterLocationMarker extends StatelessWidget {
  const _CenterLocationMarker();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -22),
          child: Image.asset(
            'assets/img/location_blue.png',
            width: 45,
            height: 45,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.location_pin,
                size: 52,
                color: Colors.blue,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ======================================================
// INFORMACIÓN DE SELECCIÓN
// ======================================================

class _SelectionInformation extends StatelessWidget {
  const _SelectionInformation();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 24,
      left: 34,
      right: 34,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 5,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.touch_app, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mueve el mapa para seleccionar un destino.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// OVERLAY DE CARGA
// ======================================================

class _MapaLoadingOverlay extends StatelessWidget {
  const _MapaLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black12,
          child: Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.7),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'Procesando mapa...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
