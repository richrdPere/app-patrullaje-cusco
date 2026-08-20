import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/menu/widgets/categoria_generica_option.dart';

class ClasificadoresMenuContent extends StatelessWidget {
  final List<CategoriaGenericaOption> categorias;
  final bool isNavigating;
  final ValueChanged<CategoriaGenericaOption> onCategoriaTap;

  const ClasificadoresMenuContent({
    super.key,
    required this.categorias,
    required this.isNavigating,
    required this.onCategoriaTap,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final categoria = categorias[index];

                  return _CategoriaGenericaCard(
                    categoria: categoria,
                    enabled: !isNavigating,
                    onTap: () => onCategoriaTap(categoria),
                  );
                }, childCount: categorias.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 190,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1000) {
      return 4;
    }

    if (width >= 600) {
      return 2;
    }

    return 2;
  }
}

class _CategoriaGenericaCard extends StatelessWidget {
  final CategoriaGenericaOption categoria;
  final bool enabled;
  final VoidCallback onTap;

  const _CategoriaGenericaCard({
    required this.categoria,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadow.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: categoria.color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      categoria.icon,
                      color: categoria.color,
                      size: 25,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: categoria.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoria.codigo,
                      style: TextStyle(
                        color: categoria.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                categoria.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: Text(
                  categoria.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Text(
              //       'Ver códigos',
              //       style: theme.textTheme.labelLarge?.copyWith(
              //         color: colors.primary,
              //         fontWeight: FontWeight.w700,
              //       ),
              //     ),
              //     const SizedBox(width: 4),
              //     Icon(
              //       Icons.arrow_forward_rounded,
              //       size: 19,
              //       color: colors.primary,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
