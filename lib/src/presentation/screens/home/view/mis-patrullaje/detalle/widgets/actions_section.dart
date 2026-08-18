import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';

class ActionsSection extends StatelessWidget {
  final PatrullajeListadoData patrullaje;

  const ActionsSection({super.key, required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              context.pushNamed(
                'historial_patrullaje',
                pathParameters: {'patrullajeId': patrullaje.id.toString()},
              );
            },
            icon: const Icon(Icons.history_rounded),
            label: const Text('Ver historial del patrullaje'),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: patrullaje.zonaId > 0
                ? () {
                    context.pushNamed(
                      'incidencias_contexto',
                      pathParameters: {
                        'patrullajeId': patrullaje.id.toString(),
                        'zonaId': patrullaje.zonaId.toString(),
                      },
                    );
                  }
                : null,
            icon: const Icon(Icons.report_outlined),
            label: const Text('Ver incidencias relacionadas'),
          ),
        ),
      ],
    );
  }
}
