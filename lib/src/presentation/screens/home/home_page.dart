import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/home_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/usuarios/usuarios_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';
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
    const Center(child: Text('Reporte')),
    //const Center(child: Text('Chat')),
    const UsuariosPage(),
    const Center(child: Text('Notificaciones')),
  ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      // body: pages[currentIndex],
      body: IndexedStack(index: currentIndex, children: pages), // No reconstruye las páginas al cambiar  
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
