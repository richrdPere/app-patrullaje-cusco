import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/home_quick_action.dart';

class HomeQuickActions extends StatelessWidget {
  final int? patrullajeId;
  final bool patrullajeActivo;

  const HomeQuickActions({
    super.key,
    required this.patrullajeId,
    required this.patrullajeActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 24,
      runSpacing: 20,
      children: [
        HomeQuickAction(
          icon: Icons.map_outlined,
          label: 'Ver mapa',
          onTap: () {
            context.goNamed('mapa');
          },
        ),

        HomeQuickAction(
          icon: Icons.warning_amber_rounded,
          label: 'Alertas',
          onTap: () {
            context.goNamed('alertas');
          },
        ),

        HomeQuickAction(
          icon: Icons.history_rounded,
          label: 'Historial',
          enabled: patrullajeId != null,
          onTap: () {
            _openHistorial(context);
          },
        ),

        HomeQuickAction(
          icon: Icons.location_city_outlined,
          label: 'Zona',
          enabled: patrullajeId != null,
          onTap: () {
            _showPendingOption(context, 'Información de la zona');
          },
        ),

        HomeQuickAction(
          icon: Icons.report_outlined,
          label: 'Incidencias',
          enabled: patrullajeId != null,
          onTap: () {
            _showPendingOption(context, 'Listado de incidencias');
          },
        ),

        HomeQuickAction(
          icon: Icons.video_collection_outlined,
          label: 'Tutoriales',
          onTap: () {
            _showPendingOption(context, 'Tutoriales');
          },
        ),
      ],
    );
  }

  void _openHistorial(BuildContext context) {
    final id = patrullajeId;

    if (id == null || id <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No existe un patrullaje disponible para consultar.'),
          ),
        );

      return;
    }

    context.pushNamed(
      'historial_patrullaje',
      pathParameters: {'patrullajeId': id.toString()},
    );
  }

  void _showPendingOption(BuildContext context, String option) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$option estará disponible próximamente.')),
      );
  }
}
