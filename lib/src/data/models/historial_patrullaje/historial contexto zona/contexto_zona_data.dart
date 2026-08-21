import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_archivo_data.dart';

// ==========================================================
// CONTEXTO DE ZONA
// ==========================================================
class ContextoZonaData {
  final ContextoZona zona;
  final ContextoPatrullajeActual patrullajeActual;
  final ContextoPeriodoConsultado periodoConsultado;
  final ContextoResumen resumen;
  final List<ContextoHistorialItem> historial;
  final ContextoPagination pagination;

  const ContextoZonaData({
    required this.zona,
    required this.patrullajeActual,
    required this.periodoConsultado,
    required this.resumen,
    required this.historial,
    required this.pagination,
  });

  factory ContextoZonaData.fromJson(Map<String, dynamic> json) {
    return ContextoZonaData(
      zona: ContextoZona.fromJson(_requiredMap(json['zona'])),

      patrullajeActual: ContextoPatrullajeActual.fromJson(
        _requiredMap(json['patrullaje_actual']),
      ),

      periodoConsultado: ContextoPeriodoConsultado.fromJson(
        _requiredMap(json['periodo_consultado']),
      ),

      resumen: ContextoResumen.fromJson(_requiredMap(json['resumen'])),

      historial: _parseList(json['historial'], ContextoHistorialItem.fromJson),

      pagination: ContextoPagination.fromJson(_requiredMap(json['pagination'])),
    );
  }

  bool get tieneHistorial {
    return historial.isNotEmpty;
  }

  bool get tieneMasPaginas {
    return pagination.hasNextPage;
  }
}

// ==========================================================
// ZONA
// ==========================================================
class ContextoZona {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<ContextoCoordenada> coordenadas;
  final String riesgo;
  final bool estado;

  const ContextoZona({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.coordenadas,
    required this.riesgo,
    required this.estado,
  });

  factory ContextoZona.fromJson(Map<String, dynamic> json) {
    return ContextoZona(
      id: _parseInt(json['id']),
      nombre: _parseString(json['nombre']),
      descripcion: _parseNullableString(json['descripcion']),
      coordenadas: _parseList(json['coordenadas'], ContextoCoordenada.fromJson),
      riesgo: _parseString(json['riesgo'], defaultValue: 'medio'),
      estado: _parseBool(json['estado'], defaultValue: true),
    );
  }
}

class ContextoCoordenada {
  final double lat;
  final double lng;

  const ContextoCoordenada({required this.lat, required this.lng});

  factory ContextoCoordenada.fromJson(Map<String, dynamic> json) {
    return ContextoCoordenada(
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
    );
  }
}

// ==========================================================
// PATRULLAJE ACTUAL
// ==========================================================
class ContextoPatrullajeActual {
  final int id;
  final String estado;
  final String horaInicio;
  final String horaFin;

  const ContextoPatrullajeActual({
    required this.id,
    required this.estado,
    required this.horaInicio,
    required this.horaFin,
  });

  factory ContextoPatrullajeActual.fromJson(Map<String, dynamic> json) {
    return ContextoPatrullajeActual(
      id: _parseInt(json['id']),
      estado: _parseString(json['estado']),
      horaInicio: _parseString(json['hora_inicio']),
      horaFin: _parseString(json['hora_fin']),
    );
  }
}

// ==========================================================
// PERIODO CONSULTADO
// ==========================================================
class ContextoPeriodoConsultado {
  final int dias;
  final DateTime fechaDesde;
  final DateTime fechaHasta;

  const ContextoPeriodoConsultado({
    required this.dias,
    required this.fechaDesde,
    required this.fechaHasta,
  });

  factory ContextoPeriodoConsultado.fromJson(Map<String, dynamic> json) {
    return ContextoPeriodoConsultado(
      dias: _parseInt(json['dias']),
      fechaDesde: _parseDateTime(json['fecha_desde']),
      fechaHasta: _parseDateTime(json['fecha_hasta']),
    );
  }
}

// ==========================================================
// RESUMEN
// ==========================================================
class ContextoResumen {
  final int total;
  final int criticos;
  final int altaPrioridad;
  final int observaciones;
  final int novedades;
  final int alertas;
  final int recomendaciones;
  final int puntosCriticos;
  final int cambiosTurno;
  final int conIncidencia;
  final int conArchivos;

  const ContextoResumen({
    required this.total,
    required this.criticos,
    required this.altaPrioridad,
    required this.observaciones,
    required this.novedades,
    required this.alertas,
    required this.recomendaciones,
    required this.puntosCriticos,
    required this.cambiosTurno,
    required this.conIncidencia,
    required this.conArchivos,
  });

