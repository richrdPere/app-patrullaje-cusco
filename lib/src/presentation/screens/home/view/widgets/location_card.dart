import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

class LocationCard extends StatelessWidget {
  final TrackingState trackingState;

  const LocationCard({super.key, required this.trackingState});

  @override
  Widget build(BuildContext context) {
    final location = trackingState.lastLocation;

    if (location == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.my_location)),
        title: const Text('Ubicación actual'),
        subtitle: Text(
          '${location.latitud.toStringAsFixed(6)}, '
          '${location.longitud.toStringAsFixed(6)}',
        ),
      ),
    );
  }
}
