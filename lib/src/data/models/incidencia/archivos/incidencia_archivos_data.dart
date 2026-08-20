class IncidenciaArchivosData {
  final int incidenciaId;
  final int total;
  final int totalEvidencias;
  final List<IncidenciaArchivoData> items;

  const IncidenciaArchivosData({
    required this.incidenciaId,
    required this.total,
    required this.totalEvidencias,
    required this.items,
  });

  factory IncidenciaArchivosData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return IncidenciaArchivosData(
      incidenciaId: _ArchivoJsonParser.parseInt(json['incidencia_id']),
      total: _ArchivoJsonParser.parseInt(json['total']),
      totalEvidencias: _ArchivoJsonParser.parseInt(json['total_evidencias']),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => IncidenciaArchivoData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get tieneArchivos => items.isNotEmpty;

  bool get estaVacio => items.isEmpty;

  int get totalImagenes {
    return items.where((archivo) => archivo.esImagen).length;
  }

  int get totalVideos {
    return items.where((archivo) => archivo.esVideo).length;
  }
}

class IncidenciaArchivoData {
  final int id;
  final int incidenciaId;
  final String urlArchivo;
  final String tipoArchivo;
  final String mimeType;
  final int? peso;
  final int serenoId;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncidenciaArchivoData({
    required this.id,
    required this.incidenciaId,
    required this.urlArchivo,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
    required this.serenoId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidenciaArchivoData.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoData(
      id: _ArchivoJsonParser.parseInt(json['id']),
      incidenciaId: _ArchivoJsonParser.parseInt(json['incidencia_id']),
      urlArchivo: json['url_archivo']?.toString() ?? '',
      tipoArchivo: json['tipo_archivo']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      peso: _ArchivoJsonParser.parseNullableInt(json['peso']),
      serenoId: _ArchivoJsonParser.parseInt(json['sereno_id']),
      estado: json['estado']?.toString() ?? '',
      createdAt: _ArchivoJsonParser.parseDateTime(json['createdAt']),
      updatedAt: _ArchivoJsonParser.parseDateTime(json['updatedAt']),
    );
  }

  bool get esImagen => tipoArchivo.toUpperCase() == 'IMAGEN';

  bool get esVideo => tipoArchivo.toUpperCase() == 'VIDEO';

  bool get esPdf => tipoArchivo.toUpperCase() == 'PDF';

  bool get estaActivo => estado.toUpperCase() == 'ACTIVO';

  double? get pesoEnKb {
    if (peso == null) {
      return null;
    }

    return peso! / 1024;
  }

  double? get pesoEnMb {
    if (peso == null) {
      return null;
    }

    return peso! / (1024 * 1024);
  }

  String get pesoFormateado {
    if (peso == null) {
      return 'Tamaño desconocido';
    }

    if (peso! < 1024) {
      return '$peso B';
    }

    if (peso! < 1024 * 1024) {
      return '${pesoEnKb!.toStringAsFixed(1)} KB';
    }

    return '${pesoEnMb!.toStringAsFixed(1)} MB';
  }
}

class _ArchivoJsonParser {
  const _ArchivoJsonParser._();

  static int parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static DateTime parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw FormatException('La fecha recibida no es válida: $value');
    }

    return parsed;
  }
}
