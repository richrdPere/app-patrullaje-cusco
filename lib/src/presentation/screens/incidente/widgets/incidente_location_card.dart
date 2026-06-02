import 'package:flutter/material.dart';

import '../bloc/incidente_state.dart';

class IncidenteLocationCard extends StatelessWidget {

  final IncidenteState state;

  const IncidenteLocationCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.location_on,
                color: Colors.green,
              ),

              SizedBox(width: 10),

              Text(
                'Ubicación Actual',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (state.latitud != null)
            Text(
              'Latitud: ${state.latitud}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

          if (state.longitud != null)
            Text(
              'Longitud: ${state.longitud}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

          if (state.direccion != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),

              child: Text(
                state.direccion!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}