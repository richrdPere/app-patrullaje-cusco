import 'package:flutter/material.dart';

class PaginationSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final bool isLoading;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const PaginationSection({super.key, 
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
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed:
                  hasPreviousPage && !isLoading
                      ? onPreviousPage
                      : null,
              tooltip: 'Página anterior',
              icon: const Icon(
                Icons.chevron_left_rounded,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Página $currentPage de $totalPages',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$totalItems clasificadores',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              IconButton(
                onPressed:
                    hasNextPage ? onNextPage : null,
                tooltip: 'Página siguiente',
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.manage_search_rounded,
          size: 70,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          'No se encontraron clasificadores.',
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorContent({super.key, 
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color:
                  Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon:
                  const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}