import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

class ReporteIncidentePage extends StatefulWidget {
  const ReporteIncidentePage({super.key});

  @override
  State<ReporteIncidentePage> createState() => _ReporteIncidentePageState();
}

class _ReporteIncidentePageState extends State<ReporteIncidentePage> {
  String? tipoSeleccionado;
  final TextEditingController descripcionCtrl = TextEditingController();

  final List<String> tipos = [
    'ROBO',
    'ACCIDENTE',
    'SOSPECHOSO',
    'VIOLENCIA',
    'OTRO',
  ];

  final List<File> archivos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Incidencia')),
      body: BlocConsumer<IncidenteBloc, IncidenteState>(
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Incidencia enviada')));

            Navigator.pop(context);
          }

          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildContent(context),

              // LOADING OVERLAY
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );

          // builder: (context, state) {
          //   return Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       children: [
          //         // TIPOS
          //         const Align(
          //           alignment: Alignment.centerLeft,
          //           child: Text(
          //             'Tipo de incidencia',
          //             style: TextStyle(fontWeight: FontWeight.bold),
          //           ),
          //         ),

          //         const SizedBox(height: 10),

          //         Wrap(
          //           spacing: 10,
          //           children: tipos.map((tipo) {
          //             return ChoiceChip(
          //               label: Text(tipo),
          //               selected: tipoSeleccionado == tipo,
          //               onSelected: (_) {
          //                 setState(() {
          //                   tipoSeleccionado = tipo;
          //                 });
          //               },
          //             );
          //           }).toList(),
          //         ),

          //         const SizedBox(height: 20),

          //         // DESCRIPCIÓN
          //         TextField(
          //           controller: descripcionCtrl,
          //           maxLines: 3,
          //           decoration: const InputDecoration(
          //             labelText: 'Descripción (opcional)',
          //             border: OutlineInputBorder(),
          //           ),
          //         ),

          //         const SizedBox(height: 20),

          //         // EVIDENCIA
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceAround,
          //           children: [
          //             ElevatedButton.icon(
          //               onPressed: () {
          //                 // abrir cámara
          //               },
          //               icon: const Icon(Icons.camera_alt),
          //               label: const Text('Foto'),
          //             ),
          //             ElevatedButton.icon(
          //               onPressed: () {
          //                 // grabar video
          //               },
          //               icon: const Icon(Icons.videocam),
          //               label: const Text('Video'),
          //             ),
          //           ],
          //         ),

          //         const SizedBox(height: 20),

          //         // UBICACIÓN
          //         Container(
          //           padding: const EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: Colors.green[100],
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: const Row(
          //             children: [
          //               Icon(Icons.location_on, color: Colors.green),
          //               SizedBox(width: 10),
          //               Text('Ubicación capturada automáticamente'),
          //             ],
          //           ),
          //         ),

          //         const Spacer(),

          //         // BOTÓN ENVIAR
          //         SizedBox(
          //           width: double.infinity,
          //           child: ElevatedButton(
          //             onPressed: () {
          //               _enviarIncidencia();
          //             },
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.red,
          //               padding: const EdgeInsets.symmetric(vertical: 15),
          //             ),
          //             child: const Text(
          //               'ENVIAR REPORTE',
          //               style: TextStyle(fontSize: 16),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   );
        },
      ),
    );
  }

  // =========================
  // UI CONTENT
  // =========================
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // TIPOS
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tipo de incidencia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // EVIDENCIA (temporal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: integrar image_picker
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Foto'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: video
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
              onPressed: () => _enviarIncidencia(context),
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
    );
  }

  // =========================
  // UBICACIÓN
  // =========================
  Future<Position> _getUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("GPS desactivado");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  // =========================
  // ENVIAR INCIDENTE
  // =========================
  Future<void> _enviarIncidencia(BuildContext context) async {
    if (tipoSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un tipo')));
      return;
    }

    try {
      final posicion = await _getUbicacion();

      final params = IncidenteModel(
        usuarioId: 1, // ⚠️ luego lo sacas de sesión
        tipo: tipoSeleccionado!,
        descripcion: descripcionCtrl.text,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        archivos: archivos,
      );

      context.read<IncidenteBloc>().add(CrearIncidenteEvent(params));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error ubicación: $e")));
    }
  }

  // void _enviarIncidencia() {
  //   if (tipoSeleccionado == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Seleccione un tipo')));
  //     return;
  //   }

  //   // Aquí irá tu Bloc
  //   print('Tipo: $tipoSeleccionado');
  //   print('Descripción: ${descripcionCtrl.text}');
  // }
}
