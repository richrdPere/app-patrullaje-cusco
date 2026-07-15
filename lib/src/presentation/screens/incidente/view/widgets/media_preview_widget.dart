import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/incidencia/incidente_bloc.dart';
import '../../blocs/incidencia/incidente_event.dart';
import '../../blocs/incidencia/incidente_state.dart';

class MediaPreviewWidget extends StatelessWidget {
  static const int maxArchivos = 5;

  const MediaPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidenteBloc, IncidenteState>(
      listenWhen: (previous, current) {
        return previous.mediaError != current.mediaError &&
            current.mediaError != null;
      },
      listener: (context, state) {
        final error = state.mediaError;

        if (error == null || error.isEmpty) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );

        context.read<IncidenteBloc>().add(const LimpiarArchivosLocalesEvent());
      },
      buildWhen: (previous, current) {
        return previous.archivosLocales != current.archivosLocales ||
            previous.loadingMedia != current.loadingMedia ||
            previous.recordingVideo != current.recordingVideo ||
            previous.recordingAudio != current.recordingAudio;
      },
      builder: (context, state) {
        final archivos = state.archivosLocales;
        final puedeAgregar =
            archivos.length < maxArchivos &&
            !state.loadingMedia &&
            !state.recordingVideo &&
            !state.recordingAudio;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cantidad: archivos.length, state: state),

            const SizedBox(height: 12),

            if (state.recordingVideo)
              _buildRecordingIndicator(
                context: context,
                icon: Icons.videocam_rounded,
                text: 'Grabando video...',
                onStop: () {
                  context.read<IncidenteBloc>().add(
                    const DetenerGrabacionVideoEvent(),
                  );
                },
              ),

            if (state.recordingAudio)
              _buildRecordingIndicator(
                context: context,
                icon: Icons.mic_rounded,
                text: 'Grabando audio...',
                onStop: () {
                  context.read<IncidenteBloc>().add(
                    const DetenerGrabacionAudioEvent(),
                  );
                },
              ),

            if (state.recordingVideo || state.recordingAudio)
              const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: puedeAgregar ? archivos.length + 1 : archivos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (puedeAgregar && index == archivos.length) {
                  return _buildAddButton(context, loading: state.loadingMedia);
                }

                final file = archivos[index];
                final tipo = _obtenerTipoArchivo(file);

