import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/detalle%20alerta/alerta_detalle_content.dart';

class AlertaDetallePage extends StatefulWidget {
  final int alertaId;
  final MisAlertasData? alertaInicial;

  const AlertaDetallePage({
    super.key,
    required this.alertaId,
    this.alertaInicial,
  });

  @override
  State<AlertaDetallePage> createState() => _AlertaDetallePageState();
}

class _AlertaDetallePageState extends State<AlertaDetallePage> {
  late final AlertaBloc _alertaBloc;

  @override
  void initState() {
    super.initState();

    _alertaBloc = context.read<AlertaBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _cargarDetalle();
    });
  }

  void _cargarDetalle() {
    final alertaInicial = widget.alertaInicial;

    if (alertaInicial != null) {
      /*
       * SeleccionarAlertaEvent ya realiza:
       *
       * 1. Seleccionar la alerta.
       * 2. Obtener el detalle.
       * 3. Marcarla como leída si corresponde.
       */
      _alertaBloc.add(SeleccionarAlertaEvent(alerta: alertaInicial));

      return;
    }

    /*
     * Cuando se abre desde una notificación o enlace
     * y solamente conocemos alertaId.
     */
    _alertaBloc
      ..add(GetAlertaDetalleEvent(alertaId: widget.alertaId))
      ..add(MarcarAlertaLeidaEvent(alertaId: widget.alertaId));
  }

  @override
  void dispose() {
    if (!_alertaBloc.isClosed) {
      _alertaBloc.add(const LimpiarAlertaSeleccionadaEvent());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlertaBloc, AlertaState>(
      listenWhen: (previous, current) {
        final statusChanged = previous.actionStatus != current.actionStatus;

        final completed =
            current.actionStatus == AlertaActionStatus.success ||
            current.actionStatus == AlertaActionStatus.error;

        return statusChanged && completed;
      },
      listener: (context, state) {
        final isSuccess = state.actionStatus == AlertaActionStatus.success;

        /*
         * No mostramos un mensaje de éxito al marcar
         * automáticamente la alerta como leída.
         */
        final mostrarExito =
            isSuccess && state.actionType != AlertaActionType.marcarLeida;

        final mostrarError = !isSuccess;

        if (mostrarExito || mostrarError) {
          _mostrarMensaje(
            context,
            message:
                state.actionMessage ??
                (isSuccess
                    ? 'Operación realizada correctamente.'
                    : 'No se pudo completar la operación.'),
            isError: !isSuccess,
          );
        }

        /*
         * No limpiamos mientras otra operación esté
         * ejecutándose.
         */
        context.read<AlertaBloc>().add(const ClearAlertaActionResponseEvent());
      },
      child: BlocBuilder<AlertaBloc, AlertaState>(
        builder: (context, state) {
          return AlertaDetalleContent(
            state: state,
            alertaInicial: widget.alertaInicial,
            onRetry: () {
              context.read<AlertaBloc>().add(
                GetAlertaDetalleEvent(alertaId: widget.alertaId),
              );
            },
            onAceptar: () {
              _mostrarResponderDialog(context, respuesta: 'ACEPTADA');
            },
            onRechazar: () {
              _mostrarResponderDialog(context, respuesta: 'RECHAZADA');
            },
            onMarcarAtendida: () {
              _mostrarAtendidaDialog(context);
            },
            onCancelar: () {
              _confirmarCancelacion(context);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // RESPONDER ALERTA
  // ============================================================

  Future<void> _mostrarResponderDialog(
    BuildContext context, {
    required String respuesta,
  }) async {
    final observacionController = TextEditingController();

    final esAceptada = respuesta == 'ACEPTADA';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(esAceptada ? 'Aceptar alerta' : 'Rechazar alerta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esAceptada
                    ? '¿Confirmas que atenderás esta alerta?'
                    : 'Indica por qué no puedes atender esta alerta.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacionController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: esAceptada
                      ? 'Observación opcional'
                      : 'Observación',
                  hintText: 'Escribe una observación...',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: !esAceptada
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.error,
                    )
                  : null,
              child: Text(esAceptada ? 'Aceptar' : 'Rechazar'),
            ),
          ],
        );
      },
    );

    final observacion = observacionController.text.trim();

    observacionController.dispose();

    if (confirmar != true || !mounted) {
      return;
    }

    // ignore: use_build_context_synchronously
    context.read<AlertaBloc>().add(
      ResponderAlertaEvent(
        alertaId: widget.alertaId,
        respuesta: respuesta,
        observacion: observacion.isEmpty ? null : observacion,
      ),
    );
  }

  // ============================================================
  // MARCAR COMO ATENDIDA
  // ============================================================

  Future<void> _mostrarAtendidaDialog(BuildContext context) async {
    final observacionController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Marcar como atendida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Confirma que la alerta ya fue atendida.'),
              const SizedBox(height: 16),
              TextField(
                controller: observacionController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Observación opcional',
                  hintText: 'Describe la atención realizada...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    final observacion = observacionController.text.trim();

    observacionController.dispose();

    if (confirmar != true || !mounted) {
      return;
    }

    context.read<AlertaBloc>().add(
      MarcarAlertaAtendidaEvent(
        alertaId: widget.alertaId,
        observacion: observacion.isEmpty ? null : observacion,
      ),
    );
  }

  // ============================================================
  // CANCELAR ALERTA
  // ============================================================

  Future<void> _confirmarCancelacion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(dialogContext).colorScheme.error,
          ),
          title: const Text('Cancelar alerta'),
          content: const Text(
            'La alerta dejará de estar activa. '
            'Esta acción no se puede revertir.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Cancelar alerta'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    context.read<AlertaBloc>().add(
      CancelarAlertaEvent(alertaId: widget.alertaId),
    );
  }

  // ============================================================
  // MENSAJE
  // ============================================================

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
