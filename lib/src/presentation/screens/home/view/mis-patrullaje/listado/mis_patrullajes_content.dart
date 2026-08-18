// mis_patrullajes_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/filters_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/pagination_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/patrullahe_list_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/results_header.dart';

class MisPatrullajesContent extends StatefulWidget {
  final HomeState homeState;

  const MisPatrullajesContent({super.key, required this.homeState});

  @override
  State<MisPatrullajesContent> createState() => _MisPatrullajesContentState();
}

class _MisPatrullajesContentState extends State<MisPatrullajesContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.homeState.misPatrullajesParams.search ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant MisPatrullajesContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousSearch = oldWidget.homeState.misPatrullajesParams.search;

    final currentSearch = widget.homeState.misPatrullajesParams.search;

    if (previousSearch != currentSearch &&
        _searchController.text != (currentSearch ?? '')) {
      _searchController.text = currentSearch ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.homeState;
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Stack(
        children: [
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ===========================================
              // FILTROS
              // ===========================================
              FiltersSection(
                searchController: _searchController,
                params: state.misPatrullajesParams,
                onSearch: _search,
                onEstadoChanged: _changeEstado,
                onLimitChanged: _changeLimit,
                onClear: _clearFilters,
              ),

              const SizedBox(height: 18),

              // ===========================================
              // RESUMEN DE RESULTADOS
              // ===========================================
              ResultsHeader(
                totalItems: state.totalItems,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
              ),

              const SizedBox(height: 12),

              // ===========================================
              // CONTENIDO
              // ===========================================
              if (state.misPatrullajesError != null &&
                  state.patrullajes.isEmpty)
                ErrorState(message: state.misPatrullajesError!, onRetry: _retry)
              else if (state.isLoadingMisPatrullajes &&
                  state.patrullajes.isEmpty)
                const LoadingState()
              else if (state.patrullajes.isEmpty)
                const EmptyState()
              else ...[
                ...state.patrullajes.map((patrullaje) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PatrullajeListCard(
                      patrullaje: patrullaje,
                      onTap: () {
                        _openPatrullaje(patrullaje);
                      },
                    ),
                  );
                }),

                if (state.mostrarPaginacion) ...[
                  const SizedBox(height: 8),

                  PaginationSection(
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    canGoPrevious: state.puedeIrPaginaAnterior,
                    canGoNext: state.puedeIrPaginaSiguiente,
                    onPrevious: _previousPage,
                    onNext: _nextPage,
                  ),
                ],
              ],
            ],
          ),

          // ===============================================
          // LOADING AL CAMBIAR DE PÁGINA
          // ===============================================
          if (state.isLoadingMisPatrullajes && state.patrullajes.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: colors.surface.withValues(alpha: 0.48),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARGAR
  // ==========================================================

  void _retry() {
    context.read<HomeBloc>().add(
      LoadMisPatrullajes(params: widget.homeState.misPatrullajesParams),
    );
  }

  Future<void> _refresh() async {
    final bloc = context.read<HomeBloc>();

    bloc.add(const RefreshMisPatrullajes());

    await bloc.stream.firstWhere((state) => !state.isLoadingMisPatrullajes);
  }

  // ==========================================================
  // BÚSQUEDA
  // ==========================================================

  void _search() {
    final value = _searchController.text.trim();

    final currentParams = widget.homeState.misPatrullajesParams;

    final params = currentParams.copyWith(
      page: 1,
      search: value.isEmpty ? null : value,
      clearSearch: value.isEmpty,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  // ==========================================================
  // ESTADO
  // ==========================================================

  void _changeEstado(PatrullajeEstadoFilter? estado) {
    final currentParams = widget.homeState.misPatrullajesParams;

    final params = currentParams.copyWith(
      page: 1,
      estado: estado,
      clearEstado: estado == null,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  // ==========================================================
  // LÍMITE
  // ==========================================================

  void _changeLimit(int limit) {
    final params = widget.homeState.misPatrullajesParams.copyWith(
      page: 1,
      limit: limit,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  // ==========================================================
  // LIMPIAR FILTROS
  // ==========================================================

  void _clearFilters() {
    _searchController.clear();

    context.read<HomeBloc>().add(const LimpiarFiltrosMisPatrullajes());
  }

  // ==========================================================
  // PAGINACIÓN
  // ==========================================================

  void _previousPage() {
    final state = widget.homeState;

    if (!state.puedeIrPaginaAnterior) {
      return;
    }

    final params = state.misPatrullajesParams.copyWith(
      page: state.currentPage - 1,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  void _nextPage() {
    final state = widget.homeState;

    if (!state.puedeIrPaginaSiguiente) {
      return;
    }

    final params = state.misPatrullajesParams.copyWith(
      page: state.currentPage + 1,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  // ==========================================================
  // ABRIR PATRULLAJE
  // ==========================================================

  void _openPatrullaje(PatrullajeListadoData patrullaje) {
    // context.pushNamed(
    //   'historial_patrullaje',
    //   pathParameters: {'patrullajeId': patrullaje.id.toString()},
    // );

    context.pushNamed(
      'patrullaje_detalle',
      pathParameters: {'patrullajeId': patrullaje.id.toString()},
      extra: patrullaje,
    );
  }
}
