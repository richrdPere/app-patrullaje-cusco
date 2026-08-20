import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/app_widgets/app_summary_chip.dart';

class MisIncidenciasContent extends StatelessWidget {
  final IncidenteState state;

  final ValueChanged<IncidenciaListadoData> onIncidenciaTap;

  const MisIncidenciasContent({
    super.key,
    required this.state,
    required this.onIncidenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: Stack(
        children: [
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ===========================================
              // FILTROS
              // ===========================================
              _FiltersSection(
                params: state.misIncidenciasParams,
                onEstadoChanged: (estado) {
                  _changeEstado(context, estado);
                },
                onTipoChanged: (tipo) {
                  _changeTipo(context, tipo);
                },
                onLimitChanged: (limit) {
                  _changeLimit(context, limit);
                },
                onClear: () {
                  _clearFilters(context);
                },
              ),

              const SizedBox(height: 18),

              // ===========================================
              // RESUMEN
              // ===========================================
              _ResultsHeader(
                totalItems: state.misIncidenciasTotalItems,
                currentPage: state.misIncidenciasPage,
                totalPages: state.misIncidenciasTotalPages,
              ),

              const SizedBox(height: 12),

              // ===========================================
              // RESULTADO
              // ===========================================
              if (state.isLoadingMisIncidencias && state.misIncidencias.isEmpty)
                const _LoadingState()
              else if (state.misIncidenciasResponse is ErrorData &&
                  state.misIncidencias.isEmpty)
                _ErrorState(
                  message: _getErrorMessage(),
                  onRetry: () {
                    _retry(context);
                  },
                )
              else if (state.misIncidencias.isEmpty)
                _EmptyState(
                  hasFilters: _hasFilters,
                  onClear: () {
                    _clearFilters(context);
                  },
                )
              else ...[
                ...state.misIncidencias.map((incidencia) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _IncidenciaCard(
                      incidencia: incidencia,
                      onTap: () {
                        onIncidenciaTap(incidencia);
                      },
                    ),
                  );
                }),

                const SizedBox(height: 4),

                _PaginationSection(
                  currentPage: state.misIncidenciasPage,
                  totalPages: state.misIncidenciasTotalPages,
                  canGoPrevious: state.misIncidenciasPage > 1,
                  canGoNext: state.misIncidenciasHasMore,
                  isLoading: state.isLoadingMoreMisIncidencias,
                  onPrevious: () {
                    _previousPage(context);
                  },
                  onNext: () {
                    _nextPage(context);
                  },
                ),
              ],
            ],
          ),

          if (state.isLoadingMoreMisIncidencias &&
              state.misIncidencias.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasFilters {
    final params = state.misIncidenciasParams;

    return params.estado != null ||
        params.tipo != null ||
        params.origen != null;
  }

  String _getErrorMessage() {
    final response = state.misIncidenciasResponse;

    if (response is ErrorData<ApiResponse<MisIncidenciasPaginated>>) {
      return response.message;
    }

    return 'No se pudieron obtener las incidencias.';
  }

  // ======================================================
  // REFRESCAR
  // ======================================================

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<IncidenteBloc>();

    final params = state.misIncidenciasParams.copyWith(page: 1);

    bloc.add(ObtenerMisIncidenciasEvent(params: params, refresh: true));

    await bloc.stream.firstWhere(
      (newState) => !newState.isLoadingMisIncidencias,
    );
  }

  // ======================================================
  // REINTENTAR
  // ======================================================

