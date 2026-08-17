import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';

class OcurrenciaPaginationFooter extends StatelessWidget {
  final OcurrenciaPagination pagination;
  final int currentLimit;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSizeChanged;

  const OcurrenciaPaginationFooter({
    required this.pagination,
    required this.currentLimit,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 4),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  tooltip: 'Página anterior',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                const SizedBox(width: 14),
                Column(
                  children: [
                    Text(
                      '${pagination.currentPage} / '
                      '${pagination.totalPages}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${pagination.totalItems} registros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                IconButton.outlined(
                  tooltip: 'Página siguiente',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Mostrar:', style: theme.textTheme.bodySmall),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: currentLimit,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 20, child: Text('20')),
                    DropdownMenuItem(value: 50, child: Text('50')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onPageSizeChanged(value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
