import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/incidencia/incidente_bloc.dart';
import '../blocs/incidencia/incidente_event.dart';

class IncidenteMediaActions extends StatelessWidget {

  const IncidenteMediaActions({super.key});

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        _button(
          context,
          icon: Icons.camera_alt,
          label: 'Foto',
          onTap: () {
            context.read<IncidenteBloc>()
                .add(TomarFotoEvent());
          },
        ),

        _button(
          context,
          icon: Icons.videocam,
          label: 'Video',
          onTap: () {
            context.read<IncidenteBloc>()
                .add(
                  IniciarGrabacionVideoEvent(),
                );
          },
        ),

        _button(
          context,
          icon: Icons.photo_library,
          label: 'Galería',
          onTap: () {
            context.read<IncidenteBloc>()
                .add(
                  SeleccionarImagenEvent(),
                );
          },
        ),
      ],
    );
  }

  Widget _button(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),

        child: ElevatedButton.icon(
          onPressed: onTap,

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xff1E293B),

            padding:
                const EdgeInsets.symmetric(
              vertical: 16,
            ),

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),

          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}