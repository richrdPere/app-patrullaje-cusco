import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

// enum QuickIncidentType {
//   robo,
//   accidente,
//   incendio,
//   violencia,
//   sospechoso,
//   medico,
// }

class IncidenteQuickActionsSheet extends StatelessWidget {
  const IncidenteQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.14,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xff111827),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [

              // HANDLE
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              // TITLE
              const Text(
                'Reportar Incidente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: GridView.count(
                  controller: scrollController,
                  crossAxisCount: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [

                    _QuickActionButton(
                      icon: Icons.local_police,
                      label: 'Robo',
                      color: Colors.red,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.robo as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),

                    _QuickActionButton(
                      icon: Icons.car_crash,
                      label: 'Accidente',
                      color: Colors.orange,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.accidente as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),

                    _QuickActionButton(
                      icon: Icons.local_fire_department,
                      label: 'Incendio',
                      color: Colors.deepOrange,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.incendio as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),

                    _QuickActionButton(
                      icon: Icons.warning_amber,
                      label: 'Violencia',
                      color: Colors.purple,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.violencia as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),

                    _QuickActionButton(
                      icon: Icons.visibility,
                      label: 'Sospechoso',
                      color: Colors.blue,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.sospechoso as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),

                    _QuickActionButton(
                      icon: Icons.medical_services,
                      label: 'Médico',
                      color: Colors.green,
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          ReporteRapidoEvent(
                            TipoIncidente.otro as IncidenteRapidoEnum,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff1F2937),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 34,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}