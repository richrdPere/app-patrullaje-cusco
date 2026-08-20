import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';

class ClasificadorDetailSheet extends StatelessWidget {
  final ClasificadorCodigoData clasificador;
  final ScrollController scrollController;
  final VoidCallback onSelected;

  const ClasificadorDetailSheet({
    super.key,
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
                    title: Text(_formatEnum(regla.clave)),
                    subtitle: regla.descripcion == null
                        ? null
                        : Text(regla.descripcion!),
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
                icon: const Icon(Icons.check_rounded),
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
        value ? Icons.check_circle_rounded : Icons.remove_circle_outline,
        color: value
            ? Colors.green
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: Text(value ? 'Requerido' : 'No requerido'),
    );
  }
}

String _formatEnum(String value) {
  return value
      .toLowerCase()
      .split('_')
      .where((item) => item.isNotEmpty)
      .map((item) => '${item[0].toUpperCase()}${item.substring(1)}')
      .join(' ');
}
