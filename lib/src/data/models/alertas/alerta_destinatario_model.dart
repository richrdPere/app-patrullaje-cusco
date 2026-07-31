import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_model.dart';

class AlertaDestinatarioModel {
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

  final AlertaModel? alerta;

  const AlertaDestinatarioModel({
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
    this.alerta,
  });

  factory AlertaDestinatarioModel.fromJson(Map<String, dynamic> json) {
    /*
     * Algunos servicios pueden devolver:
     *
     * {
     *   "id": 5,
     *   "alerta_id": 10,
     *   "estado": "LEIDA",
     *   "alerta": {...}
     * }
     *
     * También se contempla que devuelvan la información de
     * la alerta directamente en el mismo nivel.
     */
    final alertaJson = _extractAlertaJson(json);

    return AlertaDestinatarioModel(
      id: _parseInt(json['destinatario_id'] ?? json['id']) ?? 0,
      alertaId: _parseInt(json['alerta_id'] ?? alertaJson?['id']) ?? 0,
      usuarioId: _parseInt(json['usuario_id']) ?? 0,
      estado:
          json['estado_destinatario']?.toString() ??
          json['estado']?.toString() ??
          'PENDIENTE',
      fechaRecibida: _parseDate(json['fecha_recibida']),
      fechaLeida: _parseDate(json['fecha_leida']),
      fechaRespuesta: _parseDate(json['fecha_respuesta']),
      fechaAtendida: _parseDate(json['fecha_atendida']),
      observacion: json['observacion']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      alerta: alertaJson == null ? null : AlertaModel.fromJson(alertaJson),
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
      'alerta': alerta?.toJson(),
    };
  }

  AlertaDestinatarioModel copyWith({
    int? id,
    int? alertaId,
    int? usuarioId,
    String? estado,
    DateTime? fechaRecibida,
    DateTime? fechaLeida,
    DateTime? fechaRespuesta,
    DateTime? fechaAtendida,
    String? observacion,
    DateTime? createdAt,
    DateTime? updatedAt,
    AlertaModel? alerta,
  }) {
    return AlertaDestinatarioModel(
      id: id ?? this.id,
      alertaId: alertaId ?? this.alertaId,
      usuarioId: usuarioId ?? this.usuarioId,
      estado: estado ?? this.estado,
      fechaRecibida: fechaRecibida ?? this.fechaRecibida,
      fechaLeida: fechaLeida ?? this.fechaLeida,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      fechaAtendida: fechaAtendida ?? this.fechaAtendida,
      observacion: observacion ?? this.observacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alerta: alerta ?? this.alerta,
    );
  }

  bool get estaPendiente {
    return estado == 'PENDIENTE';
  }

  bool get fueRecibida {
    return const {
      'RECIBIDA',
      'LEIDA',
      'ACEPTADA',
      'RECHAZADA',
      'ATENDIDA',
    }.contains(estado);
  }

  bool get fueLeida {
    return const {
      'LEIDA',
      'ACEPTADA',
      'RECHAZADA',
      'ATENDIDA',
    }.contains(estado);
  }

  bool get fueRespondida {
    return estado == 'ACEPTADA' || estado == 'RECHAZADA';
  }

  bool get fueAceptada {
    return estado == 'ACEPTADA';
  }

  bool get fueRechazada {
    return estado == 'RECHAZADA';
  }

  bool get fueAtendida {
    return estado == 'ATENDIDA';
  }

  bool get requiereRespuesta {
    return alerta?.requiereConfirmacion == true &&
        !fueRespondida &&
        !fueAtendida;
  }

  static Map<String, dynamic>? _extractAlertaJson(Map<String, dynamic> json) {
    final nested = json['alerta'];

    if (nested is Map<String, dynamic>) {
      return nested;
    }

    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }

    /*
     * Si el backend aplana la alerta dentro del destinatario,
     * verificamos que exista al menos el título.
     */
    if (json.containsKey('titulo') ||
        json.containsKey('tipo') ||
        json.containsKey('descripcion')) {
      return {
        ...json,
        'id': json['alerta_id'] ?? json['id'],
        'estado': json['estado_alerta'] ?? json['alerta_estado'] ?? 'PENDIENTE',
      };
    }

    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }
}
