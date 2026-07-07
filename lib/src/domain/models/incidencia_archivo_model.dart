class IncidenciaArchivoModel {
  final int? id;
  final int incidenciaId;

  final String urlArchivo;
  final String keyS3;

  final String tipoArchivo;
  final String mimeType;

  final int? peso;

  final int serenoId;

  final String? estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IncidenciaArchivoModel({
    this.id,
    required this.incidenciaId,
    required this.urlArchivo,
    required this.keyS3,
    required this.tipoArchivo,
    required this.mimeType,
    this.peso,
    required this.serenoId,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory IncidenciaArchivoModel.fromJson(
      Map<String, dynamic> json) {
    return IncidenciaArchivoModel(
      id: json['id'] != null
          ? int.tryParse(json['id'].toString())
          : null,

      incidenciaId:
          int.parse(json['incidencia_id'].toString()),

      urlArchivo: json['url_archivo'] ?? '',

      keyS3: json['key_s3'] ?? '',

      tipoArchivo: json['tipo_archivo'] ?? 'OTRO',

      mimeType: json['mime_type'] ?? '',

      peso: json['peso'] != null
          ? int.tryParse(json['peso'].toString())
          : null,

      serenoId:
          int.parse(json['sereno_id'].toString()),

      estado: json['estado'],

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "incidencia_id": incidenciaId,
      "url_archivo": urlArchivo,
      "key_s3": keyS3,
      "tipo_archivo": tipoArchivo,
      "mime_type": mimeType,
      "peso": peso,
      "sereno_id": serenoId,
      "estado": estado,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}