class RegisterIncidenciaData {
  final IncidenciaRegistradaData incidencia;
  final List<IncidenciaArchivoRegistradoData> archivos;

  const RegisterIncidenciaData({
    required this.incidencia,
    required this.archivos,
  });

  factory RegisterIncidenciaData.fromJson(Map<String, dynamic> json) {
    final rawIncidencia = json['incidencia'];
    final rawArchivos = json['archivos'];

    return RegisterIncidenciaData(
      incidencia: rawIncidencia is Map
          ? IncidenciaRegistradaData.fromJson(
              Map<String, dynamic>.from(rawIncidencia),
            )
          : throw const FormatException(
              'No se recibió la incidencia registrada.',
            ),
      archivos: rawArchivos is List
          ? rawArchivos
                .whereType<Map>()
                .map(
                  (archivo) => IncidenciaArchivoRegistradoData.fromJson(
                    Map<String, dynamic>.from(archivo),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class IncidenciaRegistradaData {
  final int id;
  final int usuarioId;
  final int patrullajeId;
  final int zonaId;

  final String tipo;
  final String descripcion;

  final double latitud;
  final double longitud;

  final DateTime fechaHora;
  final String origen;
  final String estado;
  final int totalEvidencias;

  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidenciaRegistradaData({
    required this.id,
    required this.usuarioId,
    required this.patrullajeId,
    required this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    required this.origen,
    required this.estado,
    required this.totalEvidencias,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidenciaRegistradaData.fromJson(Map<String, dynamic> json) {
    return IncidenciaRegistradaData(
      id: _parseInt(json['id']),
      usuarioId: _parseInt(json['usuario_id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      zonaId: _parseInt(json['zona_id']),
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
      fechaHora: _parseDateTime(json['fecha_hora']),
      origen: json['origen']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      totalEvidencias: _parseInt(json['total_evidencias']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw const FormatException('La fecha recibida no es válida.');
    }

    return parsed;
  }
}

class IncidenciaArchivoRegistradoData {
  final int incidenciaId;
  final String urlArchivo;
  final String keyS3;
  final String tipoArchivo;
  final String mimeType;
  final int? peso;
  final int serenoId;

  const IncidenciaArchivoRegistradoData({
    required this.incidenciaId,
    required this.urlArchivo,
    required this.keyS3,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
    required this.serenoId,
  });

  factory IncidenciaArchivoRegistradoData.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoRegistradoData(
      incidenciaId: _parseInt(json['incidencia_id']),
      urlArchivo: json['url_archivo']?.toString() ?? '',
      keyS3: json['key_s3']?.toString() ?? '',
      tipoArchivo: json['tipo_archivo']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      peso: _parseNullableInt(json['peso']),
      serenoId: _parseInt(json['sereno_id']),
    );
  }

  bool get esImagen => tipoArchivo.toUpperCase() == 'IMAGEN';

  bool get esVideo => tipoArchivo.toUpperCase() == 'VIDEO';

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
}
