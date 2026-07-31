import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/alertas_content.dart';

class AlertaPage extends StatefulWidget {
  const AlertaPage({super.key});

  @override
  State<AlertaPage> createState() => _AlertaPageState();
}

class _AlertaPageState extends State<AlertaPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AlertaBloc>()
        ..add(const GetMisAlertasEvent())
        ..add(const GetMisAlertasResumenEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _AlertaPageBody();
  }
}

class _AlertaPageBody extends StatelessWidget {
  const _AlertaPageBody();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ======================================================
        // RESPUESTAS DE ACCIONES
        // ======================================================
        BlocListener<AlertaBloc, AlertaState>(
          listenWhen: (previous, current) {
            return previous.actionStatus != current.actionStatus &&
                current.actionStatus != AlertaActionStatus.initial;
          },
          listener: (context, state) {
            if (state.actionStatus == AlertaActionStatus.success) {
              _mostrarMensaje(
                context,
                message:
                    state.actionMessage ?? 'Operación realizada correctamente.',
                isError: false,
              );

              context.read<AlertaBloc>().add(
                const ClearAlertaActionResponseEvent(),
              );

              return;
            }

            if (state.actionStatus == AlertaActionStatus.error) {
              _mostrarMensaje(
                context,
                message:
                    state.actionMessage ??
                    state.errorMessage ??
                    'No se pudo completar la operación.',
                isError: true,
              );

              context.read<AlertaBloc>().add(
                const ClearAlertaActionResponseEvent(),
              );
            }
          },
        ),

        // ======================================================
        // NUEVA ALERTA REMOTA
        // ======================================================
        BlocListener<AlertaBloc, AlertaState>(
          listenWhen: (previous, current) {
            return previous.ultimaAlertaRecibida !=
                    current.ultimaAlertaRecibida &&
                current.ultimaAlertaRecibida != null;
          },
          listener: (context, state) {
            final destinatario = state.ultimaAlertaRecibida;
            final alerta = destinatario?.alerta;

            if (destinatario == null) {
              return;
            }

            final titulo = alerta?.titulo ?? 'Nueva alerta';
            final descripcion =
                alerta?.descripcion ?? 'Has recibido una nueva alerta.';

            final messenger = ScaffoldMessenger.of(context);

            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 6),
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    children: [
                      const Icon(
                        Icons.notification_important_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  action: SnackBarAction(
                    label: 'VER',
                    textColor: Colors.white,
                    onPressed: () {
                      _abrirDetalle(context, destinatario);
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<AlertaBloc, AlertaState>(
        builder: (context, state) {
          return AlertaContent(
            state: state,
            onRefresh: () async {
              context.read<AlertaBloc>().add(const RefreshMisAlertasEvent());
            },
            onLoadMore: () {
              context.read<AlertaBloc>().add(const LoadMoreAlertasEvent());
            },
            onRetry: () {
              context.read<AlertaBloc>()
                ..add(
                  GetMisAlertasEvent(
                    page: 1,
                    limit: state.limit,
                    estado: state.filtroEstado,
                    tipo: state.filtroTipo,
                    prioridad: state.filtroPrioridad,
                    requiereConfirmacion: state.filtroRequiereConfirmacion,
                    reset: true,
                  ),
                )
                ..add(const GetMisAlertasResumenEvent());
            },
            onOpenFilters: () {
              _abrirFiltros(context, state);
            },
            onClearFilters: () {
              context.read<AlertaBloc>().add(
                const LimpiarFiltrosAlertasEvent(),
              );
            },
            onAlertaTap: (alerta) {
              _abrirDetalle(context, alerta);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ABRIR DETALLE
  // ============================================================

  void _abrirDetalle(
    BuildContext context,
    AlertaDestinatarioModel destinatario,
  ) {
    final alertaBloc = context.read<AlertaBloc>();

    alertaBloc.add(SeleccionarAlertaEvent(alerta: destinatario));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: alertaBloc,
          child: AlertaDetalleSheet(destinatario: destinatario),
        );
      },
    ).whenComplete(() {
      alertaBloc.add(const LimpiarAlertaSeleccionadaEvent());
    });
  }

  // ============================================================
  // ABRIR FILTROS
  // ============================================================

  void _abrirFiltros(BuildContext context, AlertaState state) {
    final alertaBloc = context.read<AlertaBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: alertaBloc,
          child: AlertaFiltrosSheet(
            estadoInicial: state.filtroEstado,
            tipoInicial: state.filtroTipo,
            prioridadInicial: state.filtroPrioridad,
            requiereConfirmacionInicial: state.filtroRequiereConfirmacion,
          ),
        );
      },
    );
  }

  // ============================================================
  // MENSAJES
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
