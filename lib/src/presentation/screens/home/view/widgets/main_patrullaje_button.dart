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
            onPressed: () {
              context.read<HomeBloc>().add(AceptarPatrullaje(patrullaje.id));
            },
            icon: const Icon(Icons.check),
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _confirmarFinalizacion(context, patrullaje.id);
            },
            icon: const Icon(Icons.stop),
            label: const Text('Finalizar patrullaje'),
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar patrullaje'),
          content: const Text(
            '¿Está seguro de finalizar el patrullaje actual?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    context.read<HomeBloc>().add(FinalizarPatrullaje(patrullajeId));
  }
}
