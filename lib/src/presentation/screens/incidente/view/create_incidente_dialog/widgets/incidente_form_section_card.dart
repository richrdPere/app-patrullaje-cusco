import 'package:flutter/material.dart';

class IncidentFormSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? backgroundColor;
  final Widget? trailing;

  const IncidentFormSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: elevation,
      margin: EdgeInsets.zero,
      color: backgroundColor ?? colors.surface,
      // surfaceTintColor: Colors.transparent,
      // shadowColor: colors.shadow.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.65)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              icon: icon,
              title: title,
              subtitle: subtitle ?? '',
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }

  // ======================================================
  // TÍTULO DE SECCIÓN
  // ======================================================
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: const Color.fromARGB(255, 12, 38, 145)),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
