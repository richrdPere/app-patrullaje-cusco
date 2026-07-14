import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/home_stat_card.dart';

class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: HomeStatCard(
            title: 'Incidencias',
            value: '3',
            valueColor: Colors.red,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: HomeStatCard(
            title: 'Alertas',
            value: '2',
            valueColor: Colors.orange,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: HomeStatCard(
            title: 'Recorrido',
            value: '75%',
            valueColor: Colors.green,
          ),
        ),
      ],
    );
  }
}
