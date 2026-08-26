import 'package:flutter/material.dart';

class LoadingClasificador extends StatelessWidget {
  const LoadingClasificador({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Cargando clasificadores...'),
          ],
        ),
      ),
    );
  }
}

class ClasificadorError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ClasificadorError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class ClasificadorEmpty extends StatelessWidget {
  final VoidCallback onReload;

  const ClasificadorEmpty({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'No existen códigos clasificadores disponibles.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onReload,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Actualizar'),
        ),
      ],
    );
  }
}
