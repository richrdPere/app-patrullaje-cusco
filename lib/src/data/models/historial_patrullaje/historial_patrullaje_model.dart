class HistorialPatrullajeModel {
  final int? id;

  final String tipo;
  final String titulo;
  final String descripcion;
  final String prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;
  final DateTime? fechaHora;

  final Map<String, dynamic>? sereno;
  final HistorialZonaModel? zona;

  HistorialPatrullajeModel({
    this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    this.fechaHora,
    this.sereno,
    this.zona,
  });

  // =========================================================
  // FROM JSON
  // =========================================================
  factory HistorialPatrullajeModel.fromJson(Map<String, dynamic> json) {
    return HistorialPatrullajeModel(
      id: json["id"],
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
      sereno: json["sereno"],
      zona: json["zona"] != null
          ? HistorialZonaModel.fromJson(json["zona"])
          : null,
    );
  }

  // =========================================================
  // TO JSON
  // =========================================================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tipo": tipo,
      "titulo": titulo,
      "descripcion": descripcion,
      "prioridad": prioridad,
      "latitud": latitud,
      "longitud": longitud,
      "visible_para_siguiente_turno": visibleParaSiguienteTurno,
      "fecha_hora": fechaHora?.toIso8601String(),
      "sereno": sereno,
      "zona": zona?.toJson(),
    };
  }

  // =========================================================
  // COPY WITH
  // =========================================================
  HistorialPatrullajeModel copyWith({
    int? id,
    String? tipo,
    String? titulo,
    String? descripcion,
    String? prioridad,
    double? latitud,
    double? longitud,
    bool? visibleParaSiguienteTurno,
    DateTime? fechaHora,
    Map<String, dynamic>? sereno,
    HistorialZonaModel? zona,
  }) {
    return HistorialPatrullajeModel(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      visibleParaSiguienteTurno:
          visibleParaSiguienteTurno ?? this.visibleParaSiguienteTurno,
      fechaHora: fechaHora ?? this.fechaHora,
      sereno: sereno ?? this.sereno,
      zona: zona ?? this.zona,
    );
  }
}

class HistorialZonaModel {
  final int id;
  final String nombre;

  HistorialZonaModel({required this.id, required this.nombre});

  factory HistorialZonaModel.fromJson(Map<String, dynamic> json) {
    return HistorialZonaModel(id: json["id"], nombre: json["nombre"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nombre": nombre};
  }
}