  factory ContextoResumen.fromJson(Map<String, dynamic> json) {
    return ContextoResumen(
      total: _parseInt(json['total']),
      criticos: _parseInt(json['criticos']),
      altaPrioridad: _parseInt(json['alta_prioridad']),
      observaciones: _parseInt(json['observaciones']),
      novedades: _parseInt(json['novedades']),
      alertas: _parseInt(json['alertas']),
      recomendaciones: _parseInt(json['recomendaciones']),
      puntosCriticos: _parseInt(json['puntos_criticos']),
      cambiosTurno: _parseInt(json['cambios_turno']),
      conIncidencia: _parseInt(json['con_incidencia']),
      conArchivos: _parseInt(json['con_archivos']),
    );
  }
}

// ==========================================================
// ITEM DE HISTORIAL
// ==========================================================
class ContextoHistorialItem {
  final int id;
  final int patrullajeId;
  final int? usuarioId;
  final int zonaId;
  final int? incidenciaId;

  final HistorialTipo tipo;
  final String titulo;
  final String descripcion;
  final HistorialPrioridad prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;
  final DateTime fechaHora;
  final HistorialEstado estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<HistorialArchivoData> archivos;

  final ContextoPatrullajeAnterior? patrullajeProgramado;

  final ContextoUsuario? usuario;
  final ContextoIncidencia? incidencia;

  const ContextoHistorialItem({
    required this.id,
    required this.patrullajeId,
    this.usuarioId,
    required this.zonaId,
    this.incidenciaId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    required this.fechaHora,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    required this.archivos,
    this.patrullajeProgramado,
    this.usuario,
    this.incidencia,
  });

  factory ContextoHistorialItem.fromJson(Map<String, dynamic> json) {
    final patrullajeJson = _nullableMap(json['patrullaje_programado']);

    final usuarioJson = _nullableMap(json['usuario']);

    final incidenciaJson = _nullableMap(json['incidencia']);

    return ContextoHistorialItem(
      id: _parseInt(json['id']),

      patrullajeId: _parseInt(json['patrullaje_id']),

      usuarioId: _parseNullableInt(json['usuario_id']),

      zonaId: _parseInt(json['zona_id']),

      incidenciaId: _parseNullableInt(json['incidencia_id']),

      tipo: HistorialTipo.fromValue(json['tipo']?.toString()),

      titulo: _parseString(json['titulo']),

      descripcion: _parseString(json['descripcion']),

      prioridad: HistorialPrioridad.fromValue(json['prioridad']?.toString()),

      latitud: _parseNullableDouble(json['latitud']),

      longitud: _parseNullableDouble(json['longitud']),

      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
        defaultValue: true,
      ),

      fechaHora: _parseDateTime(json['fecha_hora']),

      estado: HistorialEstado.fromValue(json['estado']?.toString()),

      createdAt: _parseNullableDateTime(json['createdAt']),

      updatedAt: _parseNullableDateTime(json['updatedAt']),

      archivos: _parseList(json['archivos'], HistorialArchivoData.fromJson),

      patrullajeProgramado: patrullajeJson == null
          ? null
          : ContextoPatrullajeAnterior.fromJson(patrullajeJson),

      usuario: usuarioJson == null
          ? null
          : ContextoUsuario.fromJson(usuarioJson),

      incidencia: incidenciaJson == null
          ? null
          : ContextoIncidencia.fromJson(incidenciaJson),
    );
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get tieneArchivos {
    return archivos.isNotEmpty;
  }

  bool get tieneIncidencia {
    return incidenciaId != null || incidencia != null;
  }
}

// ==========================================================
// PATRULLAJE ANTERIOR
// ==========================================================
class ContextoPatrullajeAnterior {
  final int id;
  final String estado;
  final String horaInicio;
  final String horaFin;

  const ContextoPatrullajeAnterior({
    required this.id,
    required this.estado,
    required this.horaInicio,
    required this.horaFin,
  });

  factory ContextoPatrullajeAnterior.fromJson(Map<String, dynamic> json) {
    return ContextoPatrullajeAnterior(
      id: _parseInt(json['id']),
      estado: _parseString(json['estado']),
      horaInicio: _parseString(json['hora_inicio']),
      horaFin: _parseString(json['hora_fin']),
    );
  }
}

// ==========================================================
// USUARIO Y PERSONA
// ==========================================================
class ContextoUsuario {
  final int id;
  final int? personaId;
  final ContextoPersona? persona;

  const ContextoUsuario({required this.id, this.personaId, this.persona});

