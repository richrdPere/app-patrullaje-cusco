import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_quick_action.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_quick_actions_options.dart';

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
    final colors = Theme.of(context).colorScheme;

    // ========================================================
    // ARREGLO DE WIDGETS
    // ========================================================

    final List<Widget> actionWidgets = homeQuickActionOptions.map((option) {
      final enabled = _isOptionEnabled(option);

      return HomeQuickAction(
        icon: option.icon,
        label: option.label,
        enabled: enabled,
        onTap: () {
          _onOptionTap(context, option);
        },
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actionWidgets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          mainAxisExtent: 88,
        ),
        itemBuilder: (context, index) {
          return actionWidgets[index];
        },
      ),
    );
  }

  // ==========================================================
  // VERIFICAR SI LA OPCIÓN ESTÁ HABILITADA
  // ==========================================================
  bool _isOptionEnabled(HomeQuickActionOption option) {
    final hasPatrullaje =
        patrullajeActivo && patrullajeId != null && patrullajeId! > 0;

    final hasZona = zonaId != null && zonaId! > 0;

    switch (option.requirement) {
      case HomeQuickActionRequirement.always:
        return true;

      case HomeQuickActionRequirement.patrullaje:
        return hasPatrullaje;

      case HomeQuickActionRequirement.patrullajeAndZona:
        return hasPatrullaje && hasZona;
    }
  }

  // ==========================================================
  // ACCIÓN DE CADA OPCIÓN
  // ==========================================================
  void _onOptionTap(BuildContext context, HomeQuickActionOption option) {
    switch (option.type) {
      case HomeQuickActionType.mapa:
        context.goNamed('mapa');
        break;

      case HomeQuickActionType.alertas:
        context.goNamed('alertas');
        break;

      case HomeQuickActionType.historial:
        _openHistorial(context);
        break;

      case HomeQuickActionType.zona:
        _openZona(context);
        break;

      case HomeQuickActionType.incidenciasContexto:
        context.pushNamed('mis_incidencias');
        break;

      case HomeQuickActionType.clasificadores:
        context.pushNamed('clasificadores');
        break;

      case HomeQuickActionType.ocurrencias:
        context.goNamed('ocurrencias');
        break;

      case HomeQuickActionType.tutoriales:
        _showPendingOption(context, 'Tutoriales');
        break;
      case HomeQuickActionType.acciones:
        _showPendingOption(context, 'Mas Acciones');
        break;
      case HomeQuickActionType.misPatrullajes:
        context.pushNamed('mis_patrullajes');
        break;
    }
  }

  // ==========================================================
  // ABRIR HISTORIAL
  // ==========================================================
  void _openHistorial(BuildContext context) {
    final id = patrullajeId;

    if (!patrullajeActivo || id == null || id <= 0) {
      _showMessage(
        context,
        'Debes tener un patrullaje activo para consultar el historial.',
      );

      return;
    }

    context.pushNamed(
      'historial_patrullaje',
      pathParameters: {'patrullajeId': id.toString()},
    );
  }

  // ==========================================================
  // ABRIR ZONA
  // ==========================================================
  void _openZona(BuildContext context) {
    if (!patrullajeActivo) {
      _showMessage(
        context,
        'Debes tener un patrullaje activo para consultar la zona.',
      );

      return;
    }

    if (zonaId == null || zonaId! <= 0) {
      _showMessage(context, 'El patrullaje actual no tiene una zona asignada.');

      return;
    }

    // Cuando implementes su pantalla:
    //
    // context.pushNamed(
    //   'zona_detalle',
    //   pathParameters: {
    //     'zonaId': zonaId.toString(),
    //   },
    // );

    _showPendingOption(context, 'Información de la zona');
  }

  // ==========================================================
  // ABRIR INCIDENCIAS DEL CONTEXTO
  // ==========================================================
  // void _openMisIncidencias(BuildContext context) {
  //   final currentPatrullajeId = patrullajeId;

  //   // final currentZonaId = zonaId;

  //   if (!patrullajeActivo) {
  //     _showMessage(
  //       context,
  //       'Debes tener un patrullaje activo para consultar incidencias.',
  //     );

  //     return;
  //   }

  //   if (currentPatrullajeId == null || currentPatrullajeId <= 0) {
  //     _showMessage(
  //       context,
  //       'No existe un patrullaje disponible para consultar.',
  //     );

  //     return;
  //   }

  //   // if (currentZonaId == null || currentZonaId <= 0) {
  //   //   _showMessage(context, 'El patrullaje actual no tiene una zona asignada.');

  //   //   return;
  //   // }

  //   context.pushNamed(
  //     'mis_incidencias',
  //     pathParameters: {
  //       'patrullajeId': currentPatrullajeId.toString(),
  //       // 'zonaId': currentZonaId.toString(),
  //     },
  //   );
  // }

  // ==========================================================
  // OPCIÓN PENDIENTE
  // ==========================================================
  void _showPendingOption(BuildContext context, String option) {
    _showMessage(context, '$option estará disponible próximamente.');
  }

  // ==========================================================
  // MENSAJE
  // ==========================================================
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
