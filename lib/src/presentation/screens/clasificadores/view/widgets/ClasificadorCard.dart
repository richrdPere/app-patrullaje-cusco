import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/widgets/RequirementChip.dart';

class ClasificadorCard extends StatelessWidget {
  final ClasificadorCodigoData clasificador;
  final bool isLoading;
  final VoidCallback onTap;

  const ClasificadorCard({
    required this.clasificador,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final categoriaEspecifica = clasificador.categoriaEspecifica;

    final categoriaGenerica = categoriaEspecifica?.categoriaGenerica;

    final codePrefix = clasificador.codigo.substring(
      0,
      clasificador.codigo.length >= 2 ? 2 : clasificador.codigo.length,
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
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
                  codePrefix,
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
                          const RequirementChip(label: 'Autor'),
                        if (clasificador.requiereVictima)
                          const RequirementChip(label: 'Víctima'),
                        if (clasificador.requiereConductor)
                          const RequirementChip(label: 'Conductor'),
                        if (clasificador.requiereDatosPnp)
                          const RequirementChip(label: 'Datos PNP'),
                        if (clasificador.requiereDescripcion)
                          const RequirementChip(label: 'Descripción'),
                        if (clasificador.reglas.isNotEmpty)
                          RequirementChip(
                            label: '${clasificador.reglas.length} reglas',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLoading)
                const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
