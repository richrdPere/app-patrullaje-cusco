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
      id: int.tryParse(json['id'].toString()),
      usuarioId: int.parse(json['usuario_id'].toString()),
      patrullajeId: json['patrullaje_id'] != null
          ? int.tryParse(json['patrullaje_id'].toString())
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
}
