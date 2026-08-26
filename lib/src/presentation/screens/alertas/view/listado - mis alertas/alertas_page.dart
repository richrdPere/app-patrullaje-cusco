import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/listado%20-%20mis%20alertas/alertas_content.dart';

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
        // 1. RESPUESTAS DE ACCIONES
        // ======================================================
        BlocListener<AlertaBloc, AlertaState>(
          listenWhen: (previous, current) {
            final statusChanged = previous.actionStatus != current.actionStatus;

            final completed =
                current.actionStatus == AlertaActionStatus.success ||
                current.actionStatus == AlertaActionStatus.error;

            return statusChanged && completed;
          },
          listener: (context, state) {
            final isSuccess = state.actionStatus == AlertaActionStatus.success;

            final message =
                state.actionMessage ??
                (isSuccess
                    ? 'Operación realizada correctamente.'
                    : 'No se pudo completar la operación.');

            _mostrarMensaje(context, message: message, isError: !isSuccess);

            context.read<AlertaBloc>().add(
              const ClearAlertaActionResponseEvent(),
            );
          },
        ),

        // ======================================================
        // 2. NUEVA ALERTA REMOTA
        // ======================================================
        BlocListener<AlertaBloc, AlertaState>(
          listenWhen: (previous, current) {
            return previous.ultimaAlertaRecibida !=
                    current.ultimaAlertaRecibida &&
                current.ultimaAlertaRecibida != null;
          },
          listener: (context, state) {
            final alertaRecibida = state.ultimaAlertaRecibida;

            if (alertaRecibida == null) {
              return;
            }

            final alerta = alertaRecibida.alerta;

            final titulo = alerta.titulo.isNotEmpty
                ? alerta.titulo
                : 'Nueva alerta';

            final descripcion = alerta.descripcion.isNotEmpty
                ? alerta.descripcion
                : 'Has recibido una nueva alerta.';

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
                      // _abrirDetalle(context, alertaRecibida);
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

            // ==================================================
            // REFRESCAR
            // ==================================================
            onRefresh: () async {
              context.read<AlertaBloc>().add(const RefreshMisAlertasEvent());
            },

            // ==================================================
            // CARGAR SIGUIENTE PÁGINA
            // ==================================================
            onLoadMore: () {
              context.read<AlertaBloc>().add(const LoadMoreAlertasEvent());
            },

            // ==================================================
            // REINTENTAR
            // ==================================================
            onRetry: () {
              context.read<AlertaBloc>()
                ..add(
                  GetMisAlertasEvent(
                    page: 1,
                    limit: state.limit,
                    estado: state.filtroEstado,
                    tipo: state.filtroTipo,
                    prioridad: state.filtroPrioridad,
                    noLeidas: state.filtroNoLeidas,
                    reset: true,
                  ),
                )
                ..add(const GetMisAlertasResumenEvent());
            },

            // ==================================================
            // ABRIR FILTROS
            // ==================================================
            onOpenFilters: () {
              // _abrirFiltros(context, state);
            },

            // ==================================================
            // LIMPIAR FILTROS
            // ==================================================
            onClearFilters: () {
              context.read<AlertaBloc>().add(
                const LimpiarFiltrosAlertasEvent(),
              );
            },

            // ==================================================
            // SELECCIONAR ALERTA
            // ==================================================
            onAlertaTap: (alerta) {
              // _abrirDetalle(context, alerta);
              context.pushNamed(
                'alerta_detalle',
                pathParameters: {'alertaId': alerta.alertaId.toString()},
                extra: alerta,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // ABRIR DETALLE
  // ============================================================

  // void _abrirDetalle(BuildContext context, MisAlertasData alerta) {
  //   final alertaBloc = context.read<AlertaBloc>();

  //   /*
  //    * SeleccionarAlertaEvent:
  //    *
  //    * 1. Guarda la alerta del listado.
  //    * 2. Solicita el detalle al backend.
  //    * 3. La marca como leída cuando corresponda.
  //    */
  //   alertaBloc.add(SeleccionarAlertaEvent(alerta: alerta));

  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return BlocProvider.value(
  //         value: alertaBloc,
  //         child: AlertaDetalleSheet(alertaInicial: alerta),
  //       );
  //     },
  //   ).whenComplete(() {
  //     if (!alertaBloc.isClosed) {
  //       alertaBloc.add(const LimpiarAlertaSeleccionadaEvent());
  //     }
  //   });
  // }

  // ============================================================
  // ABRIR FILTROS
  // ============================================================
  // void _abrirFiltros(BuildContext context, AlertaState state) {
  //   final alertaBloc = context.read<AlertaBloc>();

  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return BlocProvider.value(
  //         value: alertaBloc,
  //         child: AlertaFiltrosSheet(
  //           estadoInicial: state.filtroEstado,
  //           tipoInicial: state.filtroTipo,
  //           prioridadInicial: state.filtroPrioridad,
  //           noLeidasInicial: state.filtroNoLeidas,
  //         ),
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // MOSTRAR MENSAJE
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
