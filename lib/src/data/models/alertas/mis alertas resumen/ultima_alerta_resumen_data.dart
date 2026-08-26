import 'package:sis_patrullaje_cusco/src/data/models/alertas/mis%20alertas%20resumen/ultima_alerta_detalle_data.dart';

class UltimaAlertaResumenData {
  final int id;
  final int alertaId;
  final String estado;

  final DateTime? fechaRecibida;
  final DateTime? fechaLeida;
  final DateTime? fechaRespuesta;
  final DateTime? fechaAtendida;

  final UltimaAlertaDetalleData alerta;

  const UltimaAlertaResumenData({
    required this.id,
    required this.alertaId,
    required this.estado,
    this.fechaRecibida,
    this.fechaLeida,
    this.fechaRespuesta,
    this.fechaAtendida,
    required this.alerta,
  });

  factory UltimaAlertaResumenData.fromJson(Map<String, dynamic> json) {
    final rawAlerta = json['alerta'];

    return UltimaAlertaResumenData(
      id: _parseInt(json['id']),
      alertaId: _parseInt(json['alerta_id']),
      estado: json['estado']?.toString().trim() ?? '',
      fechaRecibida: _parseDateTime(json['fecha_recibida']),
      fechaLeida: _parseDateTime(json['fecha_leida']),
      fechaRespuesta: _parseDateTime(json['fecha_respuesta']),
      fechaAtendida: _parseDateTime(json['fecha_atendida']),
      alerta: UltimaAlertaDetalleData.fromJson(
        rawAlerta is Map
            ? Map<String, dynamic>.from(rawAlerta)
            : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alerta_id': alertaId,
      'estado': estado,
      'fecha_recibida': fechaRecibida?.toIso8601String(),
      'fecha_leida': fechaLeida?.toIso8601String(),
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
      'fecha_atendida': fechaAtendida?.toIso8601String(),
      'alerta': alerta.toJson(),
    };
  }

  bool get estaLeida {
    return fechaLeida != null || estado == 'LEIDA';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final rawValue = value?.toString().trim();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
