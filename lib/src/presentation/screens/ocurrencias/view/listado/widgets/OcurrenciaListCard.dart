import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';

class OcurrenciaListCard extends StatelessWidget {
  final OcurrenciaPaginatedItem ocurrencia;
  final VoidCallback onTap;

  const OcurrenciaListCard({
    super.key,
    required this.ocurrencia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final estadoColor = _getEstadoColor(context, ocurrencia.estado);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ocurrencia.numeroOcurrencia,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${ocurrencia.codigoClasificador} · '
                          '${ocurrencia.nombreClasificador}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OcurrenciaChip(
                    label: _formatEnum(ocurrencia.estado),
                    color: estadoColor,
                  ),
                  _OcurrenciaChip(
                    label: _formatEnum(ocurrencia.turno),
                    icon: _getTurnoIcon(ocurrencia.turno),
                    color: colors.secondary,
                  ),
                  _OcurrenciaChip(
                    label: _formatEnum(ocurrencia.tipoPatrullaje),
                    icon: Icons.directions_car_outlined,
                    color: colors.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _OcurrenciaInfoRow(
                icon: Icons.calendar_today_outlined,
                text: _formatDate(ocurrencia.fechaOcurrencia),
              ),
              const SizedBox(height: 7),
              _OcurrenciaInfoRow(
                icon: Icons.person_outline_rounded,
                text: ocurrencia.nombreSereno,
              ),
              if (ocurrencia.direccion?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 7),
                _OcurrenciaInfoRow(
                  icon: Icons.location_on_outlined,
                  text: ocurrencia.direccion!,
                ),
              ],
              if (ocurrencia.datosImportantes?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ocurrencia.datosImportantes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OcurrenciaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const _OcurrenciaChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OcurrenciaInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OcurrenciaInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

Color _getEstadoColor(BuildContext context, String estado) {
  final colors = Theme.of(context).colorScheme;

  switch (estado.toUpperCase()) {
    case 'BORRADOR':
      return Colors.orange;

    case 'ENVIADO':
      return Colors.blue;

    case 'OBSERVADO':
      return Colors.deepOrange;

    case 'VALIDADO':
      return Colors.green;

    case 'ANULADO':
      return colors.error;

    default:
      return colors.primary;
  }
}

IconData _getTurnoIcon(String turno) {
  switch (turno.toUpperCase()) {
    case 'MAÑANA':
      return Icons.wb_sunny_outlined;

    case 'TARDE':
      return Icons.light_mode_outlined;

    case 'NOCHE':
      return Icons.nightlight_outlined;

    default:
      return Icons.schedule_rounded;
  }
}

String _formatEnum(String value) {
  if (value.trim().isEmpty) return 'Sin especificar';

  return value
      .toLowerCase()
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);

  if (parsed == null) return value;

  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');

  return '$day/$month/${parsed.year}';
}

