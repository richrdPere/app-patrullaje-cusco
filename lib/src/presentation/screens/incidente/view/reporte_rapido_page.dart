import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/media_preview_widget.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/widgets/incidente_location_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/widgets/incidente_media_actions.dart';

import '../bloc/incidente_bloc.dart';
import '../bloc/incidente_event.dart';
import '../bloc/incidente_state.dart';

import '../enums/incidente_tab_enum.dart';

class ReporteRapidoPage extends StatefulWidget {
  final TipoIncidente tipo;

  const ReporteRapidoPage({
    super.key,
    required this.tipo,
  });

  @override
  State<ReporteRapidoPage> createState() =>
      _ReporteRapidoPageState();
}

class _ReporteRapidoPageState
    extends State<ReporteRapidoPage> {

  final descripcionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<IncidenteBloc>()
        ..add(ObtenerUbicacionEvent())
        ..add(ObtenerIncidentesCercanosEvent());

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: Text(_title()),
      // ),

      body: BlocBuilder<IncidenteBloc, IncidenteState>(
        builder: (context, state) {

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // DESCRIPTION
                  TextField(
                    controller: descripcionCtrl,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: 'Describe lo sucedido...',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                   
                      ),

                      filled: true,
                      fillColor: const Color(0xff1E293B),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOCATION
                  IncidenteLocationCard(state: state),

                  const SizedBox(height: 20),

                  // MEDIA
                  const IncidenteMediaActions(),

                  const SizedBox(height: 16),

                  const MediaPreviewWidget(),

                  const SizedBox(height: 28),

                  // SUBMIT
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: () => _submit(context),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      icon: const Icon(Icons.send),

                      label: const Text(
                        'REPORTAR INCIDENTE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _color().withOpacity(.15),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 30,
            backgroundColor: _color(),

            child: Icon(
              _icon(),
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  _title(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Reporte táctico rápido',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {

    final state =
        context.read<IncidenteBloc>().state;

    final incidente = IncidenteModel(
      usuarioId: 1,
      patrullajeId: 1,
      zonaId: 1,

      tipo: widget.tipo.name.toUpperCase(),

      descripcion: descripcionCtrl.text,

      latitud: state.latitud!,
      longitud: state.longitud!,

      archivos: state.archivos,
    );

    context.read<IncidenteBloc>().add(
      CrearIncidenteEvent(incidente),
    );
  }

  String _title() {
    switch (widget.tipo) {
      case TipoIncidente.robo:
        return 'Reporte de Robo';

      case TipoIncidente.accidente:
        return 'Accidente';

      case TipoIncidente.incendio:
        return 'Incendio';

      case TipoIncidente.violencia:
        return 'Violencia';

      case TipoIncidente.sospechoso:
        return 'Sospechoso';

      case TipoIncidente.otro:
        return 'Otro';
    }
  }

  IconData _icon() {
    switch (widget.tipo) {
      case TipoIncidente.robo:
        return Icons.local_police;

      case TipoIncidente.accidente:
        return Icons.car_crash;

      case TipoIncidente.incendio:
        return Icons.local_fire_department;

      case TipoIncidente.violencia:
        return Icons.warning;

      case TipoIncidente.sospechoso:
        return Icons.visibility;

      case TipoIncidente.otro:
        return Icons.info;
    }
  }

  Color _color() {
    switch (widget.tipo) {
      case TipoIncidente.robo:
        return Colors.red;

      case TipoIncidente.accidente:
        return Colors.orange;

      case TipoIncidente.incendio:
        return Colors.deepOrange;

      case TipoIncidente.violencia:
        return Colors.purple;

      case TipoIncidente.sospechoso:
        return Colors.blue;

      case TipoIncidente.otro:
        return Colors.green;
    }
  }
}