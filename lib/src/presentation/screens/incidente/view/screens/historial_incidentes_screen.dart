import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class HistorialIncidentesScreen extends StatefulWidget {
  const HistorialIncidentesScreen({super.key});

  @override
  State<HistorialIncidentesScreen> createState() =>
      _HistorialIncidentesScreenState();
}

class _HistorialIncidentesScreenState extends State<HistorialIncidentesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteBloc>().add(const ObtenerIncidentesCercanosEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        // final incidentes = state.incidentesCercanos;

        final incidentes = [];

        return RefreshIndicator(
          onRefresh: () async {
            context.read<IncidenteBloc>().add(
              const ObtenerIncidentesCercanosEvent(),
            );
          },

          child: ListView(
            padding: const EdgeInsets.all(16),

            children: [
              // const Text(
              //   'Historial de Incidentes',
              //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              // ),

              // const SizedBox(height: 8),

              // Text(
              //   'Consulta incidentes recientes y cercanos.',
              //   style: TextStyle(color: Colors.grey.shade600),
              // ),

              // const SizedBox(height: 24),

              // INCIDENTES CERCANOS
              const Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Text(
                    'Incidentes Cercanos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (incidentes.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 10),

                        const Text('No se encontraron incidentes cercanos.'),
                      ],
                    ),
                  ),
                )
              else
                ...incidentes.map((incidente) {
                  return Card(
                    elevation: 2,

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColor(incidente.tipo),

                        child: Icon(
                          _getIcon(incidente.tipo),
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        incidente.tipo,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          if (incidente.descripcion != null)
                            Text(
                              incidente.descripcion!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          const SizedBox(height: 4),

                          Text(
                            '${incidente.distanciaMetros.toStringAsFixed(0)} m',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                      trailing: const Icon(Icons.chevron_right),

                      onTap: () {
                        // Aquí posteriormente:
                        //
                        // context.push(
                        //   '/mapa/incident',
                        //   extra: incidente,
                        // );
                      },
                    ),
                  );
                }),

              const SizedBox(height: 30),

              const Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text(
                    'Actividad Reciente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                  ),

                  title: const Text('Historial de reportes'),

                  subtitle: const Text(
                    'Próximamente podrá consultar todos los incidentes reportados por el serenazgo.',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROBO':
        return Colors.red;

      case 'ACCIDENTE':
        return Colors.orange;

      case 'INCENDIO':
        return Colors.deepOrange;

      case 'VIOLENCIA':
        return Colors.purple;

      case 'SOSPECHOSO':
        return Colors.blue;

      case 'MEDICO':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROBO':
        return Icons.local_police;

      case 'ACCIDENTE':
        return Icons.car_crash;

      case 'INCENDIO':
        return Icons.local_fire_department;

      case 'VIOLENCIA':
        return Icons.warning;

      case 'SOSPECHOSO':
        return Icons.visibility;

      case 'MEDICO':
        return Icons.medical_services;

      default:
        return Icons.report_problem;
    }
  }
}
