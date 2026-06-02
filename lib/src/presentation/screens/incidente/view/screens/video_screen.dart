import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Reporte mediante video',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              // ),

              // const SizedBox(height: 6),

              // Text(
              //   'Seleccione o grabe un video relacionado a una actividad sospechosa o incidente.',
              //   style: TextStyle(color: Colors.grey.shade600),
              // ),

              // const SizedBox(height: 20),

              // =====================
              // SELECCIONAR VIDEO
              // =====================
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.video_library),

                  label: const Text('Seleccionar video'),

                  onPressed: () {
                    context.read<IncidenteBloc>().add(
                      const SeleccionarVideoEvent(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // =====================
              // GRABAR VIDEO
              // =====================
              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  icon: const Icon(Icons.videocam),

                  label: const Text('Grabar video'),

                  onPressed: () {
                    context.read<IncidenteBloc>().add(
                      const IniciarGrabacionVideoEvent(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // =====================
              // CONTADOR
              // =====================
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.video_file),

                    const SizedBox(width: 10),

                    Text(
                      '${state.archivos.length} video(s) seleccionado(s)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================
              // SIN VIDEOS
              // =====================
              if (state.archivos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Column(
                    children: [
                      Icon(
                        Icons.video_collection_outlined,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'No existe ningún video seleccionado',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: state.archivos.length,

                  separatorBuilder: (_, __) => const SizedBox(height: 8),

                  itemBuilder: (context, index) {
                    final archivo = state.archivos[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.video_file,
                          color: Colors.red,
                        ),

                        title: Text(
                          archivo.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        subtitle: const Text('Video seleccionado'),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {
                            context.read<IncidenteBloc>().add(
                              EliminarArchivoEvent(index),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              if (state.archivos.isNotEmpty)
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),

                    label: const Text('CONTINUAR'),

                    onPressed: () {
                      // Próximo paso:
                      // abrir VideoDetalleScreen
                    },
                  ),
                ),

              const SizedBox(height: 12),

              if (state.archivos.isNotEmpty)
                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear_all),

                    label: const Text('Limpiar videos'),

                    onPressed: () {
                      context.read<IncidenteBloc>().add(
                        const LimpiarArchivosEvent(),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