  void _retry(BuildContext context) {
    final params = state.misIncidenciasParams.copyWith(page: 1);

    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(params: params, refresh: true),
    );
  }

  // ======================================================
  // FILTRO ESTADO
  // ======================================================

  void _changeEstado(BuildContext context, IncidenciaEstadoFilter? estado) {
    final params = state.misIncidenciasParams.copyWith(
      page: 1,
      estado: estado,
      clearEstado: estado == null,
    );

    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(params: params),
    );
  }

  // ======================================================
  // FILTRO TIPO
  // ======================================================

  void _changeTipo(BuildContext context, IncidenciaTipoFilter? tipo) {
    final params = state.misIncidenciasParams.copyWith(
      page: 1,
      tipo: tipo,
      clearTipo: tipo == null,
    );

    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(params: params),
    );
  }

  // ======================================================
  // CAMBIAR LÍMITE
  // ======================================================

  void _changeLimit(BuildContext context, int limit) {
    final params = state.misIncidenciasParams.copyWith(page: 1, limit: limit);

    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(params: params),
    );
  }

  // ======================================================
  // LIMPIAR FILTROS
  // ======================================================

  void _clearFilters(BuildContext context) {
    context.read<IncidenteBloc>().add(
      const ObtenerMisIncidenciasEvent(
        params: MisIncidenciasQueryParams(
          page: 1,
          limit: 10,
          mode: MisIncidenciasMode.app,
          incluirArchivos: false,
        ),
      ),
    );
  }

  // ======================================================
  // PÁGINA ANTERIOR
  // ======================================================

  void _previousPage(BuildContext context) {
    if (state.misIncidenciasPage <= 1 || state.isLoadingMoreMisIncidencias) {
      return;
    }

    final params = state.misIncidenciasParams.copyWith(
      page: state.misIncidenciasPage - 1,
    );

    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(params: params),
    );
  }

  // ======================================================
  // SIGUIENTE PÁGINA
  // ======================================================

  void _nextPage(BuildContext context) {
    if (!state.misIncidenciasHasMore || state.isLoadingMoreMisIncidencias) {
      return;
    }

    /*
     * Este evento utiliza los parámetros almacenados
     * en el estado y conserva todos los filtros.
     */
    context.read<IncidenteBloc>().add(const CargarMasMisIncidenciasEvent());
  }
}

// ========================================================
// FILTROS
// ========================================================

class _FiltersSection extends StatelessWidget {
  final MisIncidenciasQueryParams params;

  final ValueChanged<IncidenciaEstadoFilter?> onEstadoChanged;

  final ValueChanged<IncidenciaTipoFilter?> onTipoChanged;

  final ValueChanged<int> onLimitChanged;
  final VoidCallback onClear;

  const _FiltersSection({
    required this.params,
    required this.onEstadoChanged,
    required this.onTipoChanged,
    required this.onLimitChanged,
    required this.onClear,
  });

  bool get hasFilters =>
      params.estado != null || params.tipo != null || params.origen != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<IncidenciaEstadoFilter?>(
                  value: params.estado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(
                      value: IncidenciaEstadoFilter.reportado,
                      child: Text('Reportado'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaEstadoFilter.enProceso,
                      child: Text('En proceso'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaEstadoFilter.atendido,
                      child: Text('Atendido'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaEstadoFilter.cerrado,
                      child: Text('Cerrado'),
                    ),
                  ],
                  onChanged: onEstadoChanged,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<IncidenciaTipoFilter?>(
                  value: params.tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.robo,
                      child: Text('Robo'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.accidente,
                      child: Text('Accidente'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.incendio,
                      child: Text('Incendio'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.violencia,
                      child: Text('Violencia'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.sospechoso,
                      child: Text('Sospechoso'),
                    ),
                    DropdownMenuItem(
                      value: IncidenciaTipoFilter.otro,
                      child: Text('Otro'),
                    ),
                  ],
                  onChanged: onTipoChanged,
                ),
              ),
            ],
          ),

          // const SizedBox(height: 10),

          // Row(
          //   children: [
          //     SizedBox(
          //       width: 130,
          //       child: DropdownButtonFormField<int>(
          //         value: params.limit,
          //         decoration: const InputDecoration(
          //           labelText: 'Mostrar',
          //           border: OutlineInputBorder(),
          //         ),
          //         items: const [
          //           DropdownMenuItem(value: 5, child: Text('5')),
          //           DropdownMenuItem(value: 10, child: Text('10')),
          //           DropdownMenuItem(value: 20, child: Text('20')),
          //         ],
          //         onChanged: (value) {
          //           if (value != null) {
          //             onLimitChanged(value);
          //           }
          //         },
          //       ),
          //     ),

          //     const Spacer(),

          //     if (hasFilters)
          //       TextButton.icon(
          //         onPressed: onClear,
          //         icon: const Icon(Icons.filter_alt_off_outlined),
          //         label: const Text('Limpiar'),
          //       ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

// ========================================================
// RESUMEN
// ========================================================

class _ResultsHeader extends StatelessWidget {
  final int totalItems;
  final int currentPage;
  final int totalPages;

  const _ResultsHeader({
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: AppSummaryChip(
            total: totalItems,
            singularLabel: 'incidente',
            pluralLabel: 'incidentes',
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            icon: Icons.report_outlined,
            isSearching: false,
            search: '',
          ),
        ),

        if (totalPages > 0)
          Text(
            'Página $currentPage de $totalPages',
            style: textTheme.bodySmall,
          ),
      ],
    );
  }
}

// ========================================================
// CARD
// ========================================================

class _IncidenciaCard extends StatelessWidget {
  final IncidenciaListadoData incidencia;
  final VoidCallback onTap;

