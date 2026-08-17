import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/widgets/alerta_icon_badge.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final int alertasNoLeidas;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.alertasNoLeidas = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      elevation: 5,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 35), // 🔥 más grande
          label: 'Reporte',
        ),
        // BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: 'Ocurrencias'),
        BottomNavigationBarItem(
          // icon: Icon(Icons.notifications),
          icon: AlertaIconBadge(
            cantidad: alertasNoLeidas,
            seleccionado: currentIndex == 4,
            // iconColor: Colors.grey
          ),
          label: 'Alertas',
        ),
      ],
    );
  }
}
