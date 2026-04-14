import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Bienvenido al Sistema de Patrullaje',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de patrullas
                },
                child: const Text('Patrullas'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de reportes
                },
                child: const Text('Reportes'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de configuración
                },
                child: const Text('Configuración'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Últimas actividades',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );  
  }
}
