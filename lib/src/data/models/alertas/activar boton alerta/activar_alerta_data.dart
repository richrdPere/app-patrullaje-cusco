class ActivarAlertaData {
  final int id;
  final int emisorId;
  final int patrullajeId;
  final int zonaId;
  final int? incidenciaId;

  final String titulo;
  final String tipo;
  final String prioridad;
  final String descripcion;

  final double latitud;
  final double longitud;

  final bool requiereConfirmacion;
  final DateTime? fechaExpiracion;

  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final AlertaHistorialData? historial;
  final bool emitidaEnTiempoReal;

  const ActivarAlertaData({
    required this.id,
    required this.emisorId,
    required this.patrullajeId,
    required this.zonaId,
    this.incidenciaId,
    required this.titulo,
    required this.tipo,
    required this.prioridad,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.requiereConfirmacion,
    this.fechaExpiracion,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.historial,
    required this.emitidaEnTiempoReal,
  });

  factory ActivarAlertaData.fromJson(Map<String, dynamic> json) {
    return ActivarAlertaData(
      id: _parseInt(json['id']),
      emisorId: _parseInt(json['emisor_id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      zonaId: _parseInt(json['zona_id']),
      incidenciaId: _parseNullableInt(json['incidencia_id']),
      titulo: json['titulo']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      prioridad: json['prioridad']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim() ?? '',
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
      requiereConfirmacion: _parseBool(json['requiere_confirmacion']),
      fechaExpiracion: _parseDateTime(json['fecha_expiracion']),
      estado: json['estado']?.toString().trim() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      historial: json['historial'] is Map
          ? AlertaHistorialData.fromJson(
              Map<String, dynamic>.from(json['historial'] as Map),
            )
          : null,
      emitidaEnTiempoReal: _parseBool(json['emitida_en_tiempo_real']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emisor_id': emisorId,
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'incidencia_id': incidenciaId,
      'titulo': titulo,
      'tipo': tipo,
      'prioridad': prioridad,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'requiere_confirmacion': requiereConfirmacion,
      'fecha_expiracion': fechaExpiracion?.toIso8601String(),
      'estado': estado,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'historial': historial?.toJson(),
      'emitida_en_tiempo_real': emitidaEnTiempoReal,
    };
  }

  bool get esAlertaCritica => prioridad == 'CRITICA';

  bool get esBotonPanico => tipo == 'PANICO';

  bool get tieneHistorial => historial != null;

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }

  static DateTime? _parseDateTime(dynamic value) {
    final rawValue = value?.toString().trim();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}

class AlertaHistorialData {
  final int id;
  final int patrullajeId;
  final int usuarioId;
  final int zonaId;
  final int? incidenciaId;

  final String origen;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;

  final DateTime? fechaHora;

  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AlertaHistorialData({
    required this.id,
    required this.patrullajeId,
    required this.usuarioId,
    required this.zonaId,
    this.incidenciaId,
    required this.origen,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    this.fechaHora,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory AlertaHistorialData.fromJson(Map<String, dynamic> json) {
    return AlertaHistorialData(
      id: _parseInt(json['id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      usuarioId: _parseInt(json['usuario_id']),
      zonaId: _parseInt(json['zona_id']),
      incidenciaId: _parseNullableInt(json['incidencia_id']),
      origen: json['origen']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      titulo: json['titulo']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim() ?? '',
      prioridad: json['prioridad']?.toString().trim() ?? '',
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
      ),
      fechaHora: _parseDateTime(json['fecha_hora']),
      estado: json['estado']?.toString().trim() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'origen': origen,
      'id': id,
      'patrullaje_id': patrullajeId,
      'usuario_id': usuarioId,
      'zona_id': zonaId,
      'incidencia_id': incidenciaId,
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
      'fecha_hora': fechaHora?.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }

  static DateTime? _parseDateTime(dynamic value) {
    final rawValue = value?.toString().trim();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
