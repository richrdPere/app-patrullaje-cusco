import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';

class IncidenteModel extends Equatable {
  final int? id;
  final int? patrullajeId;

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

  /// Archivos locales pendientes de envío.
  final List<File>? archivos;

  /// Archivos devueltos por el backend.
  final List<IncidenciaArchivoModel> evidencias;

  const IncidenteModel({
    this.id,
    this.patrullajeId,
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
    this.evidencias = const [],
  });

  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    final dynamic archivosJson =
        json['archivos'] ?? json['evidencias'] ?? json['incidencia_archivos'];

    final List<IncidenciaArchivoModel> archivosRemotos;

    if (archivosJson is List) {
      archivosRemotos = archivosJson
          .whereType<Map<String, dynamic>>()
          .map(IncidenciaArchivoModel.fromJson)
          .toList();
    } else {
      archivosRemotos = const [];
    }

    return IncidenteModel(
      id: _toInt(json['id']),
      patrullajeId: _toInt(json['patrullaje_id']),
      tipo: json['tipo']?.toString() ?? 'OTRO',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _toDouble(json['latitud']) ?? 0,
      longitud: _toDouble(json['longitud']) ?? 0,
      fechaHora: _toDateTime(json['fecha_hora'] ?? json['fechaHora']),
      estado: json['estado']?.toString(),
      totalEvidencias:
          _toInt(
            json['total_evidencias'] ??
                json['total_archivos'] ??
                archivosRemotos.length,
          ) ??
          archivosRemotos.length,
      origen: json['origen']?.toString() ?? 'APP_MOVIL',
      createdAt: _toDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _toDateTime(json['updatedAt'] ?? json['updated_at']),
      archivos: null,
      evidencias: archivosRemotos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrullaje_id': patrullajeId,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_hora': fechaHora?.toIso8601String(),
      'estado': estado,
      'total_evidencias': totalEvidencias,
      'origen': origen,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'evidencias': evidencias.map((e) => e.toJson()).toList(),
    };
  }

  IncidenteModel copyWith({
    int? id,
    int? patrullajeId,
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    patrullajeId,
    tipo,
    descripcion,
    latitud,
    longitud,
    fechaHora,
    estado,
    totalEvidencias,
    origen,
    createdAt,
    updatedAt,
    archivos,
    evidencias,
  ];
}
