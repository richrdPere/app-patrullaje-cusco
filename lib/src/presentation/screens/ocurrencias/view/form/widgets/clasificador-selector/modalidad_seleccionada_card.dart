import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class ModalidadSeleccionadaCard extends StatelessWidget {
  final ModalidadClasificadorModel modalidad;

  const ModalidadSeleccionadaCard({super.key, required this.modalidad});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final requerimientos = <String>[
      if (modalidad.requiereAutor) 'Autor',
      if (modalidad.requiereVictima) 'Víctima',
      if (modalidad.requiereConductor) 'Conductor',
      if (modalidad.requiereDatosPnp) 'Datos PNP',
      if (modalidad.requiereDescripcion) 'Descripción',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  modalidad.codigo,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  modalidad.nombre,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.check_circle_rounded),
            ],
          ),

          if (modalidad.descripcion != null) ...[
            const SizedBox(height: 10),
            Text(modalidad.descripcion!, style: theme.textTheme.bodySmall),
          ],

          if (requerimientos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Información requerida',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: requerimientos
                  .map(
                    (item) => Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(item),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
