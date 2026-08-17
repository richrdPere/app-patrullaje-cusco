import 'package:flutter/material.dart';

class OcurrenciaEmpty extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final Future<void> Function() onRefresh;

  const OcurrenciaEmpty({
    required this.hasFilters,
    required this.onClearFilters,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 80),
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.assignment_outlined,
            size: 72,
            color: colors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilters
                ? 'No se encontraron ocurrencias'
                : 'No hay ocurrencias registradas',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Intenta modificar o eliminar los filtros aplicados.'
                : 'Las ocurrencias que registres aparecerán aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OcurrenciaError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OcurrenciaError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 70, color: colors.error),
            const SizedBox(height: 18),
            Text(
              'No se pudieron cargar las ocurrencias',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
