import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/app_widgets/app_summary_chip.dart';

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
    // final label = totalItems == 1 ? '1 patrullaje' : '$totalItems patrullajes';

    return Row(
      children: [
        // Text(
        //   label,
        //   style: Theme.of(
        //     context,
        //   ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        // ),
        AppSummaryChip(
          total: totalItems,
          singularLabel: 'patrullaje',
          pluralLabel: 'patrullajes',
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          icon: Icons.route_outlined,
          isSearching: false,
          search: '',
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
