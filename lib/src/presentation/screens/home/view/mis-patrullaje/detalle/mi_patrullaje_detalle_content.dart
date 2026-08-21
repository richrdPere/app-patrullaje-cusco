// patrullaje_detalle_content.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Modelo
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado%20-%20historial%20patrullaje/historial_patrullaje_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/patrullaje_information_section.dart';

// Widgets
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/operational_summary_card.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/patrullaje_header_card.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/section_card.dart';

// Secciones embebidas

enum PatrullajeDetalleSection { informacion, historial, incidencias }

class PatrullajeDetalleContent extends StatefulWidget {
  final PatrullajeListadoData patrullaje;

  const PatrullajeDetalleContent({super.key, required this.patrullaje});

  @override
  State<PatrullajeDetalleContent> createState() =>
      _PatrullajeDetalleContentState();
}

class _PatrullajeDetalleContentState extends State<PatrullajeDetalleContent> {
  PatrullajeDetalleSection _selectedSection =
      PatrullajeDetalleSection.informacion;

  PatrullajeListadoData get patrullaje {
    return widget.patrullaje;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Detalle del patrullaje'),
        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.close_rounded),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ===============================================
            // SELECTOR DE SECCIÓN
            // ===============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<PatrullajeDetalleSection>(
                  showSelectedIcon: false,
                  selected: {_selectedSection},
                  segments: const [
                    ButtonSegment(
                      value: PatrullajeDetalleSection.informacion,
                      icon: Icon(Icons.info_outline),
                      label: Text('Información'),
                    ),
                    ButtonSegment(
                      value: PatrullajeDetalleSection.historial,
                      icon: Icon(Icons.history_rounded),
                      label: Text('Historial'),
                    ),
                    ButtonSegment(
                      value: PatrullajeDetalleSection.incidencias,
                      icon: Icon(Icons.report_outlined),
                      label: Text('Incidencias'),
                    ),
                  ],
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) {
                      return;
                    }

                    setState(() {
                      _selectedSection = selection.first;
                    });
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ===============================================
            // CONTENIDO
            // ===============================================
            Expanded(
              child: IndexedStack(
                index: _selectedSection.index,
                children: [
                  // 1. Información
                  PatrullajeInformationSection(patrullaje: patrullaje),

                  // 2. Historial
                  HistorialPatrullajePage(
                    patrullajeId: patrullaje.id,
                    //embedded: true,
                  ),

                  // 3. Incidencias
                  // IncidenciasContextoPage(
                  //   patrullajeId: patrullaje.id,
                  //   zonaId: patrullaje.zonaId,
                  //   // embedded: true,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
