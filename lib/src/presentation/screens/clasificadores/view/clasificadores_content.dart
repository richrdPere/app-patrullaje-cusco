import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';

// BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_state.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/widgets/ClasificadorCard.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/widgets/PaginationSection.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/widgets/SearchSection.dart';

class ClasificadoresContent extends StatefulWidget {
  const ClasificadoresContent({super.key});

  @override
  State<ClasificadoresContent> createState() => _ClasificadoresContentState();
}

class _ClasificadoresContentState extends State<ClasificadoresContent> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  ClasificadorQueryParams _params = const ClasificadorQueryParams(
    page: 1,
    limit: 20,
    estado: true,
    incluirReglas: true,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadClasificadores();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ========================================================
  // CARGAR
  // ========================================================

  void _loadClasificadores() {
    context.read<ClasificadoresBloc>().add(
      GetClasificadoresPaginado(params: _params),
    );
  }

  Future<void> _refresh() async {
    _params = _params.copyWith(page: 1);

    _loadClasificadores();

    await context.read<ClasificadoresBloc>().stream.firstWhere(
      (state) => state.clasificadoresPaginadoResponse is! Loading,
    );
  }

  // ========================================================
  // BÚSQUEDA
  // ========================================================

  void _onSearchChanged(String value) {
    setState(() {});

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      _params = _params.copyWith(page: 1, search: value.trim());

      _loadClasificadores();
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _params = _params.copyWith(page: 1, search: '', codigo: '');
    });

    _loadClasificadores();
  }

  // ========================================================
  // PAGINACIÓN
  // ========================================================

  void _previousPage() {
    if (_params.page <= 1) return;

    _params = _params.copyWith(page: _params.page - 1);

    _loadClasificadores();
  }

  void _nextPage(ClasificadoresState state) {
    if (!state.hasNextPage) return;

    _params = _params.copyWith(page: _params.page + 1);

    _loadClasificadores();
  }

  // ========================================================
  // DETALLE
  // ========================================================

  void _getClasificadorDetail(ClasificadorCodigoData clasificador) {
    context.read<ClasificadoresBloc>().add(
      GetClasificadorByCodigo(codigo: clasificador.codigo),
    );
  }

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchSection(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _clearSearch,
        ),
        Expanded(
          child: BlocBuilder<ClasificadoresBloc, ClasificadoresState>(
            buildWhen: (previous, current) {
              return previous.clasificadoresPaginadoResponse !=
                      current.clasificadoresPaginadoResponse ||
                  previous.clasificadores != current.clasificadores;
            },
            builder: (context, state) {
              return _buildContent(state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ClasificadoresState state) {
    final response = state.clasificadoresPaginadoResponse;

    final clasificadores = state.clasificadores;

    if (response is Loading<ApiResponse<ClasificadorPaginated>> &&
        clasificadores.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (response is ErrorData<ApiResponse<ClasificadorPaginated>>) {
      return ErrorContent(
        message: response.fullMessage,
        onRetry: _loadClasificadores,
      );
    }

    if (clasificadores.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 140), EmptyContent()],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: clasificadores.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final clasificador = clasificadores[index];

                return ClasificadorCard(
                  clasificador: clasificador,
                  isLoading: state.isLoadingCodigo,
                  onTap: () {
                    _getClasificadorDetail(clasificador);
                  },
                );
              },
            ),
          ),
        ),
        PaginationSection(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalItems: state.totalItems,
          hasPreviousPage: state.hasPreviousPage,
          hasNextPage: state.hasNextPage,
          isLoading: state.isLoadingPaginado,
          onPreviousPage: _previousPage,
          onNextPage: () => _nextPage(state),
        ),
      ],
    );
  }
}
