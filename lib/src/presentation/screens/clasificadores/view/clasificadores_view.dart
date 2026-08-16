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

class ClasificadoresView extends StatefulWidget {
  final ValueChanged<ClasificadorCodigoData>? onSelected;

  const ClasificadoresView({super.key, this.onSelected});

  @override
  State<ClasificadoresView> createState() => _ClasificadoresViewState();
}

class _ClasificadoresViewState extends State<ClasificadoresView> {
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
  }

  // ========================================================
  // BÚSQUEDA
  // ========================================================

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }

      _params = _params.copyWith(page: 1, search: value.trim());

      _loadClasificadores();
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    _params = _params.copyWith(page: 1, search: '', codigo: '');

    _loadClasificadores();
  }

  // ========================================================
  // PAGINACIÓN
  // ========================================================

  void _previousPage() {
    if (_params.page <= 1) {
      return;
    }

    _params = _params.copyWith(page: _params.page - 1);

    _loadClasificadores();
  }

  void _nextPage(ClasificadoresState state) {
    if (!state.hasNextPage) {
      return;
    }

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

  void _showClasificadorDetail(ClasificadorCodigoData clasificador) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _ClasificadorDetailContent(
              clasificador: clasificador,
              scrollController: scrollController,
              onSelected: () {
                Navigator.of(sheetContext).pop();

                if (widget.onSelected != null) {
                  widget.onSelected!(clasificador);
                  return;
                }

                Navigator.of(this.context).pop(clasificador);
              },
            );
          },
        );
      },
    );
  }

  // ========================================================
  // ERROR
  // ========================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClasificadoresBloc, ClasificadoresState>(
      listenWhen: (previous, current) {
        return previous.clasificadorCodigoResponse !=
            current.clasificadorCodigoResponse;
      },
      listener: (context, state) {
        final response = state.clasificadorCodigoResponse;

        if (response is Success<ApiResponse<ClasificadorCodigoData>>) {
          final clasificador = response.data.data;

          if (clasificador != null) {
            _showClasificadorDetail(clasificador);
          }
        }

        if (response is ErrorData<ApiResponse<ClasificadorCodigoData>>) {
          _showError(response.fullMessage);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Clasificador de ocurrencias')),
          body: Column(
            children: [
              _SearchSection(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
              Expanded(child: _buildContent(state)),
            ],
          ),
        );
      },
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
      return _ErrorContent(
        message: response.fullMessage,
        onRetry: _loadClasificadores,
      );
    }

    if (clasificadores.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 160), _EmptyContent()],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: clasificadores.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final clasificador = clasificadores[index];

                return _ClasificadorCard(
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
        _PaginationSection(
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

class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchSection({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por código o nombre',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.close),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _ClasificadorCard extends StatelessWidget {
  final ClasificadorCodigoData clasificador;
  final bool isLoading;
  final VoidCallback onTap;

  const _ClasificadorCard({
    required this.clasificador,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final categoriaEspecifica = clasificador.categoriaEspecifica;

    final categoriaGenerica = categoriaEspecifica?.categoriaGenerica;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  clasificador.codigo.substring(
                    0,
                    clasificador.codigo.length >= 2
                        ? 2
                        : clasificador.codigo.length,
                  ),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clasificador.codigo,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clasificador.nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (categoriaEspecifica != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        categoriaEspecifica.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (categoriaGenerica != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        categoriaGenerica.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (clasificador.requiereAutor)
                          const _RequirementChip(label: 'Autor'),
                        if (clasificador.requiereVictima)
                          const _RequirementChip(label: 'Víctima'),
                        if (clasificador.requiereConductor)
                          const _RequirementChip(label: 'Conductor'),
                        if (clasificador.requiereDatosPnp)
                          const _RequirementChip(label: 'Datos PNP'),
                        if (clasificador.requiereDescripcion)
                          const _RequirementChip(label: 'Descripción'),
                        if (clasificador.reglas.isNotEmpty)
                          _RequirementChip(
                            label: '${clasificador.reglas.length} reglas',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  final String label;

  const _RequirementChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaginationSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;

  final bool hasPreviousPage;
  final bool hasNextPage;
  final bool isLoading;

  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const _PaginationSection({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.isLoading,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: hasPreviousPage && !isLoading ? onPreviousPage : null,
              tooltip: 'Página anterior',
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Página $currentPage de $totalPages',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$totalItems clasificadores',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                onPressed: hasNextPage ? onNextPage : null,
                tooltip: 'Página siguiente',
                icon: const Icon(Icons.chevron_right),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClasificadorDetailContent extends StatelessWidget {
  final ClasificadorCodigoData clasificador;
  final ScrollController scrollController;
  final VoidCallback onSelected;

  const _ClasificadorDetailContent({
    required this.clasificador,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoriaEspecifica = clasificador.categoriaEspecifica;

    final categoriaGenerica = categoriaEspecifica?.categoriaGenerica;

    final version = categoriaGenerica?.version;

    return Column(
      children: [
        Container(
          width: 42,
          height: 4,
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                clasificador.codigo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                clasificador.nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (clasificador.descripcion != null) ...[
                const SizedBox(height: 12),
                Text(clasificador.descripcion!),
              ],
              const SizedBox(height: 24),
              _DetailField(
                label: 'Categoría específica',
                value: categoriaEspecifica?.nombre ?? '—',
              ),
              _DetailField(
                label: 'Categoría genérica',
                value: categoriaGenerica?.nombre ?? '—',
              ),
              _DetailField(label: 'Versión', value: version?.nombre ?? '—'),
              _DetailField(
                label: 'Resolución',
                value: version?.resolucion ?? '—',
              ),
              const SizedBox(height: 16),
              Text(
                'Datos requeridos',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _BooleanRequirement(
                label: 'Autor',
                value: clasificador.requiereAutor,
              ),
              _BooleanRequirement(
                label: 'Víctima',
                value: clasificador.requiereVictima,
              ),
              _BooleanRequirement(
                label: 'Conductor',
                value: clasificador.requiereConductor,
              ),
              _BooleanRequirement(
                label: 'Datos de la PNP',
                value: clasificador.requiereDatosPnp,
              ),
              _BooleanRequirement(
                label: 'Descripción adicional',
                value: clasificador.requiereDescripcion,
              ),
              if (clasificador.reglas.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Reglas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...clasificador.reglas.map(
                  (regla) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.rule_outlined),
                    title: Text(regla.clave),
                    subtitle: regla.descripcion != null
                        ? Text(regla.descripcion!)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSelected,
                icon: const Icon(Icons.check),
                label: const Text('Seleccionar modalidad'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;

  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}

class _BooleanRequirement extends StatelessWidget {
  final String label;
  final bool value;

  const _BooleanRequirement({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        value ? Icons.check_circle : Icons.remove_circle_outline,
        color: value
            ? Colors.green
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: Text(value ? 'Requerido' : 'No requerido'),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.manage_search,
          size: 70,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'No se encontraron clasificadores.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
