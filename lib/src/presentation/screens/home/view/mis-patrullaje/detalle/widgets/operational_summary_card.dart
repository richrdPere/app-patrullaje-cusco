import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/section_card.dart';

class OperationalSummaryCard extends StatelessWidget {
  final PatrullajeResumenData? resumen;

  const OperationalSummaryCard({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: colors.primary),

              const SizedBox(width: 9),

              Text(
                'Resumen operativo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (resumen == null)
            const EmptySectionMessage(
              message:
                  'El resumen estará disponible cuando finalice el patrullaje.',
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.75,
              children: [
                _SummaryItem(
                  icon: Icons.timer_outlined,
                  label: 'Duración',
                  value: _formatDuration(resumen!.duracionSegundos),
                  color: Colors.blue,
                ),

                _SummaryItem(
                  icon: Icons.route_outlined,
                  label: 'Recorrido',
                  value: _formatDistance(resumen!.distanciaTotalMetros),
                  color: Colors.green,
                ),

                _SummaryItem(
                  icon: Icons.report_outlined,
                  label: 'Incidencias',
                  value: resumen!.totalIncidencias.toString(),
                  color: Colors.red,
                ),

                _SummaryItem(
                  icon: Icons.notes_outlined,
                  label: 'Observaciones',
                  value: resumen!.totalObservaciones.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h';
    }

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${minutes}m';
    }

    return '${duration.inMinutes} min';
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
