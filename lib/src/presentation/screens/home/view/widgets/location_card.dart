import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class LocationCard extends StatelessWidget {
  final TrackingState trackingState;

  const LocationCard({super.key, required this.trackingState});

  @override
  Widget build(BuildContext context) {
    // ===========================================
    // TRACKING INACTIVO
    // ===========================================
    if (!trackingState.isTracking) {
      return Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.location_disabled, color: Colors.grey),
          ),
          title: const Text(
            'Seguimiento inactivo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'El seguimiento comenzará al iniciar el patrullaje.',
          ),
        ),
      );
    }

    // ===========================================
    // ESPERANDO PRIMERA UBICACIÓN
    // ===========================================
    if (trackingState.lastLocation == null) {
      return const Card(
        elevation: 1,
        child: ListTile(
          leading: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(
            'Obteniendo ubicación...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('Esperando la primera posición GPS.'),
        ),
      );
    }

    final location = trackingState.lastLocation!;

    final velocidad = ((location.velocidad ?? 0) * 3.6).toStringAsFixed(1);

    final precision = location.precision?.toStringAsFixed(1) ?? '--';

    final fecha = location.fechaHora;

    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}:'
        '${fecha.second.toString().padLeft(2, '0')}';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.my_location, color: Colors.green),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación actual',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  _LocationItem(
                    icon: Icons.pin_drop_outlined,
                    label: 'Latitud',
                    value: location.latitud.toStringAsFixed(6),
                  ),

                  _LocationItem(
                    icon: Icons.pin_drop,
                    label: 'Longitud',
                    value: location.longitud.toStringAsFixed(6),
                  ),

                  _LocationItem(
                    icon: Icons.speed,
                    label: 'Velocidad',
                    value: '$velocidad km/h',
                  ),

                  _LocationItem(
                    icon: Icons.gps_fixed,
                    label: 'Precisión',
                    value: '$precision m',
                  ),

                  _LocationItem(
                    icon: Icons.schedule,
                    label: 'Actualizado',
                    value: hora,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LocationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),

          const SizedBox(width: 8),

          SizedBox(
            width: 85,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
