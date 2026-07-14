class HistorialPatrullajeRequest {
  final int patrullajeId;
  final int zonaId;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String prioridad;
  final double? latitud;
  final double? longitud;
  final bool visibleParaSiguienteTurno;

  const HistorialPatrullajeRequest({
    required this.patrullajeId,
    required this.zonaId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
  });

  factory HistorialPatrullajeRequest.fromJson(Map<String, dynamic> json) {
    return HistorialPatrullajeRequest(
      patrullajeId: int.tryParse(json['patrullaje_id']?.toString() ?? '') ?? 0,
      zonaId: int.tryParse(json['zona_id']?.toString() ?? '') ?? 0,
      tipo: json['tipo']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      prioridad: json['prioridad']?.toString() ?? '',
      latitud: double.tryParse(json['latitud']?.toString() ?? ''),
      longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
      ),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
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
