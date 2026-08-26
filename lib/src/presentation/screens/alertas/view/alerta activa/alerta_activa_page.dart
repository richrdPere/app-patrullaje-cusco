import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/alerta%20activa/alerta_activa_content.dart';

class AlertaActivaPage extends StatefulWidget {
  const AlertaActivaPage({super.key});

  @override
  State<AlertaActivaPage> createState() => _AlertaActivaPageState();
}

class _AlertaActivaPageState extends State<AlertaActivaPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AlertaBloc>().add(const GetAlertaActivaEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlertaBloc, AlertaState>(
      listenWhen: (previous, current) {
        final esCancelacion =
            current.actionType == AlertaActionType.cancelarAlerta;

        final cambioEstado = previous.actionStatus != current.actionStatus;

        final finalizada =
            current.actionStatus == AlertaActionStatus.success ||
            current.actionStatus == AlertaActionStatus.error;

        return esCancelacion && cambioEstado && finalizada;
      },
      listener: (context, state) {
        final success = state.actionStatus == AlertaActionStatus.success;

        _mostrarMensaje(
          context,
          message:
              state.actionMessage ??
              (success
                  ? 'La alerta fue cancelada correctamente.'
                  : 'No se pudo cancelar la alerta.'),
          isError: !success,
        );

        context.read<AlertaBloc>().add(const ClearAlertaActionResponseEvent());
      },
      child: BlocBuilder<AlertaBloc, AlertaState>(
        builder: (context, state) {
          return AlertaActivaContent(
            state: state,
            onRefresh: () async {
              context.read<AlertaBloc>().add(const GetAlertaActivaEvent());
            },
            onRetry: () {
              context.read<AlertaBloc>().add(const GetAlertaActivaEvent());
            },
            onOpenDetail: (alertaId) {
              context.pushNamed(
                'alerta_detalle',
                pathParameters: {'alertaId': alertaId.toString()},
              );
            },
            onCancel: (alertaId) {
              _confirmarCancelacion(context, alertaId);
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmarCancelacion(BuildContext context, int alertaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Theme.of(dialogContext).colorScheme.error,
          ),
          title: const Text('Cancelar alerta', textAlign: TextAlign.center),
          content: const Text(
            'La alerta dejará de estar activa y la central '
            'será informada de la cancelación.\n\n'
            'Esta acción no se puede revertir.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Volver'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar alerta'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    context.read<AlertaBloc>().add(CancelarAlertaEvent(alertaId: alertaId));
  }

  void _mostrarMensaje(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? colorScheme.error : Colors.green.shade700,
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
