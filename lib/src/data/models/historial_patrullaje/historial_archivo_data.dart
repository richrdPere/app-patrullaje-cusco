class HistorialArchivoData {
  final int id;
  final int historialId;
  final int usuarioId;

  final String urlArchivo;
  final String keyArchivo;
  final String? nombreOriginal;

  final String tipoArchivo;
  final String? mimeType;
  final int? peso;
  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistorialArchivoData({
    required this.id,
    required this.historialId,
    required this.usuarioId,
    required this.urlArchivo,
    required this.keyArchivo,
    this.nombreOriginal,
    required this.tipoArchivo,
    this.mimeType,
    this.peso,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory HistorialArchivoData.fromJson(Map<String, dynamic> json) {
    return HistorialArchivoData(
      id: _parseInt(json['id']),

      historialId: _parseInt(json['historial_id']),

      usuarioId: _parseInt(json['usuario_id']),

      urlArchivo: json['url_archivo']?.toString().trim() ?? '',

      keyArchivo: json['key_archivo']?.toString().trim() ?? '',

      nombreOriginal: _parseNullableString(json['nombre_original']),

      tipoArchivo: json['tipo_archivo']?.toString().trim() ?? 'OTRO',

      mimeType: _parseNullableString(json['mime_type']),

      peso: _parseNullableInt(json['peso']),

      estado: json['estado']?.toString().trim() ?? 'ACTIVO',

      createdAt: _parseNullableDateTime(json['createdAt']),

      updatedAt: _parseNullableDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'historial_id': historialId,
      'usuario_id': usuarioId,
      'url_archivo': urlArchivo,
      'key_archivo': keyArchivo,
      'nombre_original': nombreOriginal,
      'tipo_archivo': tipoArchivo,
      'mime_type': mimeType,
      'peso': peso,
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get esImagen {
    return tipoArchivo.toUpperCase() == 'IMAGEN';
  }

  bool get esVideo {
    return tipoArchivo.toUpperCase() == 'VIDEO';
  }

  bool get esPdf {
    return tipoArchivo.toUpperCase() == 'PDF';
  }

  bool get tieneUrl {
    return urlArchivo.isNotEmpty;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static String? _parseNullableString(dynamic value) {
    final parsed = value?.toString().trim();

    if (parsed == null || parsed.isEmpty) {
      return null;
    }

    return parsed;
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
