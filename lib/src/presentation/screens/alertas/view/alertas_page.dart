import 'package:flutter/material.dart';

class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [
          AlertaItem(
            tipo: 'ROBO',
            descripcion: 'Robo en proceso',
            zona: 'Centro Histórico',
            tiempo: 'Hace 2 min',
            prioridad: 'alta',
          ),
          AlertaItem(
            tipo: 'SOSPECHOSO',
            descripcion: 'Persona sospechosa',
            zona: 'San Sebastián',
            tiempo: 'Hace 5 min',
            prioridad: 'media',
          ),
          AlertaItem(
            tipo: 'INFORME',
            descripcion: 'Reporte de patrullaje',
            zona: 'Wanchaq',
            tiempo: 'Hace 10 min',
            prioridad: 'baja',
          ),
        ],
      ),
    );
  }
}

class AlertaItem extends StatelessWidget {
  final String tipo;
  final String descripcion;
  final String zona;
  final String tiempo;
  final String prioridad;

  const AlertaItem({
    super.key,
    required this.tipo,
    required this.descripcion,
    required this.zona,
    required this.tiempo,
    required this.prioridad,
  });

  Color getColor() {
    switch (prioridad) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: getColor(), size: 30),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getColor(),
                    ),
                  ),
                  Text(descripcion),
                  Text('Zona: $zona'),
                  Text(tiempo, style: const TextStyle(fontSize: 12)),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // ir al mapa
                        },
                        child: const Text('Ver en mapa'),
                      ),
                      TextButton(
                        onPressed: () {
                          // atender alerta
                        },
                        child: const Text('Atender'),
                      ),
                    ],
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
