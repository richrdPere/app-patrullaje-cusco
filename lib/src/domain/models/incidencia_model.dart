import 'dart:io';

class IncidenteModel {
  final int? id;
  final int usuarioId;
  final int? patrullajeId;
  final int? zonaId;
  final String tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String? estado;
  final DateTime? fechaHora;
  final List<File>? archivos; // SOLO para envío

  IncidenteModel({
    this.id,
    required this.usuarioId,
    this.patrullajeId,
    this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.estado,
    this.fechaHora,
    this.archivos,
  });

  // =========================
  // FROM JSON (RESPUESTA BACKEND)
  // =========================
  factory IncidenteModel.fromJson(Map<String, dynamic> json) {
    return IncidenteModel(
      id: int.tryParse(json['id'].toString()),
      usuarioId: int.parse(json['usuario_id'].toString()),
      patrullajeId: json['patrullaje_id'] != null
          ? int.tryParse(json['patrullaje_id'].toString())
          : null,
      zonaId: json['zona_id'] != null
          ? int.tryParse(json['zona_id'].toString())
          : null,
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      latitud: double.parse(json['latitud'].toString()),
      longitud: double.parse(json['longitud'].toString()),
      estado: json['estado'],
      fechaHora: json['fecha_hora'] != null
          ? DateTime.parse(json['fecha_hora'])
          : null,
      archivos: null, // backend no devuelve File
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "usuario_id": usuarioId,
      "patrullaje_id": patrullajeId,
      "zona_id": zonaId,
      "tipo": tipo,
      "descripcion": descripcion,
      "latitud": latitud,
      "longitud": longitud,
      "estado": estado,
      "fecha_hora": fechaHora?.toIso8601String(),
    };
  }

  // =========================
  // COPY WITH
  // =========================
  IncidenteModel copyWith({
    int? id,
    int? usuarioId,
    int? patrullajeId,
    int? zonaId,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    String? estado,
    DateTime? fechaHora,
    List<File>? archivos,
  }) {
    return IncidenteModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      zonaId: zonaId ?? this.zonaId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      archivos: archivos ?? this.archivos,
    );
  }
}
