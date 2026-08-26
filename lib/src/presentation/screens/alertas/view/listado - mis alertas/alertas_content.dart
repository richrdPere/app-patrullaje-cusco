import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// State
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

class AlertaContent extends StatelessWidget {
  final AlertaState state;

  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearFilters;
  final ValueChanged<MisAlertasData> onAlertaTap;

  const AlertaContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    required this.onOpenFilters,
    required this.onClearFilters,
    required this.onAlertaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            tooltip: 'Filtros',
            onPressed: onOpenFilters,
            icon: Badge(
              isLabelVisible: state.tieneFiltros,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: state.isLoading ? null : onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    // ==========================================================
    // CARGA INICIAL
    // ==========================================================

    if (state.isLoading && state.alertas.isEmpty) {
      return const _AlertaInitialLoading();
    }

    // ==========================================================
    // ERROR INICIAL
    // ==========================================================

    if (state.listStatus == AlertaListStatus.error && state.alertas.isEmpty) {
      return _AlertaErrorView(
        message:
            state.listErrorMessage ?? 'No se pudieron obtener las alertas.',
        onRetry: onRetry,
      );
    }

    // ==========================================================
    // LISTADO
    // ==========================================================

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 250 && state.puedeCargarMas) {
            onLoadMore();
          }

          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Resumen
            SliverToBoxAdapter(child: _AlertaResumenSection(state: state)),

            // Error no bloqueante
            if (state.listErrorMessage != null && state.alertas.isNotEmpty)
              SliverToBoxAdapter(
                child: _AlertaInlineError(
                  message: state.listErrorMessage!,
                  onRetry: onRetry,
                ),
              ),

            // Filtros activos
            if (state.tieneFiltros)
              SliverToBoxAdapter(
                child: _FiltrosActivosSection(
                  state: state,
                  onClear: onClearFilters,
                ),
              ),

