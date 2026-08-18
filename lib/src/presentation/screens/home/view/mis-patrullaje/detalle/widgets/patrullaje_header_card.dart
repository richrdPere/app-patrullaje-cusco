import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';

class PatrullajeHeaderCard extends StatelessWidget {
  final PatrullajeListadoData patrullaje;

  const PatrullajeHeaderCard({super.key, required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final status = _getStatusData(patrullaje.estado);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _unitIcon(patrullaje.unidad?.tipo),
                  color: colors.primary,
                  size: 28,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            patrullaje.zona?.nombre ?? 'Patrullaje municipal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            patrullaje.descripcion?.trim().isNotEmpty == true
                ? patrullaje.descripcion!
                : 'Sin descripción registrada.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
        ],
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

  _StatusData _getStatusData(String status) {
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
