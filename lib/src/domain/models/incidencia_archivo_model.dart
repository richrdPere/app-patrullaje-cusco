import 'package:equatable/equatable.dart';

class IncidenciaArchivoModel extends Equatable {
  final int? id;
  final int incidenciaId;

  final String urlArchivo;
  final String keyS3;

  final String tipoArchivo;
  final String mimeType;

  final int? peso;
  final int? serenoId;

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
    this.serenoId,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory IncidenciaArchivoModel.fromJson(Map<String, dynamic> json) {
    return IncidenciaArchivoModel(
      id: _toInt(json['id']),

      incidenciaId: _toInt(json['incidencia_id']) ?? 0,

      urlArchivo: json['url_archivo']?.toString() ?? '',

      keyS3: json['key_s3']?.toString() ?? '',

      tipoArchivo: json['tipo_archivo']?.toString() ?? 'OTRO',

      mimeType: json['mime_type']?.toString() ?? '',

      peso: _toInt(json['peso']),

      serenoId: _toInt(json['sereno_id'] ?? json['usuario_id']),

      estado: json['estado']?.toString(),

      createdAt: _toDateTime(json['createdAt'] ?? json['created_at']),

      updatedAt: _toDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incidencia_id': incidenciaId,
      'url_archivo': urlArchivo,
      'key_s3': keyS3,
      'tipo_archivo': tipoArchivo,
      'mime_type': mimeType,
      'peso': peso,
      'sereno_id': serenoId,
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  IncidenciaArchivoModel copyWith({
    int? id,
    int? incidenciaId,
    String? urlArchivo,
    String? keyS3,
    String? tipoArchivo,
    String? mimeType,
    int? peso,
    int? serenoId,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidenciaArchivoModel(
      id: id ?? this.id,
      incidenciaId: incidenciaId ?? this.incidenciaId,
      urlArchivo: urlArchivo ?? this.urlArchivo,
      keyS3: keyS3 ?? this.keyS3,
      tipoArchivo: tipoArchivo ?? this.tipoArchivo,
      mimeType: mimeType ?? this.mimeType,
      peso: peso ?? this.peso,
      serenoId: serenoId ?? this.serenoId,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    incidenciaId,
    urlArchivo,
    keyS3,
    tipoArchivo,
    mimeType,
    peso,
    serenoId,
    estado,
    createdAt,
    updatedAt,
  ];
}
