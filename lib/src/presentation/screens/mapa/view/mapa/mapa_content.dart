import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_button.dart';
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

        Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: _googlePlacesAutocomplete(context),
        ),

        _iconMyLocation(),

        _alertButton(context),

        _useCurrentLocationButton(context),

        _togglePickingButton(context),

        // _recenterButton(context),

        // Container(
        //   alignment: Alignment.bottomCenter,
        //   child: DefaultButton(
        //     text: 'REVISAR INCIDENTE',
        //     margin: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
        //     onPressed: () {
        //       context.goNamed(
        //         "incident",
        //         extra: IncidentData(
        //           pickUpLatLng: state.pickUpLatLng,
        //           pickUpDescription: state.pickUpDescription,
        //           destinationLatLng: state.destinationLatLng,
        //           destinationDescription: state.destinationDescription,
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

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

          markers: Set<Marker>.of(state.markers.values),

          // AGREGAR POLÍGONOS
          polygons: state.polygons,

          // AGREGAR CAMINO EN MAPA
          polylines: Set<Polyline>.of(state.polylines.values),

          // TRACKING (opcional si luego agregas marker dinámico)
          // markers: _buildTrackingMarkers(trackingState),
          onCameraMove: (cameraPosition) {
            context.read<MapaBloc>().add(
              OnCameraMove(cameraPosition: cameraPosition),
            );
          },

          onCameraIdle: () {
            context.read<MapaBloc>().add(OnCameraIdle());
          },

          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      },
    );
  }
  // Widget _googleMaps(BuildContext context) {
  //   return GoogleMap(
  //     mapType: MapType.normal,
  //     initialCameraPosition: state.cameraPosition,

  //     onMapCreated: (controller) {
  //       if (!state.controller!.isCompleted) {
  //         state.controller?.complete(controller);
  //       }
  //     },

  //     markers: Set<Marker>.of(state.markers.values),

  //     onCameraMove: (cameraPosition) {
  //       context.read<MapaBloc>().add(
  //         OnCameraMove(cameraPosition: cameraPosition),
  //       );
  //     },

  //     onCameraIdle: () {
  //       context.read<MapaBloc>().add(OnCameraIdle());
  //     },

  //     myLocationEnabled: true,
  //     myLocationButtonEnabled: true,
  //   );
  // }

  Widget _alertButton(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onLongPress: () {
          // context.read<TrackingBloc>().add(SendAlertEvent());

          // 🔔 Feedback inmediato
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 Alerta enviada'),
              duration: Duration(seconds: 2),
            ),
          );
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 38,
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

  Widget _googlePlacesAutocomplete(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          GooglePlaceAutoComplete(pickUpController, 'Posición actual', (
            prediction,
          ) {
            if (prediction != null) {
              // CERRAR TECLADO
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

          GooglePlaceAutoComplete(destinationController, 'Ir a', (prediction) {
            if (prediction != null) {
              // CERRAR TECLADO
              FocusScope.of(context).unfocus();

              context.read<MapaBloc>().add(
                OnAutoCompleteDestinationSelected(
                  lat: double.parse(prediction.lat!),
                  lng: double.parse(prediction.lng!),
                  destinationDescription: prediction.description ?? '',
                ),
              );
            }
          }),
        ],
      ),
    );
  }

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

  // Recentrar automaticamente
  // Widget _recenterButton(BuildContext context) {
  //   return BlocBuilder<MapaBloc, MapaState>(
  //     builder: (context, state) {
  //       return Positioned(
  //         bottom: 250,
  //         right: 20,
  //         child: FloatingActionButton(
  //           heroTag: "btnCenter",
  //           backgroundColor: state.isAutoCentering
  //               ? Colors.green
  //               : Colors.white,
  //           onPressed: () {
  //             context.read<MapaBloc>().add(ToggleAutoCenterEvent());
  //           },
  //           child: Icon(
  //             Icons.gps_fixed,
  //             color: state.isAutoCentering ? Colors.white : Colors.black,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
