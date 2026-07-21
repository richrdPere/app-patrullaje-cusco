import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc's
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

// Enum
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

class MainPatrullajeButton extends StatelessWidget {
  final HomeState homeState;

  const MainPatrullajeButton({super.key, required this.homeState});

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    if (patrullaje == null) {
      return const SizedBox.shrink();
    }

    switch (homeState.status) {
      case PatrullajeStatus.asignado:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: homeState.isLoading
                ? null
                : () {
                    context.read<HomeBloc>().add(
                      AceptarPatrullaje(patrullaje.id),
                    );
                  },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aceptar patrullaje'),
          ),
        );

      case PatrullajeStatus.aceptando:
        return const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Aceptando patrullaje...'),
            ],
          ),
        );

      case PatrullajeStatus.enCurso:
        if (homeState.isLoading) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Finalizando patrullaje...'),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _confirmarFinalizacion(context, patrullaje.id);
            },
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('Finalizar patrullaje'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        );

      case PatrullajeStatus.sinAsignacion:
      case PatrullajeStatus.finalizado:
      case PatrullajeStatus.error:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmarFinalizacion(
    BuildContext context,
    int patrullajeId,
  ) async {
    final observacionController = TextEditingController();

    final resultado = await showDialog<_FinalizacionResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.stop_circle_outlined, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text('Finalizar patrullaje')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se finalizará el patrullaje actual y se generará el resumen del recorrido, incidencias y observaciones.',
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: observacionController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Observación final',
                    hintText:
                        'Ejemplo: Patrullaje finalizado sin novedades adicionales.',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La observación es opcional.',
                  style: Theme.of(
                    dialogContext,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final observacion = observacionController.text.trim();

                Navigator.pop(
                  dialogContext,
                  _FinalizacionResult(
                    observacionFinal: observacion.isEmpty ? null : observacion,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirmar'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
            ),
          ],
        );
      },
    );

    observacionController.dispose();

    if (!context.mounted || resultado == null) {
      return;
    }

    context.read<HomeBloc>().add(
      FinalizarPatrullaje(
        patrullajeId: patrullajeId,
        observacionFinal: resultado.observacionFinal,
      ),
    );
  }
}

class _FinalizacionResult {
  final String? observacionFinal;

  const _FinalizacionResult({this.observacionFinal});
}
