import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.movie_outlined, color: colors.primary),
          const SizedBox(width: 5),
          Text('Sis Patrullaje', style: titleStyle),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ],
    );
  }

  // 🔥 OBLIGATORIO
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}