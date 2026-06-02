import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/map_templates/google_places_auto_complete.dart';

class MapaContent extends StatelessWidget {
  final MapaState state;

  final TextEditingController pickUpController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  MapaContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // SINCRONIZA DIRECTO (simple y efectivo)
    if (pickUpController.text != state.pickUpDescription) {
      pickUpController.text = state.pickUpDescription;
    }

    if (destinationController.text != state.destinationDescription) {
      destinationController.text = state.destinationDescription;
    }

    return Stack(
      children: [
        _googleMaps(context),

        // AUTOCOMPLETE
        if (!state.isPickingLocation) _searchContainer(context),

        // Container(
        //   height: 120,
        //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
        //   child: _googlePlacesAutocomplete(context),
        // ),

        // MARKER CENTRAL SOLO EN SELECCIÓN
        if (state.isPickingLocation) _iconMyLocation(), //_centerMarker(),
        // MENSAJE
        if (state.isPickingLocation) _selectionInfo(),

        // BOTONES
        // _iconMyLocation(),
        _useCurrentLocationButton(context),
        // _currentLocationButton(context),

        // _selectZoneButton(context),
        if (state.isPickingLocation) _confirmLocationButton(context),

        _togglePickingButton(context),

        if (!state.isPickingLocation) _alertButton(context),
      ],
    );
  }

  // =========================
  // GOOGLE MAP
  // =========================
  Widget _googleMaps(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, trackingState) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: state.cameraPosition,

          onMapCreated: (controller) {
            if (!state.controller!.isCompleted) {
              state.controller?.complete(controller);
            }
          },

          // MARKERS
          markers: Set<Marker>.of(state.markers.values),

          // AGREGAR POLÍGONOS
          polygons: state.polygons,

          // POLYLINES
          polylines: Set<Polyline>.of(state.polylines.values),

          // CAMERA
          onCameraMove: (cameraPosition) {
            context.read<MapaBloc>().add(
              OnCameraMove(cameraPosition: cameraPosition),
            );
          },

          onCameraIdle: () {
            context.read<MapaBloc>().add(OnCameraIdle());
          },

          // CONTROLES UI
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // Position defauld
          zoomControlsEnabled: false, // Quita botones + -
          // compassEnabled: true,           // puedes dejarlo

          // GESTOS
          rotateGesturesEnabled: false, // evita rotación accidental
          tiltGesturesEnabled: false, // No necesitas inclinación
          compassEnabled: false,
        );
      },
    );
  }

  // =========================
  // SEARCH CONTAINER
  // =========================
  Widget _searchContainer(BuildContext context) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              GooglePlaceAutoComplete(pickUpController, 'Mi ubicación', (
                prediction,
              ) {
                if (prediction != null) {
                  FocusScope.of(context).unfocus();

                  context.read<MapaBloc>().add(
                    ChangeMapCameraPosition(
                      lat: double.parse(prediction.lat!),
                      lng: double.parse(prediction.lng!),
                    ),
                  );

                  context.read<MapaBloc>().add(
                    OnAutoCompletePickUpSelected(
                      lat: double.parse(prediction.lat!),
                      lng: double.parse(prediction.lng!),
                      pickUpDescription: prediction.description ?? '',
                    ),
                  );
                }
              }),

              const Divider(),

              GooglePlaceAutoComplete(
                destinationController,
                'Buscar zona o destino',
                (prediction) {
                  if (prediction != null) {
                    FocusScope.of(context).unfocus();

                    context.read<MapaBloc>().add(
                      OnAutoCompleteDestinationSelected(
                        lat: double.parse(prediction.lat!),
                        lng: double.parse(prediction.lng!),
                        destinationDescription: prediction.description ?? '',
                      ),
                    );

                    context.read<MapaBloc>().add(
                      ChangeMapCameraPosition(
                        lat: double.parse(prediction.lat!),
                        lng: double.parse(prediction.lng!),
                      ),
                    );

                    // DIBUJAR RUTA SOLO AQUÍ
                    context.read<MapaBloc>().add(DrawRouteEvent());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // MARKER CENTRAL
  // =========================
  // Widget _centerMarker() {
  //   return IgnorePointer(
  //     child: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Icon(Icons.location_pin, size: 55, color: Colors.red),

  //           Container(
  //             width: 10,
  //             height: 10,
  //             decoration: const BoxDecoration(
  //               color: Colors.red,
  //               shape: BoxShape.circle,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // =========================
  // MENSAJE SELECCIÓN
  // =========================
  Widget _selectionInfo() {
    return Positioned(
      top: 180,
      left: 40,
      right: 40,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Mueve el mapa para seleccionar la zona de patrullaje',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  // =========================
  // UBICACIÓN ACTUAL
  // =========================
  // Widget _currentLocationButton(BuildContext context) {
  //   return Positioned(
  //     bottom: 190,
  //     right: 20,
  //     child: FloatingActionButton(
  //       heroTag: "btnLocation",
  //       backgroundColor: Colors.white,
  //       elevation: 6,
  //       onPressed: () {
  //         context.read<MapaBloc>().add(UseCurrentLocationEvent());
  //       },
  //       child: const Icon(Icons.my_location, color: Colors.blue),
  //     ),
  //   );
  // }

  // =========================
  // SELECCIONAR ZONA
  // =========================
  // Widget _selectZoneButton(BuildContext context) {
  //   return Positioned(
  //     bottom: 120,
  //     left: 20,
  //     right: 20,
  //     child: SizedBox(
  //       height: 55,
  //       child: ElevatedButton.icon(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.blue,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //         ),
  //         onPressed: () {
  //           context.read<MapaBloc>().add(TogglePickingLocationEvent());
  //         },
  //         icon: const Icon(Icons.map, color: Colors.white),
  //         label: Text(
  //           state.isPickingLocation
  //               ? 'Modo selección activado'
  //               : 'Seleccionar zona de patrullaje',
  //           style: const TextStyle(color: Colors.white, fontSize: 15),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // =========================
  // CONFIRMAR DESTINO
  // =========================
  Widget _confirmLocationButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 55,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            context.read<MapaBloc>().add(DrawRouteEvent());

            context.read<MapaBloc>().add(TogglePickingLocationEvent());
          },
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text(
            'Confirmar destino',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // =========================
  // ALERT BUTTON
  // =========================
  Widget _alertButton(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: "btnAlert",
          backgroundColor: Colors.red,
          elevation: 8,
          onPressed: () {
            final mapaState = context.read<MapaBloc>().state;

            final position = mapaState.position;

            if (position == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No hay ubicación disponible")),
              );
              return;
            }

            context.read<AlertBloc>().add(
              SendAlertEvent(lat: position.latitude, lng: position.longitude),
            );
          },

          child: const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _iconMyLocation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.center,
      child: Image.asset('assets/img/location_blue.png', width: 45, height: 45),
    );
  }

  // Widget _googlePlacesAutocomplete(BuildContext context) {
  //   return Card(
  //     color: Colors.white,
  //     elevation: 5,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     child: Column(
  //       children: [
  //         GooglePlaceAutoComplete(pickUpController, 'Posición actual', (
  //           prediction,
  //         ) {
  //           if (prediction != null) {
  //             // CERRAR TECLADO
  //             FocusScope.of(context).unfocus();

  //             context.read<MapaBloc>().add(
  //               ChangeMapCameraPosition(
  //                 lat: double.parse(prediction.lat!),
  //                 lng: double.parse(prediction.lng!),
  //               ),
  //             );

  //             context.read<MapaBloc>().add(
  //               OnAutoCompletePickUpSelected(
  //                 lat: double.parse(prediction.lat!),
  //                 lng: double.parse(prediction.lng!),
  //                 pickUpDescription: prediction.description ?? '',
  //               ),
  //             );
  //           }
  //         }),

  //         const Divider(),

  //         GooglePlaceAutoComplete(destinationController, 'Ir a', (prediction) {
  //           if (prediction != null) {
  //             // CERRAR TECLADO
  //             FocusScope.of(context).unfocus();

  //             context.read<MapaBloc>().add(
  //               OnAutoCompleteDestinationSelected(
  //                 lat: double.parse(prediction.lat!),
  //                 lng: double.parse(prediction.lng!),
  //                 destinationDescription: prediction.description ?? '',
  //               ),
  //             );
  //           }
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // Usar ubicacion actual
  Widget _useCurrentLocationButton(BuildContext context) {
    return Positioned(
      bottom: 180,
      right: 20,
      child: FloatingActionButton(
        heroTag: "btnLocation",
        backgroundColor: Colors.white,
        onPressed: () {
          context.read<MapaBloc>().add(UseCurrentLocationEvent());
          // context.read<MapaBloc>().add(TogglePickingLocationEvent());
        },
        child: const Icon(Icons.my_location, color: Colors.blue),
      ),
    );
  }

  // Modo fijar punto en mapa
  Widget _togglePickingButton(BuildContext context) {
    return BlocBuilder<MapaBloc, MapaState>(
      builder: (context, state) {
        return Positioned(
          bottom: 110,
          right: 20,
          child: FloatingActionButton(
            heroTag: "btnPick",
            backgroundColor: state.isPickingLocation
                ? Colors.orange
                : Colors.white,
            onPressed: () {
              context.read<MapaBloc>().add(TogglePickingLocationEvent());
            },
            child: Icon(
              Icons.place,
              color: state.isPickingLocation ? Colors.white : Colors.black,
            ),
          ),
        );
      },
    );
  }
}
