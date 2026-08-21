import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

class SiguienteTurnoContent extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const SiguienteTurnoContent({
    super.key,
    required this.onRefresh,
    required this.onRetry,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      buildWhen: (previous, current) {
        return previous.siguienteTurnoStatus != current.siguienteTurnoStatus ||
            previous.siguienteTurno != current.siguienteTurno ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        final status = state.siguienteTurnoStatus;

        final data = state.siguienteTurno;

        if ((status == HistorialSiguienteTurnoStatus.initial ||
                status == HistorialSiguienteTurnoStatus.loading) &&
            data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status == HistorialSiguienteTurnoStatus.error && data == null) {
          return _ErrorView(
            message:
                state.errorMessage ??
                'No se pudo obtener la información del turno anterior.',
            onRetry: onRetry,
          );
        }

        if (data == null) {
          return _ErrorView(
            message: 'No hay información disponible.',
            onRetry: onRetry,
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  _ContinuidadHeader(zona: data.zona),

                  const SizedBox(height: 16),

                  _TurnosComparison(
                    actual: data.patrullajeActual,
                    anterior: data.patrullajeAnterior,
                  ),

                  const SizedBox(height: 22),

                  if (!data.tienePatrullajeAnterior)
                    const _NoPreviousPatrol()
                  else ...[
                    _SectionTitle(
                      icon: Icons.analytics_outlined,
                      title: 'Resumen del turno anterior',
                      subtitle:
                          'Información relevante para continuar el patrullaje.',
                    ),

                    const SizedBox(height: 12),

                    _ResumenTurno(resumen: data.resumen),

                    const SizedBox(height: 24),

                    _SectionTitle(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Novedades recibidas',
                      subtitle:
                          '${data.pagination.totalItems} registros visibles para tu turno.',
                    ),

                    const SizedBox(height: 12),

                    if (data.historial.isEmpty)
                      const _NoContextView()
                    else
                      ...data.historial.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TurnoHistorialCard(historial: item),
                        ),
                      ),

                    if (data.pagination.totalPages > 1) ...[
                      const SizedBox(height: 8),
                      _PaginationFooter(
                        pagination: data.pagination,
                        onPrevious: onPreviousPage,
                        onNext: onNextPage,
                      ),
                    ],
                  ],
                ],
              ),
            ),

            if (status == HistorialSiguienteTurnoStatus.loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}

// ==========================================================
// ENCABEZADO
// ==========================================================
class _ContinuidadHeader extends StatelessWidget {
  final ContextoZona zona;

  const _ContinuidadHeader({required this.zona});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2691), Color(0xFF3659D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.sync_alt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continuidad operativa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zona.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Revisa las novedades registradas por el personal del turno anterior.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// COMPARACIÓN DE TURNOS
// ==========================================================
class _TurnosComparison extends StatelessWidget {
  final SiguienteTurnoPatrullajeData actual;

  final SiguienteTurnoPatrullajeData? anterior;

  const _TurnosComparison({required this.actual, required this.anterior});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PatrullajeTurnoCard(
          title: 'Tu patrullaje actual',
          patrullaje: actual,
          icon: Icons.shield_outlined,
          color: Colors.green,
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.arrow_upward_rounded, color: Colors.grey),
        ),

        if (anterior != null)
          _PatrullajeTurnoCard(
            title: 'Patrullaje anterior',
            patrullaje: anterior!,
            icon: Icons.history_rounded,
            color: Colors.blueGrey,
          )
        else
          const _NoPreviousPatrolCompact(),
      ],
    );
  }
}

class _PatrullajeTurnoCard extends StatelessWidget {
  final String title;

  final SiguienteTurnoPatrullajeData patrullaje;

  final IconData icon;
  final Color color;