                return _buildMediaItem(
                  context: context,
                  file: file,
                  index: index,
                  tipo: tipo,
                  disabled:
                      state.loadingMedia ||
                      state.recordingVideo ||
                      state.recordingAudio,
                );
              },
            ),

            if (state.loadingMedia) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Procesando archivo multimedia...',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  // ======================================================
  // ENCABEZADO
  // ======================================================

  Widget _buildHeader({required int cantidad, required IncidenteState state}) {
    String descripcion = 'Agrega fotografías o videos como evidencia.';

    if (state.recordingVideo) {
      descripcion = 'La grabación de video se encuentra activa.';
    } else if (state.recordingAudio) {
      descripcion = 'La grabación de audio se encuentra activa.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.perm_media_outlined, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evidencias multimedia',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                descripcion,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        Text(
          '$cantidad/$maxArchivos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cantidad >= maxArchivos ? Colors.red : Colors.black54,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // ITEM MULTIMEDIA
  // ======================================================

  Widget _buildMediaItem({
    required BuildContext context,
    required File file,
    required int index,
    required TipoMediaPreview tipo,
    required bool disabled,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.black12,
            child: _buildPreview(file: file, tipo: tipo),
          ),
        ),

        Positioned(left: 6, bottom: 6, child: _buildTypeBadge(tipo)),

        Positioned(
          top: 5,
          right: 5,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: disabled
                  ? null
                  : () {
                      context.read<IncidenteBloc>().add(
                        EliminarArchivoLocalEvent(index),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  color: disabled ? Colors.white54 : Colors.white,
                  size: 17,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview({required File file, required TipoMediaPreview tipo}) {
    switch (tipo) {
      case TipoMediaPreview.imagen:
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 36,
                color: Colors.black45,
              ),
            );
          },
        );

      case TipoMediaPreview.video:
        return const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            size: 46,
            color: Colors.black54,
          ),
        );

      case TipoMediaPreview.audio:
        return const Center(
          child: Icon(
            Icons.audio_file_rounded,
            size: 42,
            color: Colors.black54,
          ),
        );

      case TipoMediaPreview.otro:
        return const Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 40,
            color: Colors.black54,
          ),
        );
    }
  }

  Widget _buildTypeBadge(TipoMediaPreview tipo) {
    final IconData icon;
    final String label;

    switch (tipo) {
      case TipoMediaPreview.imagen:
        icon = Icons.image_outlined;
        label = 'Imagen';
        break;

      case TipoMediaPreview.video:
        icon = Icons.videocam_outlined;
        label = 'Video';
        break;

      case TipoMediaPreview.audio:
        icon = Icons.mic_none_rounded;
        label = 'Audio';
        break;

      case TipoMediaPreview.otro:
        icon = Icons.insert_drive_file_outlined;
        label = 'Archivo';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BOTÓN AGREGAR
  // ======================================================

  Widget _buildAddButton(BuildContext context, {required bool loading}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: loading
            ? null
            : () {
                _showOptions(context);
              },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 30),
                      SizedBox(height: 4),
                      Text('Agregar', style: TextStyle(fontSize: 11)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // INDICADOR DE GRABACIÓN
  // ======================================================

  Widget _buildRecordingIndicator({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onStop,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const _RecordingDot(),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.red, size: 21),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop_circle_outlined, size: 20),
            label: const Text('Detener'),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // OPCIONES
  // ======================================================

  Future<void> _showOptions(BuildContext context) async {
    final bloc = context.read<IncidenteBloc>();
    final state = bloc.state;

    if (state.loadingMedia || state.recordingVideo || state.recordingAudio) {
      return;
    }

    if (state.archivosLocales.length >= maxArchivos) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Solo se permiten hasta 5 archivos por incidencia.'),
          ),
        );

      return;
    }

    final action = await showModalBottomSheet<MediaOption>(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Agregar evidencia',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt_outlined),
                  ),
                  title: const Text('Tomar fotografía'),
                  subtitle: const Text('Usar la cámara del dispositivo'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, MediaOption.tomarFoto);
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.image_outlined),
                  ),
                  title: const Text('Seleccionar imagen'),
                  subtitle: const Text('Elegir una fotografía de la galería'),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      MediaOption.seleccionarImagen,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.video_library_outlined),
                  ),
                  title: const Text('Seleccionar video'),
                  subtitle: const Text('Elegir un video de la galería'),
                  onTap: () {
                    Navigator.pop(
                      bottomSheetContext,
                      MediaOption.seleccionarVideo,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.videocam_outlined),
                  ),
                  title: const Text('Grabar video'),
                  subtitle: const Text('Iniciar una nueva grabación'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext, MediaOption.grabarVideo);
                  },
                ),

                /*
                 * El audio se mantiene oculto mientras el backend
                 * no acepte archivos m4a, aac, mp3 o wav.
                 *
                 * Cuando lo habilites, puedes mostrar este ListTile:
                 *
                 * ListTile(
                 *   leading: const CircleAvatar(
                 *     child: Icon(Icons.mic_none_rounded),
                 *   ),
                 *   title: const Text('Grabar audio'),
                 *   onTap: () {
                 *     Navigator.pop(
                 *       bottomSheetContext,
                 *       MediaOption.grabarAudio,
                 *     );
                 *   },
                 * ),
                 */
              ],
            ),
          ),
        );
      },
    );

    if (action == null || !context.mounted) {
      return;
    }

    switch (action) {
      case MediaOption.tomarFoto:
        bloc.add(const TomarFotoEvent());
        break;

      case MediaOption.seleccionarImagen:
        bloc.add(const SeleccionarImagenEvent());
        break;

      case MediaOption.seleccionarVideo:
        bloc.add(const SeleccionarVideoEvent());
        break;

      case MediaOption.grabarVideo:
        bloc.add(const IniciarGrabacionVideoEvent());
        break;

      case MediaOption.grabarAudio:
        bloc.add(const IniciarGrabacionAudioEvent());
        break;
    }
  }

  // ======================================================
  // TIPO DE ARCHIVO
  // ======================================================

  TipoMediaPreview _obtenerTipoArchivo(File file) {
    final path = file.path.toLowerCase();

    if (_tieneExtension(path, const {
      '.jpg',
      '.jpeg',
      '.png',
      '.heic',
      '.heif',
    })) {
      return TipoMediaPreview.imagen;
    }

    if (_tieneExtension(path, const {'.mp4', '.mov'})) {
      return TipoMediaPreview.video;
    }

    if (_tieneExtension(path, const {'.m4a', '.aac', '.mp3', '.wav'})) {
      return TipoMediaPreview.audio;
    }

    return TipoMediaPreview.otro;
  }

  bool _tieneExtension(String filePath, Set<String> extensiones) {
    return extensiones.any(filePath.endsWith);
  }
}

// ======================================================
// ENUMS
// ======================================================

enum MediaOption {
  tomarFoto,
  seleccionarImagen,
  seleccionarVideo,
  grabarVideo,
  grabarAudio,
}

enum TipoMediaPreview { imagen, video, audio, otro }

// ======================================================
// INDICADOR ANIMADO SIMPLE
// ======================================================

class _RecordingDot extends StatefulWidget {
  const _RecordingDot();

  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
