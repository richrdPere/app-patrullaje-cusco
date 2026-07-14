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
  final HistorialSerenoModel? sereno;
  final HistorialZonaModel? zona;

  const HistorialPatrullajeModel({
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

  factory HistorialPatrullajeModel.fromJson(Map<String, dynamic> json) {
    return HistorialPatrullajeModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      tipo: json['tipo']?.toString() ?? 'OBSERVACION',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      prioridad: json['prioridad']?.toString() ?? 'MEDIA',
      latitud: double.tryParse(json['latitud']?.toString() ?? ''),
      longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
      ),
      fechaHora: DateTime.tryParse(json['fecha_hora']?.toString() ?? ''),
      sereno: json['sereno'] is Map
          ? HistorialSerenoModel.fromJson(
              Map<String, dynamic>.from(json['sereno'] as Map),
            )
          : null,
      zona: json['zona'] is Map
          ? HistorialZonaModel.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
      'fecha_hora': fechaHora?.toIso8601String(),
      'sereno': sereno?.toJson(),
      'zona': zona?.toJson(),
    };
  }

  static bool _parseBool(dynamic value, {bool defaultValue = true}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final parsed = value.toString().trim().toLowerCase();

    if (parsed == 'true' || parsed == '1') return true;
    if (parsed == 'false' || parsed == '0') return false;

    return defaultValue;
  }
}

class HistorialSerenoModel {
  final int id;
  final String nombres;
  final String apellidos;

  const HistorialSerenoModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
  });

  factory HistorialSerenoModel.fromJson(Map<String, dynamic> json) {
    return HistorialSerenoModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombres': nombres, 'apellidos': apellidos};
  }

  String get nombreCompleto {
    return '$nombres $apellidos'.trim();
  }
}

class HistorialZonaModel {
  final int id;
  final String nombre;

  const HistorialZonaModel({required this.id, required this.nombre});

  factory HistorialZonaModel.fromJson(Map<String, dynamic> json) {
    return HistorialZonaModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}
