import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/reporte_incidente_dialog.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_bottom_navigation.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,

      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _getCurrentIndex(context),

        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;

            case 1:
              context.go('/mapa');
              break;

            case 2:
              _showReporteDialog(context);
              break;

            case 3:
              context.go('/usuarios');
              break;

            case 4:
              context.go('/alertas');
              break;
          }
        },
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/mapa')) {
      return 1;
    }

    if (location.startsWith('/usuarios')) {
      return 3;
    }

    if (location.startsWith('/alertas')) {
      return 4;
    }

    return 0;
  }

  Future<void> _showReporteDialog(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Reporte",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return const ReporteIncidenteDialog();
      },
    );
  }
}
