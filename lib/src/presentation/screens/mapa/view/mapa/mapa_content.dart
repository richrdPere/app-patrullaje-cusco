import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_button.dart';
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

        Container(
          alignment: Alignment.bottomCenter,
          child: DefaultButton(
            text: 'REVISAR INCIDENTE',
            margin: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
            onPressed: () {
              context.goNamed(
                "incident",
                extra: IncidentData(
                  pickUpLatLng: state.pickUpLatLng,
                  pickUpDescription: state.pickUpDescription,
                  destinationLatLng: state.destinationLatLng,
                  destinationDescription: state.destinationDescription,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _googleMaps(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: state.cameraPosition,

      onMapCreated: (controller) {
        if (!state.controller!.isCompleted) {
          state.controller?.complete(controller);
        }
      },

      markers: Set<Marker>.of(state.markers.values),

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
}
