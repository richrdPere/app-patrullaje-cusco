import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';

import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_bottom_navigation.dart';

// Ajusta estos imports según tus rutas reales
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/reporte_incidente_dialog.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AlertaBloc>().add(const GetMisAlertasResumenEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BlocBuilder<AlertaBloc, AlertaState>(
        buildWhen: (previous, current) {
          return previous.alertasNoLeidas != current.alertasNoLeidas;
        },
        builder: (context, alertaState) {
          return CustomBottomNavigation(
            currentIndex: currentIndex,
            alertasNoLeidas: alertaState.alertasNoLeidas,
            onTap: (index) {
              _onNavigationTap(context, index);
            },
          );
        },
      ),
    );
  }

  void _onNavigationTap(BuildContext context, int index) {
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
        // context.go('/usuarios');
        context.go('/ocurrencias');
        break;

      case 4:
        context.go('/alertas');

        // Solo si deseas limpiar el badge
        // inmediatamente al abrir la pantalla.
        //
        // context.read<AlertaBloc>().add(
        //   const MarcarAlertasComoLeidasEvent(),
        // );

        break;
    }
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/mapa')) {
      return 1;
    }

    if (location.startsWith('/ocurrencias')) {
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
