import 'package:flutter/material.dart';

class EmptyPatrullaje extends StatelessWidget {
  const EmptyPatrullaje({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_walk, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          'Sin patrullaje asignado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Espera una asignación desde la central.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
