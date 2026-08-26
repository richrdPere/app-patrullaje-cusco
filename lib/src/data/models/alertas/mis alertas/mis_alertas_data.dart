import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_data.dart';

class MisAlertasData {
  final int id;
  final int alertaId;
  final int usuarioId;

  final String estado;

  final DateTime? fechaRecibida;
  final DateTime? fechaLeida;
  final DateTime? fechaRespuesta;
  final DateTime? fechaAtendida;

  final String? observacion;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final AlertaData alerta;

  const MisAlertasData({
    required this.id,
    required this.alertaId,
    required this.usuarioId,
    required this.estado,
    this.fechaRecibida,
    this.fechaLeida,
    this.fechaRespuesta,
    this.fechaAtendida,
    this.observacion,
    this.createdAt,
    this.updatedAt,
    required this.alerta,
  });

  factory MisAlertasData.fromJson(Map<String, dynamic> json) {
    final rawAlerta = json['alerta'];

    return MisAlertasData(
      id: _parseInt(json['id']),
      alertaId: _parseInt(json['alerta_id']),
      usuarioId: _parseInt(json['usuario_id']),
      estado: json['estado']?.toString().trim() ?? '',
      fechaRecibida: _parseDateTime(json['fecha_recibida']),
      fechaLeida: _parseDateTime(json['fecha_leida']),
      fechaRespuesta: _parseDateTime(json['fecha_respuesta']),
      fechaAtendida: _parseDateTime(json['fecha_atendida']),
      observacion: _parseNullableString(json['observacion']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      alerta: AlertaData.fromJson(
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
      'usuario_id': usuarioId,
      'estado': estado,
      'fecha_recibida': fechaRecibida?.toIso8601String(),
      'fecha_leida': fechaLeida?.toIso8601String(),
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
      'fecha_atendida': fechaAtendida?.toIso8601String(),
      'observacion': observacion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'alerta': alerta.toJson(),
    };
  }

  bool get estaLeida => fechaLeida != null || estado == 'LEIDA';

  bool get requiereConfirmacion => alerta.requiereConfirmacion;

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

  static String? _parseNullableString(dynamic value) {
    final parsedValue = value?.toString().trim();

    if (parsedValue == null || parsedValue.isEmpty) {
      return null;
    }

    return parsedValue;
  }
}
