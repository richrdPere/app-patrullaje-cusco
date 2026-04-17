import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_content.dart';

class MapaPage extends StatefulWidget {
  static const name = 'mapa-screen';

  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapaBloc>().add(MapaInitEvent());
      context.read<MapaBloc>().add(FindPosition());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: MultiBlocListener(
        listeners: [
          // Listener de mapa
          BlocListener<MapaBloc, MapaState>(
            listenWhen: (prev, curr) =>
                prev.placemarkData != curr.placemarkData,
            listener: (context, state) {
              //  if (state.placemarkData != null) {}
            },
          ),

          // Listener de alertas
          BlocListener<AlertBloc, AlertState>(
            listener: (context, state) {
              if (state.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🚨 Alerta enviada")),
                );
              }

              if (state.error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("❌ ${state.error}")));
              }
            },
          ),
        ],
        child: BlocBuilder<MapaBloc, MapaState>(
          builder: (context, state) {
            return MapaContent(state: state);
          },
        ),
      ),
    );
  }
}
