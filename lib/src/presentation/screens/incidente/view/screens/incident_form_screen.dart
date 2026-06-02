import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

class IncidenteFormScreen extends StatefulWidget {
  const IncidenteFormScreen({super.key});

  @override
  State<IncidenteFormScreen> createState() => _IncidenteFormScreenState();
}

class _IncidenteFormScreenState extends State<IncidenteFormScreen> {
  final descripcionCtrl = TextEditingController();
  TipoIncidente? selectedTipo;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteBloc>()
        ..add(ObtenerUbicacionEvent())
        ..add(ObtenerIncidentesCercanosEvent());
    });
  }

  @override
  void dispose() {
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================
              // TIPO INCIDENTE
              // =====================
              const Text(
                'Tipo de incidente',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TipoIncidente.values.map((tipo) {
                  final selected = selectedTipo == tipo;

                  return ChoiceChip(
                    selected: selected,
                    label: Text(_getTitle(tipo)),

                    onSelected: (_) {
                      setState(() {
                        selectedTipo = tipo;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // =====================
              // DESCRIPCION
              // =====================
              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: descripcionCtrl,
                maxLines: 3,
                maxLength: 300,

                decoration: InputDecoration(
                  hintText: 'Describe lo sucedido...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================
              // UBICACION
              // =====================
              // Card(
              //   child: ListTile(
              //     leading: const Icon(Icons.location_on, color: Colors.red),

              //     title: const Text('Ubicación actual'),

              //     subtitle: Text(state.direccion ?? 'Obteniendo ubicación...'),
              //   ),
              // ),

              // const SizedBox(height: 20),

              // =====================
              // EVIDENCIAS
              // =====================
              const Text(
                'Evidencias fotográficas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar foto'),
                      onPressed: () {
                        context.read<IncidenteBloc>().add(
                          const TomarFotoEvent(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      onPressed: () {
                        context.read<IncidenteBloc>().add(
                          const SeleccionarImagenEvent(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // EVIDENCIAS ADJUNTADAS
              if (state.archivos.isNotEmpty)
                SizedBox(
                  height: 110,

                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,

                    itemCount: state.archivos.length,

                    separatorBuilder: (_, __) => const SizedBox(width: 10),

                    itemBuilder: (_, index) {
                      final archivo = state.archivos[index];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),

                            child: Image.file(
                              File(archivo.path),
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            top: 4,
                            right: 4,

                            child: GestureDetector(
                              onTap: () {
                                context.read<IncidenteBloc>().add(
                                  EliminarArchivoEvent(index),
                                );
                              },

                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),

                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // =====================
              // INCIDENTES CERCANOS
              // =====================
              // const Text(
              //   'Incidentes cercanos',
              //   style: TextStyle(fontWeight: FontWeight.w600),
              // ),

              // const SizedBox(height: 12),
              const SizedBox(height: 30),

              // =====================
              // BOTON GUARDAR
              // =====================
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),

                  label: const Text('REPORTAR INCIDENTE'),

                  onPressed: () {
                    if (selectedTipo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleccione un tipo de incidente'),
                        ),
                      );

                      return;
                    }

                    if (state.archivos.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debe adjuntar al menos una fotografía',
                          ),
                        ),
                      );

                      return;
                    }

                    // context.read<IncidenteBloc>().add(
                    //   ReporteRapidoEvent(
                    //     tipo: selectedTipo!,
                    //     // descripcion: descripcionCtrl.text.trim(),
                    //   ),
                    // );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getTitle(TipoIncidente tipo) {
    switch (tipo) {
      case TipoIncidente.robo:
        return 'Robo';

      case TipoIncidente.accidente:
        return 'Accidente';

      case TipoIncidente.incendio:
        return 'Incendio';

      case TipoIncidente.violencia:
        return 'Violencia';

      case TipoIncidente.sospechoso:
        return 'Sospechoso';

      case TipoIncidente.otro:
        return 'Otro';
    }
  }
}
