class AlertaModel {
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

  /*
   * Asociaciones opcionales.
   *
   * Se mantienen como Map hasta conocer el JSON exacto
   * que devuelve Sequelize para cada relación.
   */
  final Map<String, dynamic>? emisor;
  final Map<String, dynamic>? patrullaje;
  final Map<String, dynamic>? zona;
  final Map<String, dynamic>? incidencia;

  const AlertaModel({
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
    this.patrullaje,
    this.zona,
    this.incidencia,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: _parseInt(json['id']) ?? 0,
      emisorId: _parseInt(json['emisor_id']) ?? 0,
      patrullajeId: _parseInt(json['patrullaje_id']),
      zonaId: _parseInt(json['zona_id']),
      incidenciaId: _parseInt(json['incidencia_id']),
      titulo: json['titulo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'INFORMATIVA',
      prioridad: json['prioridad']?.toString() ?? 'MEDIA',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
      requiereConfirmacion: _parseBool(json['requiere_confirmacion']),
      fechaExpiracion: _parseDate(json['fecha_expiracion']),
      estado: json['estado']?.toString() ?? 'PENDIENTE',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      emisor: _parseMap(json['emisor']),
      patrullaje: _parseMap(json['patrullaje']),
      zona: _parseMap(json['zona']),
      incidencia: _parseMap(json['incidencia']),
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
      'emisor': emisor,
      'patrullaje': patrullaje,
      'zona': zona,
      'incidencia': incidencia,
    };
  }

  AlertaModel copyWith({
    int? id,
    int? emisorId,
    int? patrullajeId,
    int? zonaId,
    int? incidenciaId,
    String? titulo,
    String? tipo,
    String? prioridad,
    String? descripcion,
    double? latitud,
    double? longitud,
    bool? requiereConfirmacion,
    DateTime? fechaExpiracion,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? emisor,
    Map<String, dynamic>? patrullaje,
    Map<String, dynamic>? zona,
    Map<String, dynamic>? incidencia,
  }) {
    return AlertaModel(
      id: id ?? this.id,
      emisorId: emisorId ?? this.emisorId,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      zonaId: zonaId ?? this.zonaId,
      incidenciaId: incidenciaId ?? this.incidenciaId,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      prioridad: prioridad ?? this.prioridad,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      requiereConfirmacion: requiereConfirmacion ?? this.requiereConfirmacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emisor: emisor ?? this.emisor,
      patrullaje: patrullaje ?? this.patrullaje,
      zona: zona ?? this.zona,
      incidencia: incidencia ?? this.incidencia,
    );
  }

  bool get estaExpirada {
    if (estado == 'EXPIRADA') {
      return true;
    }

    if (fechaExpiracion == null) {
      return false;
    }

    return DateTime.now().isAfter(fechaExpiracion!);
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get esCritica {
    return prioridad == 'CRITICA';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalized = value.toString().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}
