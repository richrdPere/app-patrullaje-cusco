import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/widgets/historial_patrullaje_card.dart';

class HistorialPatrullajeList extends StatelessWidget {
  final List<HistorialPatrullajeModel> historial;

  const HistorialPatrullajeList({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: historial.length + 1,
      separatorBuilder: (_, index) {
        if (index == 0) {
          return const SizedBox(height: 16);
        }

        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return _HistorialHeader(totalRegistros: historial.length);
        }

        final item = historial[index - 1];

        return HistorialPatrullajeCard(historial: item);
      },
    );
  }
}

class _HistorialHeader extends StatelessWidget {
  final int totalRegistros;

  const _HistorialHeader({required this.totalRegistros});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registros del patrullaje',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$totalRegistros '
                  '${totalRegistros == 1 ? 'registro encontrado' : 'registros encontrados'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