  const _PatrullajeTurnoCard({
    required this.title,
    required this.patrullaje,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(patrullaje.fecha);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patrullaje N.° ${patrullaje.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '$date · ${patrullaje.horaInicio} - ${patrullaje.horaFin}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (patrullaje.descripcion != null &&
                    patrullaje.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    patrullaje.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// RESUMEN
// ==========================================================
class _ResumenTurno extends StatelessWidget {
  final ContextoResumen resumen;

  const _ResumenTurno({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Registros', resumen.total, Icons.list_alt_rounded, Colors.blue),
      (
        'Observaciones',
        resumen.observaciones,
        Icons.visibility_outlined,
        Colors.indigo,
      ),
      ('Alertas', resumen.alertas, Icons.warning_amber_rounded, Colors.red),
      (
        'Puntos críticos',
        resumen.puntosCriticos,
        Icons.location_on_outlined,
        Colors.deepOrange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.$4.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.$4.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(item.$3, color: item.$4),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.$2}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.$1,
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
      },
    );
  }
}

// ==========================================================
// REGISTRO DEL TURNO ANTERIOR
// ==========================================================
class _TurnoHistorialCard extends StatelessWidget {
  final ContextoHistorialItem historial;

  const _TurnoHistorialCard({required this.historial});

  void _abrirDetalle(BuildContext context) {
    if (historial.id <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se encontró un historial válido.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    context.pushNamed(
      'historial_detalle',
      pathParameters: {'historialId': historial.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final priorityColor = _priorityColor(historial.prioridad);

    final sereno = historial.usuario?.persona?.nombreCompleto;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirDetalle(context),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: priorityColor.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TIPO, PRIORIDAD Y FECHA
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _StatusChip(
                          label: _typeLabel(historial.tipo),
                          color: _typeColor(historial.tipo),
                        ),
                        _StatusChip(
                          label: _priorityLabel(historial.prioridad),
                          color: priorityColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    DateFormat(
                      'dd/MM HH:mm',
                    ).format(historial.fechaHora.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // TÍTULO
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      historial.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ==================================================
              // DESCRIPCIÓN
              // ==================================================
              Text(
                historial.descripcion,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // INFORMACIÓN COMPLEMENTARIA
              // ==================================================
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _InfoLabel(
                    icon: Icons.person_outline,
                    text: sereno?.trim().isNotEmpty == true
                        ? sereno!.trim()
                        : 'Sereno no disponible',
                  ),

                  if (historial.tieneUbicacion)
                    const _InfoLabel(
                      icon: Icons.my_location_rounded,
                      text: 'Con ubicación',
                    ),

                  if (historial.tieneArchivos)
                    _InfoLabel(
                      icon: Icons.photo_library_outlined,
                      text:
                          '${historial.archivos.length} '
                          '${historial.archivos.length == 1 ? 'archivo' : 'archivos'}',
                    ),

                  if (historial.tieneIncidencia)
                    const _InfoLabel(
                      icon: Icons.report_outlined,
                      text: 'Incidencia relacionada',
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ACCESO AL DETALLE
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalle',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 17,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return 'Observación';
      case HistorialTipo.novedad:
        return 'Novedad';
      case HistorialTipo.alerta:
        return 'Alerta';
      case HistorialTipo.recomendacion:
        return 'Recomendación';
      case HistorialTipo.puntoCritico:
        return 'Punto crítico';
      case HistorialTipo.cambioTurno:
        return 'Cambio de turno';
    }
  }

  Color _typeColor(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return Colors.indigo;
      case HistorialTipo.novedad:
        return Colors.blue;
      case HistorialTipo.alerta:
        return Colors.red;
      case HistorialTipo.recomendacion:
        return Colors.green;
      case HistorialTipo.puntoCritico:
        return Colors.deepOrange;
      case HistorialTipo.cambioTurno:
        return Colors.purple;
    }
  }

  String _priorityLabel(HistorialPrioridad prioridad) {
    switch (prioridad) {
      case HistorialPrioridad.baja:
        return 'Baja';
      case HistorialPrioridad.media:
        return 'Media';
      case HistorialPrioridad.alta:
        return 'Alta';
      case HistorialPrioridad.critica:
        return 'Crítica';
    }
  }

  Color _priorityColor(HistorialPrioridad prioridad) {
    switch (prioridad) {
      case HistorialPrioridad.baja:
        return Colors.green;
      case HistorialPrioridad.media:
        return Colors.amber.shade800;
      case HistorialPrioridad.alta:
        return Colors.deepOrange;
      case HistorialPrioridad.critica:
        return Colors.red;
    }
  }
}

// ==========================================================
// COMPONENTES AUXILIARES
// ==========================================================
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final ContextoPagination pagination;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationFooter({
    required this.pagination,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: pagination.hasPreviousPage ? onPrevious : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            'Página ${pagination.page} de ${pagination.totalPages}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton.outlined(
          onPressed: pagination.hasNextPage ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _NoPreviousPatrol extends StatelessWidget {
  const _NoPreviousPatrol();

  @override
  Widget build(BuildContext context) {
    return _EmptyMessage(
      icon: Icons.flag_outlined,
      title: 'Primer patrullaje de la zona',
      message: 'No existe un patrullaje anterior finalizado en esta zona.',
    );
  }
}

class _NoPreviousPatrolCompact extends StatelessWidget {
  const _NoPreviousPatrolCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'No existe un patrullaje anterior.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NoContextView extends StatelessWidget {
  const _NoContextView();

  @override
  Widget build(BuildContext context) {
    return _EmptyMessage(
      icon: Icons.fact_check_outlined,
      title: 'Sin novedades pendientes',
      message:
          'El turno anterior no dejó información visible para tu patrullaje.',
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 46,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}
