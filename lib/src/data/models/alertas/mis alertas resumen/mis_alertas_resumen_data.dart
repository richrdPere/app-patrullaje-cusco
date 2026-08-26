import 'package:sis_patrullaje_cusco/src/data/models/alertas/mis%20alertas%20resumen/alerta_resumen_prioridades.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/mis%20alertas%20resumen/alertas_resumen_estados.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/mis%20alertas%20resumen/ultima_alerta_resumen_data.dart';

class MisAlertasResumenData {
  final int total;
  final int noLeidas;
  final int porAtender;

  final AlertasResumenEstados estados;
  final AlertasResumenPrioridades prioridades;

  final int requierenConfirmacion;
  final int expiradas;

  final UltimaAlertaResumenData? ultimaAlerta;

  const MisAlertasResumenData({
    required this.total,
    required this.noLeidas,
    required this.porAtender,
    required this.estados,
    required this.prioridades,
    required this.requierenConfirmacion,
    required this.expiradas,
    this.ultimaAlerta,
  });

  const MisAlertasResumenData.empty()
    : total = 0,
      noLeidas = 0,
      porAtender = 0,
      estados = const AlertasResumenEstados.empty(),
      prioridades = const AlertasResumenPrioridades.empty(),
      requierenConfirmacion = 0,
      expiradas = 0,
      ultimaAlerta = null;

  factory MisAlertasResumenData.fromJson(Map<String, dynamic> json) {
    return MisAlertasResumenData(
      total: _parseInt(json['total']),
      noLeidas: _parseInt(json['no_leidas']),
      porAtender: _parseInt(json['por_atender']),
      estados: json['estados'] is Map
          ? AlertasResumenEstados.fromJson(
              Map<String, dynamic>.from(json['estados'] as Map),
            )
          : const AlertasResumenEstados.empty(),
      prioridades: json['prioridades'] is Map
          ? AlertasResumenPrioridades.fromJson(
              Map<String, dynamic>.from(json['prioridades'] as Map),
            )
          : const AlertasResumenPrioridades.empty(),
      requierenConfirmacion: _parseInt(json['requieren_confirmacion']),
      expiradas: _parseInt(json['expiradas']),
      ultimaAlerta: json['ultima_alerta'] is Map
          ? UltimaAlertaResumenData.fromJson(
              Map<String, dynamic>.from(json['ultima_alerta'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'no_leidas': noLeidas,
      'por_atender': porAtender,
      'estados': estados.toJson(),
      'prioridades': prioridades.toJson(),
      'requieren_confirmacion': requierenConfirmacion,
      'expiradas': expiradas,
      'ultima_alerta': ultimaAlerta?.toJson(),
    };
  }

  bool get tieneAlertas => total > 0;

  bool get tieneAlertasNoLeidas => noLeidas > 0;

  bool get tieneAlertasPorAtender => porAtender > 0;

  bool get tieneAlertasExpiradas => expiradas > 0;

  bool get tieneAlertasQueRequierenConfirmacion {
    return requierenConfirmacion > 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
