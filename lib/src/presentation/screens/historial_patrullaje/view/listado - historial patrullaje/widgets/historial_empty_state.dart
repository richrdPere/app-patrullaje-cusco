import 'package:flutter/material.dart';

class HistorialEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const HistorialEmptyState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 82,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Sin registros de historial',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            'Todavía no se han registrado observaciones, '
            'novedades, alertas o puntos críticos en este patrullaje.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
          ),
        ],
      ),
    );
  }
}