            // Vacío
            if (state.alertas.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _AlertaEmptyView(
                  tieneFiltros: state.tieneFiltros,
                  onClearFilters: onClearFilters,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: state.alertas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alerta = state.alertas[index];

                    return _AlertaCard(
                      alertaUsuario: alerta,
                      onTap: () {
                        onAlertaTap(alerta);
                      },
                    );
                  },
                ),
              ),

            // Cargando siguiente página
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Fin del listado
            if (!state.hasNextPage &&
                state.alertas.isNotEmpty &&
                !state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 24),
                  child: Center(
                    child: Text(
                      'No existen más alertas.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// RESUMEN
// ==========================================================================

class _AlertaResumenSection extends StatelessWidget {
  final AlertaState state;

  const _AlertaResumenSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final resumen = state.resumen;

    if (state.resumenStatus == AlertaResumenStatus.loading && resumen == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: SizedBox(
          height: 94,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final total = resumen?.total ?? state.total;

    final noLeidas = resumen?.noLeidas ?? state.alertasNoLeidas;

    final criticas =
        resumen?.prioridades.criticas ??
        state.alertas.where((item) {
          return item.alerta.prioridad.toUpperCase() == 'CRITICA';
        }).length;

    final requierenRespuesta =
        resumen?.requierenConfirmacion ??
        state.totalRequierenRespuestaEnListado;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resumen operativo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.resumenStatus == AlertaResumenStatus.loading &&
                  resumen != null)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.15,
            children: [
              _ResumenCard(
                title: 'Total',
                value: total,
                icon: Icons.notifications_active_outlined,
              ),
              _ResumenCard(
                title: 'No leídas',
                value: noLeidas,
                icon: Icons.mark_email_unread_outlined,
              ),
              _ResumenCard(
                title: 'Críticas',
                value: criticas,
                icon: Icons.warning_amber_rounded,
              ),
              _ResumenCard(
                title: 'Por responder',
                value: requierenRespuesta,
                icon: Icons.question_answer_outlined,
              ),
            ],
          ),
          if (state.resumenStatus == AlertaResumenStatus.error &&
              state.resumenErrorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.resumenErrorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _ResumenCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// FILTROS ACTIVOS
// ==========================================================================

class _FiltrosActivosSection extends StatelessWidget {
  final AlertaState state;
  final VoidCallback onClear;

  const _FiltrosActivosSection({required this.state, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (state.filtroEstado != null) {
      chips.add(
        Chip(label: Text('Estado: ${_formatearTexto(state.filtroEstado!)}')),
      );
    }

    if (state.filtroTipo != null) {
      chips.add(
        Chip(label: Text('Tipo: ${_formatearTexto(state.filtroTipo!)}')),
      );
    }

    if (state.filtroPrioridad != null) {
      chips.add(
        Chip(
          label: Text('Prioridad: ${_formatearTexto(state.filtroPrioridad!)}'),
        ),
      );
    }

    if (state.filtroNoLeidas != null) {
      chips.add(
        Chip(
          label: Text(
            state.filtroNoLeidas! ? 'Solo no leídas' : 'Incluir leídas',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filtros activos',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
          Wrap(spacing: 8, runSpacing: 4, children: chips),
        ],
      ),
    );
  }
}

// ==========================================================================
// TARJETA DE ALERTA
// ==========================================================================

class _AlertaCard extends StatelessWidget {
  final MisAlertasData alertaUsuario;
  final VoidCallback onTap;

  const _AlertaCard({required this.alertaUsuario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final alerta = alertaUsuario.alerta;
    final colorScheme = Theme.of(context).colorScheme;

    final prioridadColor = _getPrioridadColor(context, alerta.prioridad);

    final noLeida =
        alertaUsuario.fechaLeida == null &&
        alertaUsuario.estado.toUpperCase() != 'LEIDA';

    final titulo = alerta.titulo.isNotEmpty ? alerta.titulo : 'Alerta';

    final descripcion = alerta.descripcion.isNotEmpty
        ? alerta.descripcion
        : 'No existe una descripción disponible.';

    return Material(
      color: noLeida
          ? colorScheme.primaryContainer.withValues(alpha: 0.20)
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: noLeida
                  ? colorScheme.primary.withValues(alpha: 0.35)
                  : colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AlertaIcon(tipo: alerta.tipo, prioridadColor: prioridadColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: noLeida
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (noLeida) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniLabel(
                          text: _formatearTexto(
                            alerta.prioridad.isNotEmpty
                                ? alerta.prioridad
                                : 'MEDIA',
                          ),
                          icon: Icons.priority_high_rounded,
                          color: prioridadColor,
                        ),
                        _MiniLabel(
                          text: _formatearTexto(alertaUsuario.estado),
                          icon: _getEstadoDestinatarioIcon(
                            alertaUsuario.estado,
                          ),
                          color: _getEstadoDestinatarioColor(
                            context,
                            alertaUsuario.estado,
                          ),
                        ),
                        if (alerta.requiereConfirmacion)
                          const _MiniLabel(
                            text: 'Requiere respuesta',
                            icon: Icons.question_answer_outlined,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _formatearFecha(
                              alerta.createdAt ?? alertaUsuario.createdAt,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertaIcon extends StatelessWidget {
  final String? tipo;
  final Color prioridadColor;

  const _AlertaIcon({required this.tipo, required this.prioridadColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: prioridadColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_getTipoIcon(tipo), color: prioridadColor),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _MiniLabel({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// ERROR NO BLOQUEANTE
// ==========================================================================

class _AlertaInlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AlertaInlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
              IconButton(
                tooltip: 'Reintentar',
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// LOADING INICIAL
// ==========================================================================

class _AlertaInitialLoading extends StatelessWidget {
  const _AlertaInitialLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ==========================================================================
// ERROR
// ==========================================================================

class _AlertaErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AlertaErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar las alertas',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// VACÍO
// ==========================================================================

class _AlertaEmptyView extends StatelessWidget {
  final bool tieneFiltros;
  final VoidCallback onClearFilters;

  const _AlertaEmptyView({
    required this.tieneFiltros,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tieneFiltros
                  ? Icons.filter_alt_off_outlined
                  : Icons.notifications_none_rounded,
              size: 72,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 16),
            Text(
              tieneFiltros
                  ? 'No existen alertas con estos filtros'
                  : 'No tienes alertas',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tieneFiltros
                  ? 'Prueba cambiando o eliminando los filtros aplicados.'
                  : 'Las nuevas alertas aparecerán en esta sección.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (tieneFiltros) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// HELPERS
// ==========================================================================

String _formatearTexto(String value) {
  final normalized = value.trim().replaceAll('_', ' ').toLowerCase();

  if (normalized.isEmpty) {
    return '';
  }

  return normalized
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _formatearFecha(DateTime? date) {
  if (date == null) {
    return 'Fecha no disponible';
  }

  return DateFormat("dd/MM/yyyy · HH:mm", 'es_PE').format(date.toLocal());
}

Color _getPrioridadColor(BuildContext context, String? prioridad) {
  switch (prioridad?.trim().toUpperCase()) {
    case 'CRITICA':
      return Colors.red.shade700;

    case 'ALTA':
      return Colors.orange.shade700;

    case 'MEDIA':
      return Colors.amber.shade800;

    case 'BAJA':
      return Colors.green.shade700;

    default:
      return Theme.of(context).colorScheme.primary;
  }
}

IconData _getTipoIcon(String? tipo) {
  switch (tipo?.trim().toUpperCase()) {
    case 'PANICO':
    case 'SOS':
      return Icons.sos_rounded;

    case 'EMERGENCIA':
      return Icons.emergency_rounded;

    case 'INCIDENCIA':
      return Icons.report_problem_outlined;

    case 'INFORMATIVA':
      return Icons.info_outline_rounded;

    default:
      return Icons.notifications_active_outlined;
  }
}

IconData _getEstadoDestinatarioIcon(String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Icons.schedule_rounded;

    case 'RECIBIDA':
      return Icons.notifications_active_outlined;

    case 'LEIDA':
      return Icons.mark_email_read_outlined;

    case 'ACEPTADA':
      return Icons.check_circle_outline_rounded;

    case 'RECHAZADA':
      return Icons.cancel_outlined;

    case 'ATENDIDA':
      return Icons.task_alt_rounded;

    default:
      return Icons.info_outline_rounded;
  }
}

Color _getEstadoDestinatarioColor(BuildContext context, String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Colors.orange.shade700;

    case 'RECIBIDA':
      return Colors.blue.shade700;

    case 'LEIDA':
      return Colors.blueGrey.shade600;

    case 'ACEPTADA':
      return Colors.green.shade700;

    case 'RECHAZADA':
      return Colors.red.shade700;

    case 'ATENDIDA':
      return Colors.teal.shade700;

    default:
      return Theme.of(context).colorScheme.primary;
  }
}

// // ==========================================================================
// // DETALLE DE ALERTA
// // ==========================================================================

// class AlertaDetalleSheet extends StatelessWidget {
//   final MisAlertasData destinatario;

//   const AlertaDetalleSheet({super.key, required this.destinatario});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AlertaBloc, AlertaState>(
//       builder: (context, state) {
//         final actualizado = state.alertas.firstWhere(
//           (item) => item.alertaId == destinatario.alertaId,
//           orElse: () => destinatario,
//         );

//         final alerta = actualizado.alerta ?? destinatario.alerta;

//         return Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.sizeOf(context).height * 0.92,
//           ),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 width: 42,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade400,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _DetalleHeader(alerta: alerta, destinatario: actualizado),
//                       const SizedBox(height: 20),

//                       _DetalleSection(
//                         title: 'Descripción',
//                         icon: Icons.description_outlined,
//                         child: Text(
//                           alerta?.descripcion ??
//                               'No existe una descripción disponible.',
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       _DetalleSection(
//                         title: 'Información',
//                         icon: Icons.info_outline_rounded,
//                         child: Column(
//                           children: [
//                             _DetalleRow(
//                               label: 'Tipo',
//                               value: _formatearTexto(
//                                 alerta?.tipo ?? 'INFORMATIVA',
//                               ),
//                             ),
//                             _DetalleRow(
//                               label: 'Prioridad',
//                               value: _formatearTexto(
//                                 alerta?.prioridad ?? 'MEDIA',
//                               ),
//                             ),
//                             _DetalleRow(
//                               label: 'Estado de alerta',
//                               value: _formatearTexto(
//                                 alerta?.estado ?? 'PENDIENTE',
//                               ),
//                             ),
//                             _DetalleRow(
//                               label: 'Estado para mí',
//                               value: _formatearTexto(actualizado.estado),
//                             ),
//                             _DetalleRow(
//                               label: 'Fecha',
//                               value: _formatearFecha(
//                                 alerta?.createdAt ?? actualizado.createdAt,
//                               ),
//                             ),
//                             if (alerta?.fechaExpiracion != null)
//                               _DetalleRow(
//                                 label: 'Expira',
//                                 value: _formatearFecha(alerta?.fechaExpiracion),
//                               ),
//                           ],
//                         ),
//                       ),

//                       if (alerta?.tieneUbicacion == true) ...[
//                         const SizedBox(height: 14),
//                         _DetalleSection(
//                           title: 'Ubicación',
//                           icon: Icons.location_on_outlined,
//                           child: Column(
//                             children: [
//                               _DetalleRow(
//                                 label: 'Latitud',
//                                 value: alerta!.latitud.toString(),
//                               ),
//                               _DetalleRow(
//                                 label: 'Longitud',
//                                 value: alerta.longitud.toString(),
//                               ),
//                               const SizedBox(height: 8),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: OutlinedButton.icon(
//                                   onPressed: () {
//                                     /*
//                                      * Aquí posteriormente puedes navegar
//                                      * al mapa usando latitud y longitud.
//                                      */
//                                   },
//                                   icon: const Icon(Icons.map_outlined),
//                                   label: const Text('Ver ubicación en el mapa'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],

//                       if (actualizado.observacion != null &&
//                           actualizado.observacion!.trim().isNotEmpty) ...[
//                         const SizedBox(height: 14),
//                         _DetalleSection(
//                           title: 'Observación',
//                           icon: Icons.comment_outlined,
//                           child: Text(actualizado.observacion!),
//                         ),
//                       ],

//                       const SizedBox(height: 22),

//                       _AlertaActionButtons(
//                         destinatario: actualizado,
//                         actionStatus: state.actionStatus,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _DetalleHeader extends StatelessWidget {
//   final AlertaModel? alerta;
//   final AlertaDestinatarioModel destinatario;

//   const _DetalleHeader({required this.alerta, required this.destinatario});

//   @override
//   Widget build(BuildContext context) {
//     final prioridadColor = _getPrioridadColor(context, alerta?.prioridad);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 54,
//           height: 54,
//           decoration: BoxDecoration(
//             color: prioridadColor.withValues(alpha: 0.15),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(
//             _getTipoIcon(alerta?.tipo),
//             color: prioridadColor,
//             size: 28,
//           ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 alerta?.titulo ?? 'Alerta',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 6,
//                 children: [
//                   _MiniLabel(
//                     text: _formatearTexto(alerta?.prioridad ?? 'MEDIA'),
//                     icon: Icons.priority_high_rounded,
//                     color: prioridadColor,
//                   ),
//                   _MiniLabel(
//                     text: _formatearTexto(destinatario.estado),
//                     icon: _getEstadoDestinatarioIcon(destinatario.estado),
//                     color: _getEstadoDestinatarioColor(
//                       context,
//                       destinatario.estado,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           tooltip: 'Cerrar',
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.close_rounded),
//         ),
//       ],
//     );
//   }
// }

// class _DetalleSection extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Widget child;

//   const _DetalleSection({
//     required this.title,
//     required this.icon,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainerLow,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: colorScheme.outlineVariant.withValues(alpha: 0.55),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: colorScheme.primary),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _DetalleRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetalleRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 125,
//             child: Text(
//               label,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               textAlign: TextAlign.end,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ==========================================================================
// // ACCIONES DEL DETALLE
// // ==========================================================================

// class _AlertaActionButtons extends StatelessWidget {
//   final AlertaDestinatarioModel destinatario;
//   final AlertaActionStatus actionStatus;

//   const _AlertaActionButtons({
//     required this.destinatario,
//     required this.actionStatus,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final alerta = destinatario.alerta;
//     final isLoading = actionStatus == AlertaActionStatus.loading;

//     final puedeResponder =
//         alerta?.requiereConfirmacion == true &&
//         !destinatario.fueRespondida &&
//         !destinatario.fueAtendida;

//     final puedeAtender = destinatario.fueAceptada && !destinatario.fueAtendida;

//     if (!puedeResponder && !puedeAtender) {
//       return _EstadoFinalInfo(destinatario: destinatario);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (puedeResponder) ...[
//           Text(
//             '¿Aceptas atender esta alerta?',
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           _mostrarDialogoRespuesta(
//                             context,
//                             destinatario: destinatario,
//                             respuesta: 'RECHAZADA',
//                           );
//                         },
//                   icon: const Icon(Icons.close_rounded),
//                   label: const Text('Rechazar'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: FilledButton.icon(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           _mostrarDialogoRespuesta(
//                             context,
//                             destinatario: destinatario,
//                             respuesta: 'ACEPTADA',
//                           );
//                         },
//                   icon: const Icon(Icons.check_rounded),
//                   label: const Text('Aceptar'),
//                 ),
//               ),
//             ],
//           ),
//         ],

//         if (puedeAtender) ...[
//           if (puedeResponder) const SizedBox(height: 14),
//           FilledButton.icon(
//             onPressed: isLoading
//                 ? null
//                 : () {
//                     _mostrarDialogoAtendida(context, destinatario);
//                   },
//             icon: isLoading
//                 ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.task_alt_rounded),
//             label: const Text('Marcar como atendida'),
//           ),
//         ],
//       ],
//     );
//   }

//   void _mostrarDialogoRespuesta(
//     BuildContext context, {
//     required AlertaDestinatarioModel destinatario,
//     required String respuesta,
//   }) {
//     final controller = TextEditingController();
//     final alertaBloc = context.read<AlertaBloc>();

//     showDialog<void>(
//       context: context,
//       builder: (dialogContext) {
//         final esAceptada = respuesta == 'ACEPTADA';

//         return AlertDialog(
//           title: Text(esAceptada ? 'Aceptar alerta' : 'Rechazar alerta'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 esAceptada
//                     ? 'Confirma que atenderás esta alerta.'
//                     : 'Indica el motivo por el que rechazas la alerta.',
//               ),
//               const SizedBox(height: 14),
//               TextField(
//                 controller: controller,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: esAceptada
//                       ? 'Observación opcional'
//                       : 'Motivo del rechazo',
//                   alignLabelWithHint: true,
//                   border: const OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: const Text('Cancelar'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 final observacion = controller.text.trim();

//                 if (!esAceptada && observacion.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Debes indicar el motivo del rechazo.'),
//                     ),
//                   );

//                   return;
//                 }

//                 Navigator.pop(dialogContext);

//                 alertaBloc.add(
//                   ResponderAlertaEvent(
//                     alertaId: destinatario.alertaId,
//                     respuesta: respuesta,
//                     observacion: observacion.isEmpty ? null : observacion,
//                   ),
//                 );
//               },
//               child: Text(esAceptada ? 'Aceptar' : 'Rechazar'),
//             ),
//           ],
//         );
//       },
//     ).whenComplete(controller.dispose);
//   }

//   void _mostrarDialogoAtendida(
//     BuildContext context,
//     AlertaDestinatarioModel destinatario,
//   ) {
//     final controller = TextEditingController();
//     final alertaBloc = context.read<AlertaBloc>();

//     showDialog<void>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Finalizar atención'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Confirma que la alerta fue atendida.'),
//               const SizedBox(height: 14),
//               TextField(
//                 controller: controller,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Observación de atención',
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: const Text('Cancelar'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 final observacion = controller.text.trim();

//                 Navigator.pop(dialogContext);

//                 alertaBloc.add(
//                   MarcarAlertaAtendidaEvent(
//                     alertaId: destinatario.alertaId,
//                     observacion: observacion.isEmpty ? null : observacion,
//                   ),
//                 );
//               },
//               child: const Text('Confirmar'),
//             ),
//           ],
//         );
//       },
//     ).whenComplete(controller.dispose);
//   }
// }

// class _EstadoFinalInfo extends StatelessWidget {
//   final AlertaDestinatarioModel destinatario;

//   const _EstadoFinalInfo({required this.destinatario});

//   @override
//   Widget build(BuildContext context) {
//     late final String message;
//     late final IconData icon;

//     switch (destinatario.estado) {
//       case 'ATENDIDA':
//         message = 'Esta alerta ya fue atendida.';
//         icon = Icons.task_alt_rounded;
//         break;

//       case 'RECHAZADA':
//         message = 'Esta alerta fue rechazada.';
//         icon = Icons.cancel_outlined;
//         break;

//       case 'ACEPTADA':
//         message = 'La alerta fue aceptada y está pendiente de atención.';
//         icon = Icons.check_circle_outline_rounded;
//         break;

//       default:
//         message = 'No existen acciones disponibles para esta alerta.';
//         icon = Icons.info_outline_rounded;
//     }

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Icon(icon),
//           const SizedBox(width: 10),
//           Expanded(child: Text(message)),
//         ],
//       ),
//     );
//   }
// }

// // ==========================================================================
// // FILTROS
// // ==========================================================================

// class AlertaFiltrosSheet extends StatefulWidget {
//   final String? estadoInicial;
//   final String? tipoInicial;
//   final String? prioridadInicial;
//   final bool? requiereConfirmacionInicial;

//   const AlertaFiltrosSheet({
//     super.key,
//     this.estadoInicial,
//     this.tipoInicial,
//     this.prioridadInicial,
//     this.requiereConfirmacionInicial,
//   });

//   @override
//   State<AlertaFiltrosSheet> createState() => _AlertaFiltrosSheetState();
// }

// class _AlertaFiltrosSheetState extends State<AlertaFiltrosSheet> {
//   String? _estado;
//   String? _tipo;
//   String? _prioridad;
//   bool? _requiereConfirmacion;

//   static const List<String> _estados = [
//     'PENDIENTE',
//     'RECIBIDA',
//     'LEIDA',
//     'ACEPTADA',
//     'RECHAZADA',
//     'ATENDIDA',
//   ];

//   static const List<String> _tipos = [
//     'PANICO',
//     'INCIDENCIA',
//     'EMERGENCIA',
//     'SOS',
//     'INFORMATIVA',
//     'PREVENTIVA',
//     'CAMBIO_RUTA',
//     'APOYO_REQUERIDO',
//     'MENSAJE_CENTRAL',
//   ];

//   static const List<String> _prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];

//   @override
//   void initState() {
//     super.initState();

//     _estado = widget.estadoInicial;
//     _tipo = widget.tipoInicial;
//     _prioridad = widget.prioridadInicial;
//     _requiereConfirmacion = widget.requiereConfirmacionInicial;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         20,
//         12,
//         20,
//         MediaQuery.viewInsetsOf(context).bottom + 24,
//       ),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 42,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade400,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Filtrar alertas',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.close_rounded),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 18),

//             DropdownButtonFormField<String>(
//               initialValue: _estado,
//               decoration: const InputDecoration(
//                 labelText: 'Estado',
//                 prefixIcon: Icon(Icons.flag_outlined),
//                 border: OutlineInputBorder(),
//               ),
//               items: _estados
//                   .map(
//                     (item) => DropdownMenuItem(
//                       value: item,
//                       child: Text(_formatearTexto(item)),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _estado = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 14),

//             DropdownButtonFormField<String>(
//               initialValue: _tipo,
//               isExpanded: true,
//               decoration: const InputDecoration(
//                 labelText: 'Tipo',
//                 prefixIcon: Icon(Icons.category_outlined),
//                 border: OutlineInputBorder(),
//               ),
//               items: _tipos
//                   .map(
//                     (item) => DropdownMenuItem(
//                       value: item,
//                       child: Text(
//                         _formatearTexto(item),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _tipo = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 14),

//             DropdownButtonFormField<String>(
//               initialValue: _prioridad,
//               decoration: const InputDecoration(
//                 labelText: 'Prioridad',
//                 prefixIcon: Icon(Icons.priority_high_rounded),
//                 border: OutlineInputBorder(),
//               ),
//               items: _prioridades
//                   .map(
//                     (item) => DropdownMenuItem(
//                       value: item,
//                       child: Text(_formatearTexto(item)),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _prioridad = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 14),

//             DropdownButtonFormField<bool>(
//               initialValue: _requiereConfirmacion,
//               decoration: const InputDecoration(
//                 labelText: 'Confirmación',
//                 prefixIcon: Icon(Icons.question_answer_outlined),
//                 border: OutlineInputBorder(),
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: true,
//                   child: Text('Requiere confirmación'),
//                 ),
//                 DropdownMenuItem(
//                   value: false,
//                   child: Text('No requiere confirmación'),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _requiereConfirmacion = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 22),

//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       context.read<AlertaBloc>().add(
//                         const LimpiarFiltrosAlertasEvent(),
//                       );

//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.filter_alt_off_rounded),
//                     label: const Text('Limpiar'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FilledButton.icon(
//                     onPressed: () {
//                       context.read<AlertaBloc>().add(
//                         FiltrarAlertasEvent(
//                           estado: _estado,
//                           tipo: _tipo,
//                           prioridad: _prioridad,
//                           requiereConfirmacion: _requiereConfirmacion,
//                         ),
//                       );

//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.search_rounded),
//                     label: const Text('Aplicar'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================================================
// // ESTADOS DE PANTALLA
// // ==========================================================================

// class _AlertaInitialLoading extends StatelessWidget {
//   const _AlertaInitialLoading();

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 14),
//           Text('Cargando alertas...'),
//         ],
//       ),
//     );
//   }
// }

// class _AlertaErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;

//   const _AlertaErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.cloud_off_rounded,
//               size: 72,
//               color: Theme.of(context).colorScheme.error,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No se pudieron cargar las alertas',
//               textAlign: TextAlign.center,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 22),
//             FilledButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Reintentar'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AlertaEmptyView extends StatelessWidget {
//   final bool tieneFiltros;
//   final VoidCallback onClearFilters;

//   const _AlertaEmptyView({
//     required this.tieneFiltros,
//     required this.onClearFilters,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               tieneFiltros
//                   ? Icons.filter_alt_off_rounded
//                   : Icons.notifications_none_rounded,
//               size: 74,
//               color: Colors.grey.shade500,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               tieneFiltros
//                   ? 'No existen alertas con estos filtros'
//                   : 'No tienes alertas',
//               textAlign: TextAlign.center,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               tieneFiltros
//                   ? 'Prueba cambiando o eliminando los filtros aplicados.'
//                   : 'Las alertas enviadas por la central aparecerán aquí.',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             if (tieneFiltros) ...[
//               const SizedBox(height: 20),
//               OutlinedButton.icon(
//                 onPressed: onClearFilters,
//                 icon: const Icon(Icons.filter_alt_off_rounded),
//                 label: const Text('Limpiar filtros'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ==========================================================================
// // HELPERS
// // ==========================================================================

// String _formatearTexto(String value) {
//   if (value.trim().isEmpty) {
//     return '';
//   }

//   final words = value
//       .trim()
//       .toLowerCase()
//       .split('_')
//       .where((item) => item.isNotEmpty)
//       .map((item) => '${item[0].toUpperCase()}${item.substring(1)}');

//   return words.join(' ');
// }

// String _formatearFecha(DateTime? date) {
//   if (date == null) {
//     return 'Fecha no disponible';
//   }

//   final local = date.toLocal();

//   final day = local.day.toString().padLeft(2, '0');
//   final month = local.month.toString().padLeft(2, '0');
//   final year = local.year.toString();

//   final hour = local.hour.toString().padLeft(2, '0');
//   final minute = local.minute.toString().padLeft(2, '0');

//   return '$day/$month/$year - $hour:$minute';
// }

// Color _getPrioridadColor(BuildContext context, String? prioridad) {
//   switch (prioridad) {
//     case 'CRITICA':
//       return Colors.red.shade700;

//     case 'ALTA':
//       return Colors.deepOrange.shade700;

//     case 'MEDIA':
//       return Colors.amber.shade800;

//     case 'BAJA':
//       return Colors.green.shade700;

//     default:
//       return Theme.of(context).colorScheme.primary;
//   }
// }

// Color _getEstadoDestinatarioColor(BuildContext context, String estado) {
//   switch (estado) {
//     case 'PENDIENTE':
//       return Colors.orange.shade700;

//     case 'RECIBIDA':
//       return Colors.blue.shade700;

//     case 'LEIDA':
//       return Colors.indigo.shade600;

//     case 'ACEPTADA':
//       return Colors.green.shade700;

//     case 'RECHAZADA':
//       return Colors.red.shade700;

//     case 'ATENDIDA':
//       return Colors.teal.shade700;

//     default:
//       return Theme.of(context).colorScheme.primary;
//   }
// }

// IconData _getEstadoDestinatarioIcon(String estado) {
//   switch (estado) {
//     case 'PENDIENTE':
//       return Icons.schedule_rounded;

//     case 'RECIBIDA':
//       return Icons.notifications_active_outlined;

//     case 'LEIDA':
//       return Icons.mark_email_read_outlined;

//     case 'ACEPTADA':
//       return Icons.check_circle_outline_rounded;

//     case 'RECHAZADA':
//       return Icons.cancel_outlined;

//     case 'ATENDIDA':
//       return Icons.task_alt_rounded;

//     default:
//       return Icons.info_outline_rounded;
//   }
// }

// IconData _getTipoIcon(String? tipo) {
//   switch (tipo) {
//     case 'PANICO':
//       return Icons.crisis_alert_rounded;

//     case 'INCIDENCIA':
//       return Icons.report_problem_outlined;

//     case 'EMERGENCIA':
//       return Icons.emergency_rounded;

//     case 'SOS':
//       return Icons.sos_rounded;

//     case 'INFORMATIVA':
//       return Icons.info_outline_rounded;

//     case 'PREVENTIVA':
//       return Icons.health_and_safety_outlined;

//     case 'CAMBIO_RUTA':
//       return Icons.alt_route_rounded;

//     case 'APOYO_REQUERIDO':
//       return Icons.groups_outlined;

//     case 'MENSAJE_CENTRAL':
//       return Icons.campaign_outlined;

//     default:
//       return Icons.notifications_active_outlined;
//   }
// }
