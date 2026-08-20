import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';

class PatrullajeListCard extends StatelessWidget {
  final PatrullajeListadoData patrullaje;
  final VoidCallback onTap;

  const PatrullajeListCard({
    super.key,
    required this.patrullaje,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final resumen = patrullaje.resumen;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _unitIcon(patrullaje.unidad?.tipo),
                      color: colors.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patrullaje.zona?.nombre ?? 'Zona no disponible',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          DateFormat('dd/MM/yyyy').format(patrullaje.fecha),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(estado: patrullaje.estado),
                ],
              ),

              if (patrullaje.descripcion?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 14),

                Text(
                  patrullaje.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.schedule,
                    label:
                        '${_formatTime(patrullaje.horaInicio)} - '
                        '${_formatTime(patrullaje.horaFin)}',
                  ),

                  // if (patrullaje.unidad != null)
                  //   _InfoChip(
                  //     icon: Icons.directions_car_outlined,
                  //     label:
                  //         patrullaje.unidad?.placa ?? patrullaje.unidad!.codigo,
                  //   ),

                  // if (resumen != null)
                  //   _InfoChip(
                  //     icon: Icons.route_outlined,
                  //     label: _formatDistance(resumen.distanciaTotalMetros),
                  //   ),

                  if (resumen != null)
                    _InfoChip(
                      icon: Icons.report_outlined,
                      label: '${resumen.totalIncidencias} incidencias',
                    ),
                ],
              ),

              // const SizedBox(height: 14),

              // Row(
              //   children: [
              //     Icon(Icons.history_rounded, size: 18, color: colors.primary),

              //     const SizedBox(width: 6),

              //     Text(
              //       'Ver historial',
              //       style: Theme.of(context).textTheme.labelLarge?.copyWith(
              //         color: colors.primary,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),

              //     const Spacer(),

              //     Icon(
              //       Icons.chevron_right_rounded,
              //       color: colors.onSurfaceVariant,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _unitIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'MOTO':
      case 'MOTO_LINEAL':
        return Icons.two_wheeler;

      case 'BICICLETA':
        return Icons.pedal_bike;

      case 'A_PIE':
        return Icons.directions_walk;

      default:
        return Icons.directions_car_outlined;
    }
  }

  String _formatTime(String value) {
    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }

  // String _formatDistance(double meters) {
  //   if (meters < 1000) {
  //     return '${meters.round()} m';
  //   }

  //   return '${(meters / 1000).toStringAsFixed(1)} km';
  // }
}

class _StatusBadge extends StatelessWidget {
  final String estado;

  const _StatusBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final data = _statusData(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        data.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: data.color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _StatusData _statusData(String status) {
    switch (status) {
      case 'PROGRAMADO':
        return const _StatusData(label: 'Programado', color: Colors.blueGrey);

      case 'ASIGNADO':
        return const _StatusData(label: 'Asignado', color: Colors.blue);

      case 'ACEPTADO':
        return const _StatusData(label: 'Aceptado', color: Colors.indigo);

      case 'EN_CURSO':
        return const _StatusData(label: 'En curso', color: Colors.orange);

      case 'FINALIZADO':
        return const _StatusData(label: 'Finalizado', color: Colors.green);

      default:
        return const _StatusData(label: 'Desconocido', color: Colors.grey);
    }
  }
}

class _StatusData {
  final String label;
  final Color color;

  const _StatusData({required this.label, required this.color});
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),

          const SizedBox(width: 5),

          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}





