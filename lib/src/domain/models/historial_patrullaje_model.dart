class HistorialPatrullajeModel {
  final int? id;

  final int patrullajeId;
  // final int serenoId;
  // final int zonaId;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;
  final DateTime? fechaHora;
  final String estado;

  HistorialPatrullajeModel({
    this.id,
    required this.patrullajeId,
    // required this.serenoId,
    // required this.zonaId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    this.fechaHora,
    required this.estado,
  });

  // =========================================================
  // FROM JSON
  // =========================================================
  factory HistorialPatrullajeModel.fromJson(Map<String, dynamic> json) {
    return HistorialPatrullajeModel(
      id: json["id"],
      patrullajeId: json["patrullaje_id"],
      // serenoId: json["sereno_id"],
      // zonaId: json["zona_id"],
      tipo: json["tipo"] ?? "OBSERVACION",
      titulo: json["titulo"] ?? "",
      descripcion: json["descripcion"] ?? "",
      prioridad: json["prioridad"] ?? "MEDIA",
      latitud: json["latitud"] != null
          ? double.tryParse(json["latitud"].toString())
          : null,
      longitud: json["longitud"] != null
          ? double.tryParse(json["longitud"].toString())
          : null,
      visibleParaSiguienteTurno: json["visible_para_siguiente_turno"] ?? true,
      fechaHora: json["fecha_hora"] != null
          ? DateTime.parse(json["fecha_hora"])
          : null,
      estado: json["estado"] ?? "ACTIVO",
    );
  }

  // =========================================================
  // TO JSON
  // =========================================================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "patrullaje_id": patrullajeId,
      // "sereno_id": serenoId,
      // "zona_id": zonaId,
      "tipo": tipo,
      "titulo": titulo,
      "descripcion": descripcion,
      "prioridad": prioridad,
      "latitud": latitud,
      "longitud": longitud,
      "visible_para_siguiente_turno": visibleParaSiguienteTurno,
      "fecha_hora": fechaHora?.toIso8601String(),
      "estado": estado,
    };
  }

  // =========================================================
  // COPY WITH
  // =========================================================
  HistorialPatrullajeModel copyWith({
    int? id,
    int? patrullajeId,
    // int? serenoId,
    // int? zonaId,
    String? tipo,
    String? titulo,
    String? descripcion,
    String? prioridad,
    double? latitud,
    double? longitud,
    bool? visibleParaSiguienteTurno,
    DateTime? fechaHora,
    String? estado,
  }) {
    return HistorialPatrullajeModel(
      id: id ?? this.id,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      // serenoId: serenoId ?? this.serenoId,
      // zonaId: zonaId ?? this.zonaId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      visibleParaSiguienteTurno:
          visibleParaSiguienteTurno ?? this.visibleParaSiguienteTurno,
      fechaHora: fechaHora ?? this.fechaHora,
      estado: estado ?? this.estado,
    );
  }
}