  factory ContextoUsuario.fromJson(Map<String, dynamic> json) {
    final personaJson = _nullableMap(json['persona']);

    return ContextoUsuario(
      id: _parseInt(json['id']),
      personaId: _parseNullableInt(json['persona_id']),
      persona: personaJson == null
          ? null
          : ContextoPersona.fromJson(personaJson),
    );
  }
}

class ContextoPersona {
  final int id;
  final String nombres;
  final String apellidos;
  final String? documentoIdentidad;
  final String? fotoPerfil;

  const ContextoPersona({
    required this.id,
    required this.nombres,
    required this.apellidos,
    this.documentoIdentidad,
    this.fotoPerfil,
  });

  factory ContextoPersona.fromJson(Map<String, dynamic> json) {
    return ContextoPersona(
      id: _parseInt(json['id']),
      nombres: _parseString(json['nombres']),
      apellidos: _parseString(json['apellidos']),
      documentoIdentidad: _parseNullableString(json['documento_identidad']),
      fotoPerfil: _parseNullableString(json['foto_perfil']),
    );
  }

  String get nombreCompleto {
    return [nombres, apellidos].where((item) => item.isNotEmpty).join(' ');
  }
}

// ==========================================================
// INCIDENCIA RELACIONADA
// ==========================================================
class ContextoIncidencia {
  final int id;
  final String tipo;
  final String descripcion;
  final String estado;

  final double? latitud;
  final double? longitud;

  final DateTime? fechaHora;
  final int totalEvidencias;

  final List<ContextoIncidenciaArchivo> archivos;

  const ContextoIncidencia({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.estado,
    this.latitud,
    this.longitud,
    this.fechaHora,
    required this.totalEvidencias,
    required this.archivos,
  });

  factory ContextoIncidencia.fromJson(Map<String, dynamic> json) {
    return ContextoIncidencia(
      id: _parseInt(json['id']),
      tipo: _parseString(json['tipo']),
      descripcion: _parseString(json['descripcion']),
      estado: _parseString(json['estado']),
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      fechaHora: _parseNullableDateTime(json['fecha_hora']),
      totalEvidencias: _parseInt(json['total_evidencias']),
      archivos: _parseList(
        json['archivos'],
        ContextoIncidenciaArchivo.fromJson,
      ),
    );
  }
}

class ContextoIncidenciaArchivo {
  final int id;
  final int incidenciaId;
  final String urlArchivo;
  final String? keyS3;
  final String tipoArchivo;
  final String? mimeType;
  final int? peso;

  const ContextoIncidenciaArchivo({
    required this.id,
    required this.incidenciaId,
    required this.urlArchivo,
    this.keyS3,
    required this.tipoArchivo,
    this.mimeType,
    this.peso,
  });

  factory ContextoIncidenciaArchivo.fromJson(Map<String, dynamic> json) {
    return ContextoIncidenciaArchivo(
      id: _parseInt(json['id']),
      incidenciaId: _parseInt(json['incidencia_id']),
      urlArchivo: _parseString(json['url_archivo']),
      keyS3: _parseNullableString(json['key_s3']),
      tipoArchivo: _parseString(json['tipo_archivo'], defaultValue: 'OTRO'),
      mimeType: _parseNullableString(json['mime_type']),
      peso: _parseNullableInt(json['peso']),
    );
  }
}

// ==========================================================
// PAGINACIÓN
// ==========================================================
class ContextoPagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const ContextoPagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory ContextoPagination.fromJson(Map<String, dynamic> json) {
    return ContextoPagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      hasPreviousPage: _parseBool(json['hasPreviousPage']),
      hasNextPage: _parseBool(json['hasNextPage']),
    );
  }
}

// ==========================================================
// HELPERS
// ==========================================================
Map<String, dynamic> _requiredMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}

Map<String, dynamic>? _nullableMap(dynamic value) {
  if (value == null) {
    return null;
  }

  final parsed = _requiredMap(value);

  return parsed.isEmpty ? null : parsed;
}

List<T> _parseList<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .whereType<Map>()
      .map((item) => parser(Map<String, dynamic>.from(item)))
      .toList();
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  return int.tryParse(value.toString());
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

String _parseString(dynamic value, {String defaultValue = ''}) {
  final parsed = value?.toString().trim();

  if (parsed == null || parsed.isEmpty) {
    return defaultValue;
  }

  return parsed;
}

String? _parseNullableString(dynamic value) {
  final parsed = value?.toString().trim();

  if (parsed == null || parsed.isEmpty) {
    return null;
  }

  return parsed;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value == 1;
  }

  final normalized = value?.toString().trim().toLowerCase();

  if (normalized == 'true' || normalized == '1') {
    return true;
  }

  if (normalized == 'false' || normalized == '0') {
    return false;
  }

  return defaultValue;
}

DateTime _parseDateTime(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}
