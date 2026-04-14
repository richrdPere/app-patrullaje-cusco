import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/gps/gps_bloc.dart';

class GpsAccessScreen extends StatelessWidget {
  const GpsAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            return (state.isGpsEnabled)
                ? const _EnableGpsMessage()
                : const _AccessButton();
          },
        ),
      ),
    );
  }
}

class _AccessButton extends StatelessWidget {
  const _AccessButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Es necesario el acceso a GPS'),
        MaterialButton(
          onPressed: () {},
          color: Colors.blue,
          shape: const StadiumBorder(),
          elevation: 0,
          // splashColor: Colors.transparent,
          child: const Text(
            'Solicitar Acceso',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Permitir acceso a tu ubicación',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Para mostrar tu ubicación en el mapa, necesitamos acceder a tu ubicación.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para solicitar permisos de ubicación
            },
            child: Text('Permitir Acceso'),
          ),
        ],
      ),
    );
  }
}
