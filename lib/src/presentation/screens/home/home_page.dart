import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/alertas_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/home_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/reporte_incidente_dialog.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_page.dart';
//import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/reporte_incidente_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/usuarios/usuarios_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_bottom_navigation.dart';

class HomePage extends StatefulWidget {
  static const name = 'home-screen';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  // Tus páginas
  final List<Widget> pages = [
    const HomeContent(),
    const MapaPage(),
    //const ReporteIncidentePage(),
    const UsuariosPage(),
    const AlertasPage(),
  ];

  void onItemTapped(int index) {
    // REPORTE
    if (index == 2) {
      _showReporteDialog();

      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _showReporteDialog() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(),
      // body: pages[currentIndex],
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ), // No reconstruye las páginas al cambiar
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
