import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/filters_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/pagination_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/patrullage_list_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/results_header.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/widgets/results_header.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/app_widgets/app_summary_chip.dart';

class MisPatrullajesContent extends StatefulWidget {
  final HomeState homeState;

  const MisPatrullajesContent({super.key, required this.homeState});

  @override
  State<MisPatrullajesContent> createState() => _MisPatrullajesContentState();
}

class _MisPatrullajesContentState extends State<MisPatrullajesContent> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.homeState.misPatrullajesParams.search ?? '',
    );

    _searchController.addListener(_onSearchChanged);
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
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
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
              // BÚSQUEDA Y FILTRO POR DÍA
              // ===========================================
              FiltersSection(
                searchController: _searchController,
                params: state.misPatrullajesParams,
                onSearch: _search,
                onDiaChanged: _changeDia,
                onClearDia: _clearDia,
                onClearFilters: _clearFilters,
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
              

              const SizedBox(height: 20),

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
                EmptyState(
                  onClear: _clearFilters,
                  message: _emptyMessage(state.misPatrullajesParams.dia),
                )
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
          // LOADING AL CAMBIAR FILTRO O PÁGINA
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
  // LIMPIAR ÚNICAMENTE EL DÍA
  // ==========================================================
  void _clearDia() {
    final currentParams = widget.homeState.misPatrullajesParams;

    final params = currentParams.copyWith(
      page: 1,
      clearDia: true,
      clearFechaDesde: true,
      clearFechaHasta: true,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
  }

  // ==========================================================
  // LIMPIAR TODOS LOS FILTROS
  // ==========================================================
  void _clearFilters() {
    _searchController.clear();

    final currentParams = widget.homeState.misPatrullajesParams;

    final params = currentParams.copyWith(
      page: 1,

      // Limpiar filtros visibles.
      clearDia: true,
      clearSearch: true,

      // Limpiar posibles filtros anteriores.
      clearFechaDesde: true,
      clearFechaHasta: true,
      clearEstado: true,
      clearEstadoPersonal: true,
      clearZonaId: true,
      clearUnidadId: true,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
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
  // LISTENER AUTOMÁTICO DE BÚSQUEDA
  // ==========================================================

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }

      final inputSearch = _searchController.text.trim();

      final currentSearch = widget.homeState.misPatrullajesParams.search
          ?.trim();

      final normalizedCurrentSearch =
          currentSearch == null || currentSearch.isEmpty ? '' : currentSearch;

      /*
       * Evita repetir la consulta cuando el valor del
       * controlador ya coincide con el valor del estado.
       */
      if (inputSearch == normalizedCurrentSearch) {
        return;
      }

      _search();
    });
  }

  // ==========================================================
  // BÚSQUEDA
  // ==========================================================
  void _search() {
    _searchDebounce?.cancel();

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
  // FILTRAR POR DÍA
  // ==========================================================
  void _changeDia(DateTime dia) {
    final currentParams = widget.homeState.misPatrullajesParams;

    final selectedDay = DateUtils.dateOnly(dia);

    final params = currentParams.copyWith(
      page: 1,
      dia: selectedDay,
      clearFechaDesde: true,
      clearFechaHasta: true,
    );

    context.read<HomeBloc>().add(LoadMisPatrullajes(params: params));
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
  // MENSAJE VACÍO
  // ==========================================================

  String _emptyMessage(DateTime? dia) {
    if (dia == null) {
      return 'No tienes patrullajes registrados.';
    }

    final formattedDate = _formatDisplayDate(dia);

    return 'No tienes patrullajes para el $formattedDate.';
  }

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ==========================================================
  // ABRIR PATRULLAJE
  // ==========================================================

  void _openPatrullaje(PatrullajeListadoData patrullaje) {
    context.pushNamed(
      'patrullaje_detalle',
      pathParameters: {'patrullajeId': patrullaje.id.toString()},
      extra: patrullaje,
    );
  }
}
