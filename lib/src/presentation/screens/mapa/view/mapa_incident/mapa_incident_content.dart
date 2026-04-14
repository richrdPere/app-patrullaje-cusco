import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/boton_azul.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_icon_back.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_text_field.dart';

class MapaIncidentContent extends StatelessWidget {
  MapaIncidentState state;

  MapaIncidentContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _googleMaps(context),
        Align(
          alignment: Alignment.bottomCenter,

          child: _cardIncidentInfo(context),
        ),
        Container(
          margin: EdgeInsets.only(top: 50, left: 20),
          child: DefauldIconBack(),
        ),
      ],
    );
  }

  Widget _cardIncidentInfo(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text("Rcoger en", style: TextStyle(fontSize: 15)),
            subtitle: Text('Calle 123 av. sol', style: TextStyle(fontSize: 13)),
            leading: Icon(Icons.location_on),
          ),

          ListTile(
            title: Text("Dejar en", style: TextStyle(fontSize: 15)),
            subtitle: Text('Calle 123 av. sol', style: TextStyle(fontSize: 13)),
            leading: Icon(Icons.my_location),
          ),

          ListTile(
            title: Text(
              "Tiempo y distancia aproximados",
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text('0Km 0Min', style: TextStyle(fontSize: 13)),
            leading: Icon(Icons.timer),
          ),

          // ListTile(
          //   title: Text("Precios recomendados", style: TextStyle(fontSize: 15)),
          //   subtitle: Text('0\$', style: TextStyle(fontSize: 13)),
          //   leading: Icon(Icons.attach_money),
          // ),

          DefaultTextField(
            margin: EdgeInsets.only(left: 10, right: 10),
            label: "Ofrece tu tarifa",
            icon: Icons.attach_money,
            onChanged: (text) {},
          ),

          BotonAzul(text: "Buscar ", onPressed: () {}),
        ],
      ),
    );
  }

  Widget _googleMaps(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.52,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: state.cameraPosition,
        markers: Set<Marker>.of(state.markers.values),
        polylines: Set<Polyline>.of(state.polylines.values),
        onMapCreated: (controller) {
          if (!state.controller!.isCompleted) {
            state.controller?.complete(controller);
          }
        },
      ),
    );
  }
}
