import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/incidencia/incidente_bloc.dart';
import '../blocs/incidencia/incidente_event.dart';
import '../blocs/incidencia/incidente_state.dart';

class MediaPreviewWidget extends StatelessWidget {
  const MediaPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        final archivos = state.archivos;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: archivos.length < 5
              ? archivos.length + 1
              : archivos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            // ➕ BOTÓN AGREGAR
            if (index == archivos.length && archivos.length < 5) {
              return _buildAddButton(context);
            }

            final file = archivos[index];
            final isVideo = file.path.endsWith('.mp4') ||
                file.path.endsWith('.mov');

            return _buildMediaItem(context, file, index, isVideo);
          },
        );
      },
    );
  }

  // =========================
  // ITEM MEDIA
  // =========================
  Widget _buildMediaItem(
    BuildContext context,
    File file,
    int index,
    bool isVideo,
  ) {
    return Stack(
      children: [
        // IMAGEN / VIDEO
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black12,
            child: isVideo
                ? const Center(
                    child: Icon(Icons.videocam, size: 40),
                  )
                : Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
        ),

        // ❌ ELIMINAR
        Positioned(
          top: 5,
          right: 5,
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
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // BOTÓN AGREGAR
  // =========================
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  // =========================
  // OPCIONES (WhatsApp style)
  // =========================
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tomar foto"),
                onTap: () {
                  Navigator.pop(context);
                  context.read<IncidenteBloc>().add(TomarFotoEvent());
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Grabar video"),
                onTap: () {
                  Navigator.pop(context);
                  // context.read<IncidenteBloc>().add(GrabarVideoEvent());
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Galería"),
                onTap: () {
                  Navigator.pop(context);
                  context.read<IncidenteBloc>().add(SeleccionarImagenEvent());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}