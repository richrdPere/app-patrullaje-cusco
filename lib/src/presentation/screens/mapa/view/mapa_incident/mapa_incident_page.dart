import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa_incident/mapa_incident_content.dart';

class MapaIncidentPage extends StatefulWidget {
  final IncidentData incident;
  const MapaIncidentPage({super.key, required this.incident});

  @override
  State<MapaIncidentPage> createState() => _MapaIncidentPageState();
}

class _MapaIncidentPageState extends State<MapaIncidentPage> {
  late LatLng? pickUp;
  late LatLng? destination;
  late String pickUpDesc;
  late String destinationDesc;

  @override
  void initState() {
    super.initState();

    // Desglosar aquí (mejor práctica)
    pickUp = widget.incident.pickUpLatLng;
    destination = widget.incident.destinationLatLng;
    pickUpDesc = widget.incident.pickUpDescription;
    destinationDesc = widget.incident.destinationDescription;

    // Iniciar el bloc
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<MapaIncidentBloc>().add(
        MapaIncidentInitEvent(
          pickUpLatLng: pickUp!,
          destinationLatLng: destination!,
          pickUpDescription: pickUpDesc,
          destinationDescription: destinationDesc,
        ),
      );

      context.read<MapaIncidentBloc>().add(AddPolyline());
      context.read<MapaIncidentBloc>().add(
        ChangeMapCameraPosition(lat: pickUp!.latitude, lng: pickUp!.longitude),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MapaIncidentBloc, MapaIncidentState>(
        builder: (context, state) {
          return MapaIncidentContent(state: state);
        },
      ),
    );
  }
}
