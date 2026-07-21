import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/home_quick_action.dart';

class HomeQuickActions extends StatelessWidget {
  final int? patrullajeId;
  final int? zonaId;
  final bool patrullajeActivo;

  const HomeQuickActions({
    super.key,
    required this.patrullajeId,
    required this.zonaId,
    required this.patrullajeActivo,
  });

  @override
  Widget build(BuildContext context) {
    final puedeConsultarPatrullaje =
        patrullajeActivo && patrullajeId != null && patrullajeId! > 0;

    final puedeConsultarIncidencias =
        puedeConsultarPatrullaje && zonaId != null && zonaId! > 0;

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 24,
      runSpacing: 20,
      children: [
        // ======================================================
        // MAPA
        // ======================================================
        HomeQuickAction(
          icon: Icons.map_outlined,
          label: 'Ver mapa',
          onTap: () {
            context.goNamed('mapa');
          },
        ),

        // ======================================================
        // ALERTAS
        // ======================================================
        HomeQuickAction(
          icon: Icons.warning_amber_rounded,
          label: 'Alertas',
          onTap: () {
            context.goNamed('alertas');
          },
        ),

        // ======================================================
        // HISTORIAL
        // ======================================================
        HomeQuickAction(
          icon: Icons.history_rounded,
          label: 'Historial',
          enabled: puedeConsultarPatrullaje,
          onTap: () {
            _openHistorial(context);
          },
        ),

        // ======================================================
        // ZONA
        // ======================================================
        HomeQuickAction(
          icon: Icons.location_city_outlined,
          label: 'Zona',
          enabled: puedeConsultarPatrullaje,
          onTap: () {
            _showPendingOption(context, 'Información de la zona');
          },
        ),

        // ======================================================
        // INCIDENCIAS
        // ======================================================
        HomeQuickAction(
          icon: Icons.report_outlined,
          label: 'Incidencias',
          enabled: puedeConsultarIncidencias,
          onTap: () {
            _openIncidenciasContexto(context);
          },
        ),

        // ======================================================
        // TUTORIALES
        // ======================================================
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

  // ======================================================
  // ABRIR HISTORIAL
  // ======================================================
  void _openHistorial(BuildContext context) {
    final id = patrullajeId;

    if (id == null || id <= 0) {
      _showMessage(
        context,
        'No existe un patrullaje disponible para consultar.',
      );

      return;
    }

    context.pushNamed(
      'historial_patrullaje',
      pathParameters: {'patrullajeId': id.toString()},
    );
  }

  // ======================================================
  // ABRIR INCIDENCIAS DEL CONTEXTO
  // ======================================================
  void _openIncidenciasContexto(BuildContext context) {
    final currentPatrullajeId = patrullajeId;
    final currentZonaId = zonaId;

    if (!patrullajeActivo) {
      _showMessage(
        context,
        'Debes tener un patrullaje activo para consultar incidencias.',
      );

      return;
    }

    if (currentPatrullajeId == null || currentPatrullajeId <= 0) {
      _showMessage(
        context,
        'No existe un patrullaje disponible para consultar.',
      );

      return;
    }

    if (currentZonaId == null || currentZonaId <= 0) {
      _showMessage(context, 'El patrullaje actual no tiene una zona asignada.');

      return;
    }

    context.pushNamed(
      'incidencias_contexto',
      pathParameters: {
        'patrullajeId': currentPatrullajeId.toString(),
        'zonaId': currentZonaId.toString(),
      },
    );
  }

  // ======================================================
  // OPCIÓN PENDIENTE
  // ======================================================
  void _showPendingOption(BuildContext context, String option) {
    _showMessage(context, '$option estará disponible próximamente.');
  }

  // ======================================================
  // MENSAJE
  // ======================================================
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
