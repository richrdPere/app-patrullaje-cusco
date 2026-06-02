import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';



class EvidenciaScreen extends StatelessWidget {
  const EvidenciaScreen({super.key});

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
              //   'Evidencias',
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),

              // const SizedBox(height: 6),

              // Text(
              //   'Adjunte fotografías, videos o audios relacionados al incidente.',
              //   style: TextStyle(
              //     color: Colors.grey.shade600,
              //   ),
              // ),

              // const SizedBox(height: 24),

              // FOTOS

              // Row(
              //   children: [

              //     Expanded(
              //       child: ElevatedButton.icon(
              //         icon: const Icon(Icons.camera_alt),

              //         label: const Text('Cámara'),

              //         onPressed: () {
              //           context.read<IncidenteBloc>().add(
              //             const TomarFotoEvent(),
              //           );
              //         },
              //       ),
              //     ),

              //     const SizedBox(width: 10),

              //     Expanded(
              //       child: ElevatedButton.icon(
              //         icon: const Icon(Icons.photo_library),

              //         label: const Text('Galería'),

              //         onPressed: () {
              //           context.read<IncidenteBloc>().add(
              //             const SeleccionarImagenEvent(),
              //           );
              //         },
              //       ),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 12),

              // VIDEO

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.videocam),

                  label: const Text('Grabar video'),

                  onPressed: () {
                    context.read<IncidenteBloc>().add(
                      const IniciarGrabacionVideoEvent(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // AUDIO

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mic),

                  label: const Text('Grabar audio'),

                  onPressed: () {
                    context.read<IncidenteBloc>().add(
                      const IniciarGrabacionAudioEvent(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // CONTADOR

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [

                    const Icon(Icons.attach_file),

                    const SizedBox(width: 10),

                    Text(
                      '${state.archivos.length} archivo(s) adjunto(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // LISTA ARCHIVOS

              if (state.archivos.isEmpty)

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  child: Column(
                    children: [

                      Icon(
                        Icons.folder_open,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'No existen evidencias adjuntas',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )

              else

                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: state.archivos.length,

                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),

                  itemBuilder: (context, index) {

                    final archivo =
                        state.archivos[index];

                    return Card(
                      child: ListTile(

                        leading: const Icon(
                          Icons.insert_drive_file,
                        ),

                        title: Text(
                          archivo.path
                              .split('/')
                              .last,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed: () {
                            context
                                .read<IncidenteBloc>()
                                .add(
                                  EliminarArchivoEvent(
                                    index,
                                  ),
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

                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear_all),

                    label: const Text(
                      'Limpiar evidencias',
                    ),

                    onPressed: () {
                      context.read<IncidenteBloc>().add(
                        const LimpiarArchivosEvent(),
                      );
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
}