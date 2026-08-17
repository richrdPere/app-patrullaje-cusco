import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/listado/widgets/OcurrenciaEmpty.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/listado/widgets/OcurrenciaFiltersSheet.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/listado/widgets/OcurrenciaListCard.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/listado/widgets/OcurrenciaPaginationFooter.dart';

class OcurrenciasContent extends StatefulWidget {
  const OcurrenciasContent({super.key});

  @override
  State<OcurrenciasContent> createState() => _OcurrenciasContentState();
}

class _OcurrenciasContentState extends State<OcurrenciasContent> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchTimer;

  OcurrenciaQueryParams _params = const OcurrenciaQueryParams(
    page: 1,
    limit: 20,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _getOcurrencias();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // OBTENER OCURRENCIAS
  // ==========================================================
  void _getOcurrencias() {
    context.read<OcurrenciaBloc>().add(GetOcurrenciasPaginado(params: _params));
  }

  Future<void> _refresh() async {
    _params = _params.copyWith(page: 1);

    _getOcurrencias();

    await context.read<OcurrenciaBloc>().stream.firstWhere(
      (state) => state.paginatedResponse is! Loading,
    );
  }

  // ==========================================================
  // BÚSQUEDA
  // ==========================================================
  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      _params = _params.copyWith(
        page: 1,
        numero: value.trim(),
        clearNumero: value.trim().isEmpty,
      );

      _getOcurrencias();
    });
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();

    setState(() {
      _params = _params.copyWith(page: 1, clearNumero: true);
    });

    _getOcurrencias();
  }

  // ==========================================================
  // FILTROS
  // ==========================================================
  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<OcurrenciaQueryParams>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return OcurrenciaFiltersSheet(initialParams: _params);
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      _params = result.copyWith(
        page: 1,
        numero: _searchController.text,
        clearNumero: _searchController.text.trim().isEmpty,
      );
    });

    _getOcurrencias();
  }

  void _clearFilters() {
    setState(() {
      _params = OcurrenciaQueryParams(
        page: 1,
        limit: _params.limit,
        numero: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
    });

    _getOcurrencias();
  }

  int get _activeFilters {
    var total = 0;

    if (_params.codigo?.trim().isNotEmpty == true) total++;
    if (_params.fecha?.trim().isNotEmpty == true) total++;
    if (_params.fechaDesde?.trim().isNotEmpty == true) total++;
    if (_params.fechaHasta?.trim().isNotEmpty == true) total++;
    if (_params.serenoId != null) total++;
    if (_params.zonaId != null) total++;
    if (_params.turno?.trim().isNotEmpty == true) total++;
    if (_params.estado?.trim().isNotEmpty == true) total++;
    if (_params.estadoRemision?.trim().isNotEmpty == true) {
      total++;
    }

    return total;
  }

  // ==========================================================
  // PAGINACIÓN
  // ==========================================================
  void _previousPage() {
    if (_params.page <= 1) return;

    setState(() {
      _params = _params.copyWith(page: _params.page - 1);
    });

    _getOcurrencias();
  }

  void _nextPage(int totalPages) {
    if (_params.page >= totalPages) return;

    setState(() {
      _params = _params.copyWith(page: _params.page + 1);
    });

    _getOcurrencias();
  }

  void _changePageSize(int limit) {
    setState(() {
      _params = _params.copyWith(page: 1, limit: limit);
    });

    _getOcurrencias();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
            buildWhen: (previous, current) {
              return previous.paginatedResponse != current.paginatedResponse;
            },
            builder: (context, state) {
              return _buildResponse(context, state.paginatedResponse);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por número de ocurrencia',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openFilters,
                    icon: Badge(
                      isLabelVisible: _activeFilters > 0,
                      label: Text('$_activeFilters'),
                      child: const Icon(Icons.tune_rounded, size: 20),
                    ),
                    label: Text(
                      _activeFilters == 0
                          ? 'Filtros'
                          : 'Filtros ($_activeFilters)',
                    ),
                  ),
                ),
                if (_activeFilters > 0) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Limpiar filtros',
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponse(
    BuildContext context,
    Resource<ApiResponse<OcurrenciaPaginated>> response,
  ) {
    if (response is Initial<ApiResponse<OcurrenciaPaginated>>) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response is Loading<ApiResponse<OcurrenciaPaginated>>) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response is ErrorData<ApiResponse<OcurrenciaPaginated>>) {
      return OcurrenciaError(
        message: response.message,
        onRetry: _getOcurrencias,
      );
    }

    if (response is Success<ApiResponse<OcurrenciaPaginated>>) {
      final paginated = response.data.data;

      if (paginated == null) {
        return OcurrenciaError(
          message: 'No se pudo interpretar la respuesta del servidor.',
          onRetry: _getOcurrencias,
        );
      }

      if (paginated.items.isEmpty) {
        return OcurrenciaEmpty(
          hasFilters:
              _activeFilters > 0 || _searchController.text.trim().isNotEmpty,
          onClearFilters: _clearFilters,
          onRefresh: _refresh,
        );
      }

      return _buildList(context, paginated);
    }

    return const SizedBox.shrink();
  }

  Widget _buildList(BuildContext context, OcurrenciaPaginated paginated) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: paginated.items.length + 2,
        separatorBuilder: (_, index) {
          if (index == 0) {
            return const SizedBox(height: 8);
          }

          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildResultsSummary(context, paginated);
          }

          if (index <= paginated.items.length) {
            final item = paginated.items[index - 1];

            return OcurrenciaListCard(
              ocurrencia: item,
              onTap: () {
                context.push('/ocurrencias/${item.id}');
              },
            );
          }

          return OcurrenciaPaginationFooter(
            pagination: paginated.pagination,
            currentLimit: _params.limit,
            onPrevious: paginated.pagination.hasPreviousPage
                ? _previousPage
                : null,
            onNext: paginated.pagination.hasNextPage
                ? () => _nextPage(paginated.pagination.totalPages)
                : null,
            onPageSizeChanged: _changePageSize,
          );
        },
      ),
    );
  }

  Widget _buildResultsSummary(
    BuildContext context,
    OcurrenciaPaginated paginated,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            paginated.pagination.totalItems == 1
                ? '1 ocurrencia encontrada'
                : '${paginated.pagination.totalItems} ocurrencias encontradas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          'Página ${paginated.pagination.currentPage} '
          'de ${paginated.pagination.totalPages}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
