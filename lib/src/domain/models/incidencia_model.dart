import 'dart:io';

class IncidenteModel {
  final int? id;
  final int usuarioId;
  final int? patrullajeId;
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
      id: json['id'],
      usuarioId: json['usuario_id'],
      patrullajeId: json['patrullaje_id'],
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
}
