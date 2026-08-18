import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_stat_card.dart';

class HomeStatsSection extends StatelessWidget {
  final int incidenciasRegistradas;
  final int alertasSinLeer;
  final double distanciaRecorridaMetros;
  final bool isLoading;

  const HomeStatsSection({
    super.key,
    this.incidenciasRegistradas = 0,
    this.alertasSinLeer = 0,
    this.distanciaRecorridaMetros = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: HomeStatCard(
            title: 'Incidencias',
            value: isLoading ? '...' : incidenciasRegistradas.toString(),
            valueColor: colorScheme.error,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: HomeStatCard(
            title: 'Sin leer',
            value: isLoading ? '...' : alertasSinLeer.toString(),
            valueColor: Colors.orange,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: HomeStatCard(
            title: 'Recorrido',
            value: isLoading
                ? '...'
                : _formatDistance(distanciaRecorridaMetros),
            valueColor: Colors.green,
          ),
        ),
      ],
    );
  }

  String _formatDistance(double meters) {
    if (meters <= 0) {
      return '0 m';
    }

    if (meters < 1000) {
      return '${meters.round()} m';
    }

    final kilometers = meters / 1000;

    if (kilometers < 10) {
      return '${kilometers.toStringAsFixed(1)} km';
    }

    return '${kilometers.toStringAsFixed(0)} km';
  }
}
