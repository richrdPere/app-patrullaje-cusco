class AlertaData {
  final int id;
  final int emisorId;

  final int? patrullajeId;
  final int? zonaId;
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

  final AlertaEmisorData? emisor;

  /*
   * En el JSON proporcionado estos campos llegan en null.
   *
   * Temporalmente se mantienen como Map para no inventar una estructura.
   * Cuando tengas el JSON completo de estas relaciones, se pueden
   * reemplazar por modelos tipados.
   */
  final Map<String, dynamic>? zona;
  final Map<String, dynamic>? patrullaje;
  final Map<String, dynamic>? incidencia;

  const AlertaData({
    required this.id,
    required this.emisorId,
    this.patrullajeId,
    this.zonaId,
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
    this.emisor,
    this.zona,
    this.patrullaje,
    this.incidencia,
  });

  factory AlertaData.fromJson(Map<String, dynamic> json) {
    return AlertaData(
      id: _parseInt(json['id']),
      emisorId: _parseInt(json['emisor_id']),
      patrullajeId: _parseNullableInt(json['patrullaje_id']),
      zonaId: _parseNullableInt(json['zona_id']),
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
      emisor: json['emisor'] is Map
          ? AlertaEmisorData.fromJson(
              Map<String, dynamic>.from(json['emisor'] as Map),
            )
          : null,
      zona: _parseNullableMap(json['zona']),
      patrullaje: _parseNullableMap(json['patrullaje']),
      incidencia: _parseNullableMap(json['incidencia']),
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
      'emisor': emisor?.toJson(),
      'zona': zona,
      'patrullaje': patrullaje,
      'incidencia': incidencia,
    };
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

  static Map<String, dynamic>? _parseNullableMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}

class AlertaEmisorData {
  final int id;
  final String username;
  final String correo;

  const AlertaEmisorData({
    required this.id,
    required this.username,
    required this.correo,
  });

  factory AlertaEmisorData.fromJson(Map<String, dynamic> json) {
    return AlertaEmisorData(
      id: _parseInt(json['id']),
      username: json['username']?.toString().trim() ?? '',
      correo: json['correo']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'correo': correo};
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
