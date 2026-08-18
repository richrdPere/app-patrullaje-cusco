import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

class FiltersSection extends StatelessWidget {
  final TextEditingController searchController;

  final PatrullajeSerenoQueryParams params;

  final VoidCallback onSearch;
  final ValueChanged<PatrullajeEstadoFilter?> onEstadoChanged;
  final ValueChanged<int> onLimitChanged;
  final VoidCallback onClear;

  const FiltersSection({
    super.key,
    required this.searchController,
    required this.params,
    required this.onSearch,
    required this.onEstadoChanged,
    required this.onLimitChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              onSearch();
            },
            decoration: InputDecoration(
              hintText: 'Buscar patrullaje...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<PatrullajeEstadoFilter?>(
                  value: params.estado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<PatrullajeEstadoFilter?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: PatrullajeEstadoFilter.programado,
                      child: Text('Programado'),
                    ),
                    DropdownMenuItem(
                      value: PatrullajeEstadoFilter.asignado,
                      child: Text('Asignado'),
                    ),
                    DropdownMenuItem(
                      value: PatrullajeEstadoFilter.aceptado,
                      child: Text('Aceptado'),
                    ),
                    DropdownMenuItem(
                      value: PatrullajeEstadoFilter.enCurso,
                      child: Text('En curso'),
                    ),
                    DropdownMenuItem(
                      value: PatrullajeEstadoFilter.finalizado,
                      child: Text('Finalizado'),
                    ),
                  ],
                  onChanged: onEstadoChanged,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<int>(
                  value: params.limit,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mostrar',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5')),
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 20, child: Text('20')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onLimitChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
