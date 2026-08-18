// patrullaje_listado_data.dart

class PatrullajeListadoData {
  final int id;
  final int? unidadId;
  final int zonaId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final String? descripcion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<PatrullajePersonalData> personal;
  final PatrullajeZonaData? zona;
  final PatrullajeUnidadData? unidad;
  final PatrullajeResumenData? resumen;

  const PatrullajeListadoData({
    required this.id,
    this.unidadId,
    required this.zonaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
    required this.personal,
    this.zona,
    this.unidad,
    this.resumen,
  });

  factory PatrullajeListadoData.fromJson(Map<String, dynamic> json) {
    return PatrullajeListadoData(
      id: _parseInt(json['id']),
      unidadId: _parseNullableInt(json['unidad_id']),
      zonaId: _parseInt(json['zona_id']),
      fecha: DateTime.parse(json['fecha'].toString()),
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      createdAt: _parseNullableDateTime(json['createdAt']),
      updatedAt: _parseNullableDateTime(json['updatedAt']),
      personal: (json['personal'] as List<dynamic>? ?? [])
          .map(
            (item) => PatrullajePersonalData.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      zona: json['zona'] == null
          ? null
          : PatrullajeZonaData.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            ),
      unidad: json['unidad'] == null
          ? null
          : PatrullajeUnidadData.fromJson(
              Map<String, dynamic>.from(json['unidad'] as Map),
            ),
      resumen: json['resumen'] == null
          ? null
          : PatrullajeResumenData.fromJson(
              Map<String, dynamic>.from(json['resumen'] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidad_id': unidadId,
      'zona_id': zonaId,
      'fecha': _formatDate(fecha),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'descripcion': descripcion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'personal': personal.map((item) => item.toJson()).toList(),
      'zona': zona?.toJson(),
      'unidad': unidad?.toJson(),
      'resumen': resumen?.toJson(),
    };
  }

  bool get estaFinalizado => estado == 'FINALIZADO';

  bool get estaEnCurso => estado == 'EN_CURSO';

  bool get tieneResumen => resumen != null;

  bool get tieneUnidad => unidad != null;

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class PatrullajePersonalData {
  final int id;
  final int? usuarioId;
  final String tipoPersonal;
  final String estado;
  final DateTime? fechaAsignacion;

  const PatrullajePersonalData({
    required this.id,
    this.usuarioId,
    required this.tipoPersonal,
    required this.estado,
    this.fechaAsignacion,
  });

  factory PatrullajePersonalData.fromJson(Map<String, dynamic> json) {
    return PatrullajePersonalData(
      id: _parseInt(json['id']),
      usuarioId: _parseNullableInt(json['usuario_id']),
      tipoPersonal: json['tipo_personal']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      fechaAsignacion: _parseNullableDateTime(json['fecha_asignacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tipo_personal': tipoPersonal,
      'estado': estado,
      'fecha_asignacion': fechaAsignacion?.toIso8601String(),
    };
  }
}

class PatrullajeZonaData {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<PatrullajeCoordenadaData> coordenadas;
  final String? riesgo;
  final bool estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatrullajeZonaData({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.coordenadas,
    this.riesgo,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory PatrullajeZonaData.fromJson(Map<String, dynamic> json) {
    return PatrullajeZonaData(
      id: _parseInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      coordenadas: (json['coordenadas'] as List<dynamic>? ?? [])
          .map(
            (item) => PatrullajeCoordenadaData.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      riesgo: json['riesgo']?.toString(),
      estado: json['estado'] == true,
      createdAt: _parseNullableDateTime(json['createdAt']),
      updatedAt: _parseNullableDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'coordenadas': coordenadas.map((item) => item.toJson()).toList(),
      'riesgo': riesgo,
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PatrullajeCoordenadaData {
  final double lat;
  final double lng;

  const PatrullajeCoordenadaData({required this.lat, required this.lng});

  factory PatrullajeCoordenadaData.fromJson(Map<String, dynamic> json) {
    return PatrullajeCoordenadaData(
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}

class PatrullajeUnidadData {
  final int id;
  final String codigo;
  final String tipo;
  final String? placa;
  final String estado;
  final String? descripcion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatrullajeUnidadData({
    required this.id,
    required this.codigo,
    required this.tipo,
    this.placa,
    required this.estado,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
  });

  factory PatrullajeUnidadData.fromJson(Map<String, dynamic> json) {
    return PatrullajeUnidadData(
      id: _parseInt(json['id']),
      codigo: json['codigo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      placa: json['placa']?.toString(),
      estado: json['estado']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      createdAt: _parseNullableDateTime(json['createdAt']),
      updatedAt: _parseNullableDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'tipo': tipo,
      'placa': placa,
      'estado': estado,
      'descripcion': descripcion,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PatrullajeResumenData {
  final int id;
  final int patrullajeId;
  final int usuarioFinalizaId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int duracionSegundos;
  final double distanciaTotalMetros;
  final int totalPuntosRecorrido;
  final int totalIncidencias;
  final int totalObservaciones;
  final String? observacionFinal;

  const PatrullajeResumenData({
    required this.id,
    required this.patrullajeId,
    required this.usuarioFinalizaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.duracionSegundos,
    required this.distanciaTotalMetros,
    required this.totalPuntosRecorrido,
    required this.totalIncidencias,
    required this.totalObservaciones,
    this.observacionFinal,
  });

  factory PatrullajeResumenData.fromJson(Map<String, dynamic> json) {
    return PatrullajeResumenData(
      id: _parseInt(json['id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      usuarioFinalizaId: _parseInt(json['usuario_finaliza_id']),
      fechaInicio: DateTime.parse(json['fecha_inicio'].toString()),
      fechaFin: DateTime.parse(json['fecha_fin'].toString()),
      duracionSegundos: _parseInt(json['duracion_segundos']),
      distanciaTotalMetros: _parseDouble(json['distancia_total_metros']),
      totalPuntosRecorrido: _parseInt(json['total_puntos_recorrido']),
      totalIncidencias: _parseInt(json['total_incidencias']),
      totalObservaciones: _parseInt(json['total_observaciones']),
      observacionFinal: json['observacion_final']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrullaje_id': patrullajeId,
      'usuario_finaliza_id': usuarioFinalizaId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'duracion_segundos': duracionSegundos,
      'distancia_total_metros': distanciaTotalMetros,
      'total_puntos_recorrido': totalPuntosRecorrido,
      'total_incidencias': totalIncidencias,
      'total_observaciones': totalObservaciones,
      'observacion_final': observacionFinal,
    };
  }

  Duration get duracion {
    return Duration(seconds: duracionSegundos);
  }

  double get distanciaKilometros {
    return distanciaTotalMetros / 1000;
  }
}

// ==========================================================
// HELPERS
// ==========================================================
int _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
