import 'package:flutter/material.dart';

class AppSummaryChip extends StatelessWidget {
  final int total;

  final String singularLabel;
  final String pluralLabel;

  final IconData icon;

  final bool isSearching;
  final String search;

  final EdgeInsetsGeometry padding;

  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  const AppSummaryChip({
    super.key,
    required this.total,
    required this.singularLabel,
    required this.pluralLabel,
    required this.icon,
    this.isSearching = false,
    this.search = '',
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 8),
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final text = total == 1 ? '1 $singularLabel' : '$total $pluralLabel';

    final bgColor =
        backgroundColor ?? colors.primaryContainer.withValues(alpha: 0.55);

    final effectiveBorderColor =
        borderColor ?? colors.primary.withValues(alpha: 0.20);

    final effectiveForegroundColor =
        foregroundColor ?? colors.onPrimaryContainer;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          // ==================================================
          // RESUMEN
          // ==================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: effectiveBorderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: effectiveForegroundColor),

                const SizedBox(width: 6),

                Text(
                  text,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: effectiveForegroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // TEXTO DE BÚSQUEDA
          // ==================================================
          if (isSearching && search.trim().isNotEmpty) ...[
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Resultados para “${search.trim()}”',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
