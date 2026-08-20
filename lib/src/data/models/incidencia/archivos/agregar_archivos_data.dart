class AgregarArchivosIncidenciaData {
  final int incidenciaId;
  final int totalEvidencias;
  final List<IncidenciaArchivoAgregadoData> archivos;

  const AgregarArchivosIncidenciaData({
    required this.incidenciaId,
    required this.totalEvidencias,
    required this.archivos,
  });

  factory AgregarArchivosIncidenciaData.fromJson(Map<String, dynamic> json) {
    final rawArchivos = json['archivos'];

    return AgregarArchivosIncidenciaData(
      incidenciaId: _ArchivoAgregadoJsonParser.parseInt(json['incidencia_id']),
      totalEvidencias: _ArchivoAgregadoJsonParser.parseInt(
        json['total_evidencias'],
      ),
      archivos: rawArchivos is List
          ? rawArchivos
                .whereType<Map>()
                .map(
                  (archivo) => IncidenciaArchivoAgregadoData.fromJson(
                    Map<String, dynamic>.from(archivo),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get tieneArchivos => archivos.isNotEmpty;

  int get cantidadArchivosAgregados => archivos.length;
}

class IncidenciaArchivoAgregadoData {
  final int incidenciaId;
  final String urlArchivo;
  final String keyS3;
  final String tipoArchivo;
  final String mimeType;
  final int? peso;
  final int serenoId;

  const IncidenciaArchivoAgregadoData({
    required this.incidenciaId,
    required this.urlArchivo,
    required this.keyS3,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
    required this.serenoId,
  });

  factory IncidenciaArchivoAgregadoData.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoAgregadoData(
      incidenciaId: _ArchivoAgregadoJsonParser.parseInt(json['incidencia_id']),
      urlArchivo: json['url_archivo']?.toString() ?? '',
      keyS3: json['key_s3']?.toString() ?? '',
      tipoArchivo: json['tipo_archivo']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      peso: _ArchivoAgregadoJsonParser.parseNullableInt(json['peso']),
      serenoId: _ArchivoAgregadoJsonParser.parseInt(json['sereno_id']),
    );
  }

  bool get esImagen => tipoArchivo.toUpperCase() == 'IMAGEN';

  bool get esVideo => tipoArchivo.toUpperCase() == 'VIDEO';

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
      final kb = peso! / 1024;

      return '${kb.toStringAsFixed(1)} KB';
    }

    return '${pesoEnMb!.toStringAsFixed(1)} MB';
  }
}

class _ArchivoAgregadoJsonParser {
  const _ArchivoAgregadoJsonParser._();

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
}
