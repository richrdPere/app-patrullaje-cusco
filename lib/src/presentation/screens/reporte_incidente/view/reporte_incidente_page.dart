import 'package:flutter/material.dart';

class ReporteIncidentePage extends StatefulWidget {
  const ReporteIncidentePage({super.key});

  @override
  State<ReporteIncidentePage> createState() => _ReporteIncidentePageState();
}

class _ReporteIncidentePageState extends State<ReporteIncidentePage> {

  String? tipoSeleccionado;
  final TextEditingController descripcionCtrl = TextEditingController();

  final List<String> tipos = [
    'Robo',
    'Accidente',
    'Sospechoso',
    'Violencia',
    'Otro'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidencia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // TIPOS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Tipo de incidencia',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: tipos.map((tipo) {
                return ChoiceChip(
                  label: Text(tipo),
                  selected: tipoSeleccionado == tipo,
                  onSelected: (_) {
                    setState(() {
                      tipoSeleccionado = tipo;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // DESCRIPCIÓN
            TextField(
              controller: descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // EVIDENCIA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // abrir cámara
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // grabar video
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Video'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // UBICACIÓN
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Ubicación capturada automáticamente'),
                ],
              ),
            ),

            const Spacer(),

            // BOTÓN ENVIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _enviarIncidencia();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'ENVIAR REPORTE',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarIncidencia() {
    if (tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un tipo')),
      );
      return;
    }

    // Aquí irá tu Bloc
    print('Tipo: $tipoSeleccionado');
    print('Descripción: ${descripcionCtrl.text}');
  }
}