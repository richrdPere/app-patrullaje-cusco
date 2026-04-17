import 'package:flutter/material.dart';

class MenuBottom extends StatefulWidget {
  static const name = 'home-screen';

  const MenuBottom({super.key});

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  int currentIndex = 0;

  // Tus páginas
  // final List<Widget> pages = [
  //   const HomeContent(),
  //   const MapaPage(),
  //   const ReporteIncidentePage(),
  //   const UsuariosPage(),
  //   const AlertasPage(),
  // ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
