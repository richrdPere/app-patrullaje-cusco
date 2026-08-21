import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

class ContextoZonaContent extends StatelessWidget {
  final ContextoZonaQueryParams params;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const ContextoZonaContent({
    super.key,
    required this.params,
    required this.onRefresh,
    required this.onRetry,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      buildWhen: (previous, current) {
        return previous.contextoZonaStatus != current.contextoZonaStatus ||
            previous.contextoZona != current.contextoZona ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        final status = state.contextoZonaStatus;

        final contexto = state.contextoZona;

        if ((status == HistorialContextoZonaStatus.initial ||
                status == HistorialContextoZonaStatus.loading) &&
            contexto == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status == HistorialContextoZonaStatus.error && contexto == null) {
          return _ErrorView(
            message:
                state.errorMessage ??
                'No se pudo obtener el contexto de la zona.',
            onRetry: onRetry,
          );
        }

        if (contexto == null) {
          return _ErrorView(
            message: 'No hay información disponible.',
            onRetry: onRetry,
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ZonaHeaderCard(zona: contexto.zona),

                        const SizedBox(height: 14),

                        _PatrullajeActualCard(
                          patrullaje: contexto.patrullajeActual,
                        ),

                        const SizedBox(height: 14),

                        _PeriodoCard(periodo: contexto.periodoConsultado),

                        const SizedBox(height: 20),

                        _SectionTitle(
                          icon: Icons.analytics_outlined,
                          title: 'Resumen operativo',
                          subtitle:
                              'Información encontrada en los últimos ${contexto.periodoConsultado.dias} días.',
                        ),

                        const SizedBox(height: 12),

                        _ResumenGrid(resumen: contexto.resumen),

                        const SizedBox(height: 24),

                        _SectionTitle(
                          icon: Icons.history_rounded,
                          title: 'Antecedentes de la zona',
                          subtitle:
                              '${contexto.pagination.totalItems} registros disponibles.',
                        ),

                        const SizedBox(height: 12),

                        if (contexto.historial.isEmpty)
                          const _EmptyView()
                        else
                          ...contexto.historial.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ContextoHistorialCard(historial: item),
                            ),
                          ),

                        if (contexto.pagination.totalPages > 1) ...[
                          const SizedBox(height: 8),

                          _PaginationFooter(
                            pagination: contexto.pagination,
                            onPrevious: onPreviousPage,
                            onNext: onNextPage,
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            if (status == HistorialContextoZonaStatus.loading)
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
// ZONA
// ==========================================================
class _ZonaHeaderCard extends StatelessWidget {
  final ContextoZona zona;

  const _ZonaHeaderCard({required this.zona});

  @override
  Widget build(BuildContext context) {
    final riesgoColor = _riesgoColor(zona.riesgo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.map_outlined),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zona.nombre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Zona operativa',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: riesgoColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Riesgo ${zona.riesgo}',
                  style: TextStyle(
                    color: riesgoColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          if (zona.descripcion != null &&
              zona.descripcion!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              zona.descripcion!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.format_shapes_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 7),
              Text(
                '${zona.coordenadas.length} puntos delimitan la zona',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _riesgoColor(String riesgo) {
    switch (riesgo.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'alto':
        return Colors.deepOrange;
      case 'critico':
        return Colors.red;
      case 'medio':
      default:
        return Colors.amber.shade800;
    }
  }
}

// ==========================================================
// PATRULLAJE ACTUAL
// ==========================================================
class _PatrullajeActualCard extends StatelessWidget {
  final ContextoPatrullajeActual patrullaje;

  const _PatrullajeActualCard({required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrullaje N.° ${patrullaje.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${patrullaje.horaInicio} - ${patrullaje.horaFin}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _SmallStatusChip(
            label: _formatEnumLabel(patrullaje.estado),
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// PERIODO
// ==========================================================
class _PeriodoCard extends StatelessWidget {
  final ContextoPeriodoConsultado periodo;

  const _PeriodoCard({required this.periodo});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${formatter.format(periodo.fechaDesde.toLocal())} '
              'al ${formatter.format(periodo.fechaHasta.toLocal())}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${periodo.dias} días',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// RESUMEN
// ==========================================================
class _ResumenGrid extends StatelessWidget {
  final ContextoResumen resumen;

  const _ResumenGrid({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', resumen.total, Icons.list_alt_rounded, Colors.blue),
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
      (
        'Prioridad alta',
        resumen.altaPrioridad,
        Icons.priority_high_rounded,
        Colors.orange,
      ),
      (
        'Con archivos',
        resumen.conArchivos,
        Icons.attach_file_rounded,
        Colors.teal,
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
        childAspectRatio: 2.25,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.$4.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: item.$4.withValues(alpha: 0.20)),
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
// CARD DE HISTORIAL
// ==========================================================
class _ContextoHistorialCard extends StatelessWidget {
  final ContextoHistorialItem historial;

  const _ContextoHistorialCard({required this.historial});

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
    final colorScheme = Theme.of(context).colorScheme;
    final tipoColor = _tipoColor(historial.tipo);

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
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _SmallStatusChip(
                          label: _tipoLabel(historial.tipo),
                          color: tipoColor,
                        ),
                        _SmallStatusChip(
                          label: _prioridadLabel(historial.prioridad),
                          color: _prioridadColor(historial.prioridad),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(historial.fechaHora.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      historial.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

              Text(
                historial.descripcion,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              if (historial.tieneUbicacion ||
                  historial.tieneArchivos ||
                  historial.tieneIncidencia) ...[
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (historial.tieneUbicacion)
                      const _IconLabel(
                        icon: Icons.my_location_rounded,
                        label: 'Con ubicación',
                      ),

                    if (historial.tieneArchivos)
                      _IconLabel(
                        icon: Icons.photo_library_outlined,
                        label:
                            '${historial.archivos.length} '
                            '${historial.archivos.length == 1 ? 'archivo' : 'archivos'}',
                      ),

                    if (historial.tieneIncidencia)
                      const _IconLabel(
                        icon: Icons.report_outlined,
                        label: 'Incidencia',
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver detalle',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

  Color _tipoColor(HistorialTipo tipo) {
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

  String _tipoLabel(HistorialTipo tipo) {
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

  String _prioridadLabel(HistorialPrioridad prioridad) {
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

  Color _prioridadColor(HistorialPrioridad prioridad) {
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

class _SmallStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallStatusChip({required this.label, required this.color});

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

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel({required this.icon, required this.label});

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
        Text(label, style: Theme.of(context).textTheme.bodySmall),
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
          tooltip: 'Página anterior',
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
          tooltip: 'Página siguiente',
          onPressed: pagination.hasNextPage ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

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
            Icons.history_toggle_off_rounded,
            size: 46,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hay antecedentes disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'No se encontraron registros para los filtros seleccionados.',
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

String _formatEnumLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}'
            '${word.substring(1)}',
      )
      .join(' ');
}
