class CancelarAlertaData {
  final int id;
  final int emisorId;
  final int patrullajeId;
  final int zonaId;
  final int? incidenciaId;

  final String titulo;
  final String tipo;
  final String prioridad;
  final String descripcion;

  final double? latitud;
  final double? longitud;

  final bool requiereConfirmacion;
  final DateTime? fechaExpiracion;

  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool emitidaEnTiempoReal;

  const CancelarAlertaData({
    required this.id,
    required this.emisorId,
    required this.patrullajeId,
    required this.zonaId,
    this.incidenciaId,
    required this.titulo,
    required this.tipo,
    required this.prioridad,
    required this.descripcion,
    this.latitud,
    this.longitud,
    required this.requiereConfirmacion,
    this.fechaExpiracion,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    required this.emitidaEnTiempoReal,
  });

  factory CancelarAlertaData.fromJson(Map<String, dynamic> json) {
    return CancelarAlertaData(
      id: _parseInt(json['id']),
      emisorId: _parseInt(json['emisor_id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      zonaId: _parseInt(json['zona_id']),
      incidenciaId: _parseNullableInt(json['incidencia_id']),
      titulo: json['titulo']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      prioridad: json['prioridad']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim() ?? '',
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      requiereConfirmacion: _parseBool(json['requiere_confirmacion']),
      fechaExpiracion: _parseDateTime(json['fecha_expiracion']),
      estado: json['estado']?.toString().trim() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emitida_en_tiempo_real': emitidaEnTiempoReal,
    };
  }

  bool get fueCancelada => estado == 'CANCELADA';

  bool get esPanico => tipo == 'PANICO';

  bool get esCritica => prioridad == 'CRITICA';

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
