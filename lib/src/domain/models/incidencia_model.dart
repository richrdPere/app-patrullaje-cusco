import 'dart:io';

import 'incidencia_archivo_model.dart';

class IncidenteModel {
  final int? id;

  // final int usuarioId;
  final int? patrullajeId;
  // final int? zonaId;

  final String tipo;
  final String descripcion;

  final double latitud;
  final double longitud;

  final DateTime? fechaHora;

  final String? estado;

  final int totalEvidencias;

  final String origen;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// SOLO PARA ENVÍO
  final List<File>? archivos;

  /// SOLO RESPUESTA BACKEND
  final List<IncidenciaArchivoModel>? evidencias;

  const IncidenteModel({
    this.id,
    // required this.usuarioId,
    this.patrullajeId,
    // this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.fechaHora,
    this.estado,
    this.totalEvidencias = 0,
    this.origen = 'APP_MOVIL',
    this.createdAt,
    this.updatedAt,
    this.archivos,
    this.evidencias,
  });

  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    return IncidenteModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,

      // usuarioId: int.parse(json['usuario_id'].toString()),
      patrullajeId: json['patrullaje_id'] != null
          ? int.tryParse(json['patrullaje_id'].toString())
          : null,

      // zonaId: json['zona_id'] != null
      //     ? int.tryParse(
      //         json['zona_id'].toString(),
      //       )
      //     : null,
      tipo: json['tipo'] ?? 'OTRO',

      descripcion: json['descripcion'] ?? '',

      latitud: double.parse(json['latitud'].toString()),

      longitud: double.parse(json['longitud'].toString()),

      fechaHora: json['fecha_hora'] != null
          ? DateTime.parse(json['fecha_hora'])
          : null,

      estado: json['estado'],

      totalEvidencias: json['total_evidencias'] != null
          ? int.parse(json['total_evidencias'].toString())
          : 0,

      origen: json['origen'] ?? 'APP_MOVIL',

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,

      archivos: null,

      evidencias: json['evidencias'] != null
          ? (json['evidencias'] as List)
                .map((e) => IncidenciaArchivoModel.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      // "usuario_id": usuarioId,
      // "zona_id": zonaId,
      "patrullaje_id": patrullajeId,
      "tipo": tipo,
      "descripcion": descripcion,
      "latitud": latitud,
      "longitud": longitud,
      "fecha_hora": fechaHora?.toIso8601String(),
      "estado": estado,
      "total_evidencias": totalEvidencias,
      "origen": origen,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  IncidenteModel copyWith({
    int? id,
    int? usuarioId,
    int? patrullajeId,
    int? zonaId,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    DateTime? fechaHora,
    String? estado,
    int? totalEvidencias,
    String? origen,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<File>? archivos,
    List<IncidenciaArchivoModel>? evidencias,
  }) {
    return IncidenteModel(
      id: id ?? this.id,
      // usuarioId: usuarioId ?? this.usuarioId,      
      // zonaId: zonaId ?? this.zonaId,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaHora: fechaHora ?? this.fechaHora,
      estado: estado ?? this.estado,
      totalEvidencias: totalEvidencias ?? this.totalEvidencias,
      origen: origen ?? this.origen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivos: archivos ?? this.archivos,
      evidencias: evidencias ?? this.evidencias,
    );
  }
}
