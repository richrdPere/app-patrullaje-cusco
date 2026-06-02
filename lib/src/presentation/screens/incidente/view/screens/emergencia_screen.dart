import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';


class EmergenciaScreen extends StatelessWidget {
  const EmergenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 10),

              const Icon(
                Icons.warning_rounded,
                size: 70,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              const Text(
                'EMERGENCIA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Utilice esta opción únicamente en situaciones que requieran asistencia inmediata.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // UBICACION

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),

                  title: const Text(
                    'Ubicación actual',
                  ),

                  subtitle: Text(
                    state.direccion ??
                        'Obteniendo ubicación...',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // BOTON SOS

              GestureDetector(
                onTap: () {
                  _confirmarSOS(context);
                },

                child: Container(
                  width: 220,
                  height: 220,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(.4),
                        blurRadius: 25,
                        spreadRadius: 10,
                      ),
                    ],
                  ),

                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Card(
                color: Colors.red.shade50,

                child: const Padding(
                  padding: EdgeInsets.all(16),

                  child: Column(
                    children: [

                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Ubicación GPS'),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Fecha y hora'),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Sereno responsable'),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Estado de emergencia'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmarSOS(
    BuildContext context,
  ) async {

    final result = await showDialog<bool>(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Confirmar Emergencia',
          ),

          content: const Text(
            '¿Desea enviar una alerta de emergencia a la central?',
          ),

          actions: [

            TextButton(
              onPressed: () {
               // Navigator.pop(_, false);
              },

              child: const Text('Cancelar'),
            ),

            FilledButton(
              onPressed: () {
               // Navigator.pop(_, true);
              },

              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    // EVENTO SOS
    context.read<IncidenteBloc>().add(
      const ReporteRapidoEvent(
        IncidenteRapidoEnum.emergencia,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Alerta de emergencia enviada correctamente',
        ),
      ),
    );
  }
}