// patrullaje_detalle_page.dart

import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/mi_patrullaje_detalle_content.dart';

class PatrullajeDetallePage extends StatelessWidget {
  final PatrullajeListadoData patrullaje;

  const PatrullajeDetallePage({super.key, required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    return PatrullajeDetalleContent(patrullaje: patrullaje);
  }
}
