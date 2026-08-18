import 'package:flutter/material.dart';

class ResultsHeader extends StatelessWidget {
  final int totalItems;
  final int currentPage;
  final int totalPages;

  const ResultsHeader({
    super.key,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final label = totalItems == 1 ? '1 patrullaje' : '$totalItems patrullajes';

    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),

        const Spacer(),

        if (totalPages > 0)
          Text(
            'Página $currentPage de $totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
