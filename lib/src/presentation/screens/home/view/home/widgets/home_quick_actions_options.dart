// home_quick_actions_options.dart

import 'package:flutter/material.dart';

enum HomeQuickActionType {
  misPatrullajes,
  mapa,
  alertas,
  historial,
  siguienteTurno,
  zona,
  incidenciasContexto,
  clasificadores,
  ocurrencias,
  tutoriales,
  acciones,
}

enum HomeQuickActionRequirement { always, patrullaje, patrullajeAndZona }

class HomeQuickActionOption {
  final HomeQuickActionType type;
  final IconData icon;
  final String label;
  final HomeQuickActionRequirement requirement;

  const HomeQuickActionOption({
    required this.type,
    required this.icon,
    required this.label,
    this.requirement = HomeQuickActionRequirement.always,
  });
}

const List<HomeQuickActionOption> homeQuickActionOptions = [
  HomeQuickActionOption(
    type: HomeQuickActionType.misPatrullajes,
    icon: Icons.route_outlined,
    label: 'Patrullajes',
  ),

  HomeQuickActionOption(
    type: HomeQuickActionType.zona,
    icon: Icons.room_sharp,
    label: 'Ver zona',
  ),

  HomeQuickActionOption(
    type: HomeQuickActionType.siguienteTurno,
    icon: Icons.supervised_user_circle,
    label: 'Turno ant.',
  ),

  // HomeQuickActionOption(
  //   type: HomeQuickActionType.alertas,
  //   icon: Icons.warning_amber_rounded,
  //   label: 'Alertas',
  // ),

  // HomeQuickActionOption(
  //   type: HomeQuickActionType.historial,
  //   icon: Icons.history_rounded,
  //   label: 'Historial',
  //   requirement: HomeQuickActionRequirement.patrullaje,
  // ),

  // HomeQuickActionOption(
  //   type: HomeQuickActionType.zona,
  //   icon: Icons.location_on_outlined,
  //   label: 'Zona',
  //   requirement: HomeQuickActionRequirement.patrullajeAndZona,
  // ),
  HomeQuickActionOption(
    type: HomeQuickActionType.incidenciasContexto,
    icon: Icons.report_outlined,
    label: 'Incidencias',
  ),

  // HomeQuickActionOption(
  //   type: HomeQuickActionType.ocurrencias,
  //   icon: Icons.edit_document,
  //   label: 'Ocurrencias',
  // ),
  HomeQuickActionOption(
    type: HomeQuickActionType.clasificadores,
    icon: Icons.list_alt_rounded,
    label: 'Códigos',
  ),

  HomeQuickActionOption(
    type: HomeQuickActionType.tutoriales,
    icon: Icons.video_collection_outlined,
    label: 'Tutoriales',
  ),

  HomeQuickActionOption(
    type: HomeQuickActionType.acciones,
    icon: Icons.dashboard_customize_outlined,
    label: 'Más acciones',
  ),
];