  const _IncidenciaCard({required this.incidencia, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tipoColor = _getTipoColor(incidencia.tipo);

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tipoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getTipoIcon(incidencia.tipo), color: tipoColor),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _formatTipo(incidencia.tipo),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),

                        _StatusBadge(estado: incidencia.estado),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      incidencia.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _InfoItem(
                          icon: Icons.location_on_outlined,
                          text: incidencia.zona?.nombre ?? 'Sin zona',
                        ),
                        _InfoItem(
                          icon: Icons.schedule_outlined,
                          text: _formatDateTime(incidencia.fechaHora),
                        ),
                        _InfoItem(
                          icon: Icons.attachment_outlined,
                          text: '${incidencia.totalEvidencias}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Icon(Icons.chevron_right_rounded, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROBO':
        return Icons.local_police_outlined;

      case 'ACCIDENTE':
        return Icons.car_crash_outlined;

      case 'INCENDIO':
        return Icons.local_fire_department_outlined;

      case 'VIOLENCIA':
        return Icons.personal_injury_outlined;

      case 'SOSPECHOSO':
        return Icons.visibility_outlined;

      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROBO':
        return Colors.deepPurple;

      case 'ACCIDENTE':
        return Colors.orange;

      case 'INCENDIO':
        return Colors.red;

      case 'VIOLENCIA':
        return Colors.pink;

      case 'SOSPECHOSO':
        return Colors.amber.shade800;

      default:
        return Colors.blueGrey;
    }
  }

  String _formatTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'ROBO':
        return 'Robo';

      case 'ACCIDENTE':
        return 'Accidente';

      case 'INCENDIO':
        return 'Incendio';

      case 'VIOLENCIA':
        return 'Violencia';

      case 'SOSPECHOSO':
        return 'Sospechoso';

      default:
        return 'Otro';
    }
  }

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');

    final month = localDate.month.toString().padLeft(2, '0');

    final hour = localDate.hour.toString().padLeft(2, '0');

    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year} '
        '$hour:$minute';
  }
}

class _StatusBadge extends StatelessWidget {
  final String estado;

  const _StatusBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _getLabel(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (estado.toUpperCase()) {
      case 'REPORTADO':
        return Colors.orange.shade800;

      case 'EN_PROCESO':
        return Colors.blue;

      case 'ATENDIDO':
        return Colors.green;

      case 'CERRADO':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  String _getLabel() {
    switch (estado.toUpperCase()) {
      case 'REPORTADO':
        return 'Reportado';

      case 'EN_PROCESO':
        return 'En proceso';

      case 'ATENDIDO':
        return 'Atendido';

      case 'CERRADO':
        return 'Cerrado';

      default:
        return estado;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ========================================================
// PAGINACIÓN
// ========================================================

class _PaginationSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLoading;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationSection({
    required this.currentPage,
    required this.totalPages,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          tooltip: 'Página anterior',
          onPressed: canGoPrevious && !isLoading ? onPrevious : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$currentPage / $totalPages',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        IconButton.outlined(
          tooltip: 'Página siguiente',
          onPressed: canGoNext && !isLoading ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

// ========================================================
// ESTADOS
// ========================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 280,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: colors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 58,
              color: colors.outline,
            ),

            const SizedBox(height: 14),

            Text(
              'No se encontraron incidencias',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            Text(
              hasFilters
                  ? 'Prueba modificando los filtros aplicados.'
                  : 'Todavía no registraste incidencias.',
              textAlign: TextAlign.center,
            ),

            if (hasFilters) ...[
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
