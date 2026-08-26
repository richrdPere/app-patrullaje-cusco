import 'package:flutter/material.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Widgets
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/widgets/clasificador-selector/loading_clasificador.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/widgets/clasificador-selector/modalidad_seleccionada_card.dart';

class ClasificadorOcurrenciaSelector extends StatelessWidget {
  final ClasificadorArbolData? arbol;
  final OcurrenciaFormController controller;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onReload;

  const ClasificadorOcurrenciaSelector({
    super.key,
    required this.arbol,
    required this.controller,
    required this.isLoading,
    required this.errorMessage,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && (arbol == null || arbol!.isEmpty)) {
      return const LoadingClasificador();
    }

    if (errorMessage != null && (arbol == null || arbol!.isEmpty)) {
      return ClasificadorError(message: errorMessage!, onRetry: onReload);
    }

    if (arbol == null || arbol!.isEmpty) {
      return ClasificadorEmpty(onReload: onReload);
    }

    final categoriasGenericas =
        arbol!.categorias.where((categoria) => categoria.estado).toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));

    final categoriaGenerica = _findCategoriaGenerica(
      categoriasGenericas,
      controller.categoriaGenericaSeleccionada?.id,
    );

    final categoriasEspecificas =
        categoriaGenerica?.categoriasEspecificas
            .where((categoria) => categoria.estado)
            .toList() ??
        <CategoriaEspecificaModel>[];

    categoriasEspecificas.sort((a, b) => a.orden.compareTo(b.orden));

    final categoriaEspecifica = _findCategoriaEspecifica(
      categoriasEspecificas,
      controller.categoriaEspecificaSeleccionada?.id,
    );

    final modalidades =
        categoriaEspecifica?.modalidades
            .where((modalidad) => modalidad.estado)
            .toList() ??
        <ModalidadClasificadorModel>[];

    modalidades.sort((a, b) => a.orden.compareTo(b.orden));

    final modalidadSeleccionada = _findModalidad(
      modalidades,
      controller.modalidadSeleccionada?.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona progresivamente la categoría y modalidad correspondiente a la ocurrencia.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 16),

        // ====================================================
        // NIVEL 1: CATEGORÍA GENÉRICA
        // ====================================================
        DropdownButtonFormField<int>(
          key: const ValueKey('categoria_generica'),
          initialValue: categoriaGenerica?.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Categoría general *',
            hintText: 'Selecciona una categoría',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items: categoriasGenericas
              .map(
                (categoria) => DropdownMenuItem<int>(
                  value: categoria.id,
                  child: Text(
                    '${categoria.codigo} - '
                    '${categoria.nombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            final categoria = _findCategoriaGenerica(categoriasGenericas, id);

            controller.seleccionarCategoriaGenerica(categoria);
          },
          validator: (value) {
            if (value == null) {
              return 'Selecciona una categoría general.';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // ====================================================
        // NIVEL 2: CATEGORÍA ESPECÍFICA
        // ====================================================
        DropdownButtonFormField<int>(
          /*
           * La key fuerza la reconstrucción cuando cambia
           * la categoría genérica.
           */
          key: ValueKey(
            'categoria_especifica_'
            '${categoriaGenerica?.id}',
          ),
          initialValue: categoriaEspecifica?.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Categoría específica *',
            hintText: 'Selecciona una categoría específica',
            prefixIcon: Icon(Icons.subdirectory_arrow_right_rounded),
            border: OutlineInputBorder(),
          ),
          items: categoriasEspecificas
              .map(
                (categoria) => DropdownMenuItem<int>(
                  value: categoria.id,
                  child: Text(
                    '${categoria.codigo} - '
                    '${categoria.nombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: categoriaGenerica == null
              ? null
              : (id) {
                  final categoria = _findCategoriaEspecifica(
                    categoriasEspecificas,
                    id,
                  );

                  controller.seleccionarCategoriaEspecifica(categoria);
                },
          validator: (value) {
            if (value == null) {
              return 'Selecciona una categoría específica.';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // ====================================================
        // NIVEL 3: MODALIDAD FINAL
        // ====================================================
        DropdownButtonFormField<int>(
          /*
           * La key fuerza la reconstrucción cuando cambia
           * la categoría específica.
           */
          key: ValueKey(
            'modalidad_'
            '${categoriaEspecifica?.id}',
          ),
          initialValue: modalidadSeleccionada?.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Código clasificador *',
            hintText: 'Selecciona la modalidad',
            prefixIcon: Icon(Icons.numbers_rounded),
            border: OutlineInputBorder(),
          ),
          items: modalidades
              .map(
                (modalidad) => DropdownMenuItem<int>(
                  value: modalidad.id,
                  child: Text(
                    '${modalidad.codigo} - '
                    '${modalidad.nombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: categoriaEspecifica == null
              ? null
              : (id) {
                  final modalidad = _findModalidad(modalidades, id);

                  controller.seleccionarModalidad(modalidad);
                },
          validator: (value) {
            if (value == null) {
              return 'Selecciona el código clasificador.';
            }

            return null;
          },
        ),

        if (controller.modalidadSeleccionada != null) ...[
          const SizedBox(height: 14),

          ModalidadSeleccionadaCard(
            modalidad: controller.modalidadSeleccionada!,
          ),
        ],
      ],
    );
  }

  CategoriaGenericaModel? _findCategoriaGenerica(
    List<CategoriaGenericaModel> items,
    int? id,
  ) {
    if (id == null) return null;

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  CategoriaEspecificaModel? _findCategoriaEspecifica(
    List<CategoriaEspecificaModel> items,
    int? id,
  ) {
    if (id == null) return null;

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  ModalidadClasificadorModel? _findModalidad(
    List<ModalidadClasificadorModel> items,
    int? id,
  ) {
    if (id == null) return null;

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }
}
