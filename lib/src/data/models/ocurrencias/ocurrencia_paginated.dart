class OcurrenciaPaginated {
  final List<OcurrenciaPaginatedItem> items;
  final OcurrenciaPagination pagination;
  final OcurrenciaAppliedFilters filters;

  const OcurrenciaPaginated({
    this.items = const [],
    required this.pagination,
    required this.filters,
  });

  factory OcurrenciaPaginated.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginated(
      items: _fromList(json['items'], OcurrenciaPaginatedItem.fromJson),
      pagination: OcurrenciaPagination.fromJson(_asMap(json['pagination'])),
      filters: OcurrenciaAppliedFilters.fromJson(_asMap(json['filters'])),
    );
  }
}

// ==========================================================
// ITEM
// ==========================================================
class OcurrenciaPaginatedItem {
  final int id;
  final String numeroOcurrencia;
  final String uuidCliente;

  final int serenoId;
  final int modalidadId;
  final int? incidenciaId;
  final int? patrullajeId;
  final int? zonaId;
  final int? unidadId;

  final String origen;
  final String? origenOtro;
  final String modalidadPatrullaje;
  final String tipoPatrullaje;
  final String? tipoPatrullajeOtro;
  final String turno;

  final String? placaVehiculo;
  final String? tipoVehiculo;
  final String? tipoVehiculoOtro;

  final String fechaOcurrencia;
  final String? horaAlerta;
  final String? horaLlegada;
  final String? horaRepliegue;

  final String resultado;
  final String? relacionVictimaVictimario;

  final String? tipoLugar;
  final String? tipoLugarOtro;
  final String? tipoVia;
  final String? direccion;
  final String? referencia;
  final String? manzana;
  final String? lote;

  final String? tipoZona;
  final String? nombreZona;
  final String? sectorPatrullaje;
  final String? ubigeo;

  final String? latitud;
  final String? longitud;
  final String? datosImportantes;

  final String estado;
  final String? motivoAnulacion;
  final String estadoRemision;
  final String? fechaRemision;
  final String? constanciaRemision;

  final String createdAt;
  final String updatedAt;

  final OcurrenciaPaginatedSereno? sereno;
  final OcurrenciaPaginatedModalidad? modalidad;
  final OcurrenciaPaginatedIncidencia? incidencia;
  final OcurrenciaPaginatedPatrullaje? patrullaje;

  // Actualmente el endpoint devuelve null.
  final Map<String, dynamic>? zonas;
  final Map<String, dynamic>? unidad;

  const OcurrenciaPaginatedItem({
    required this.id,
    required this.numeroOcurrencia,
    required this.uuidCliente,
    required this.serenoId,
    required this.modalidadId,
    this.incidenciaId,
    this.patrullajeId,
    this.zonaId,
    this.unidadId,
    required this.origen,
    this.origenOtro,
    required this.modalidadPatrullaje,
    required this.tipoPatrullaje,
    this.tipoPatrullajeOtro,
    required this.turno,
    this.placaVehiculo,
    this.tipoVehiculo,
    this.tipoVehiculoOtro,
    required this.fechaOcurrencia,
    this.horaAlerta,
    this.horaLlegada,
    this.horaRepliegue,
    required this.resultado,
    this.relacionVictimaVictimario,
    this.tipoLugar,
    this.tipoLugarOtro,
    this.tipoVia,
    this.direccion,
    this.referencia,
    this.manzana,
    this.lote,
    this.tipoZona,
    this.nombreZona,
    this.sectorPatrullaje,
    this.ubigeo,
    this.latitud,
    this.longitud,
    this.datosImportantes,
    required this.estado,
    this.motivoAnulacion,
    required this.estadoRemision,
    this.fechaRemision,
    this.constanciaRemision,
    required this.createdAt,
    required this.updatedAt,
    this.sereno,
    this.modalidad,
    this.incidencia,
    this.patrullaje,
    this.zonas,
    this.unidad,
  });

  String get nombreSereno {
    return sereno?.persona?.nombreCompleto ?? 'Sin sereno';
  }

  String get codigoClasificador {
    return modalidad?.codigo ?? '';
  }

  String get nombreClasificador {
    return modalidad?.nombre ?? 'Sin clasificador';
  }

  double? get latitudValue => double.tryParse(latitud ?? '');

  double? get longitudValue => double.tryParse(longitud ?? '');

  factory OcurrenciaPaginatedItem.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedItem(
      id: _asInt(json['id']),
      numeroOcurrencia: _asString(json['numero_ocurrencia']),
      uuidCliente: _asString(json['uuid_cliente']),
      serenoId: _asInt(json['sereno_id']),
      modalidadId: _asInt(json['modalidad_id']),
      incidenciaId: _asNullableInt(json['incidencia_id']),
      patrullajeId: _asNullableInt(json['patrullaje_id']),
      zonaId: _asNullableInt(json['zona_id']),
      unidadId: _asNullableInt(json['unidad_id']),
      origen: _asString(json['origen']),
      origenOtro: _asNullableString(json['origen_otro']),
      modalidadPatrullaje: _asString(json['modalidad_patrullaje']),
      tipoPatrullaje: _asString(json['tipo_patrullaje']),
      tipoPatrullajeOtro: _asNullableString(json['tipo_patrullaje_otro']),
      turno: _asString(json['turno']),
      placaVehiculo: _asNullableString(json['placa_vehiculo']),
      tipoVehiculo: _asNullableString(json['tipo_vehiculo']),
      tipoVehiculoOtro: _asNullableString(json['tipo_vehiculo_otro']),
      fechaOcurrencia: _asString(json['fecha_ocurrencia']),
      horaAlerta: _asNullableString(json['hora_alerta']),
      horaLlegada: _asNullableString(json['hora_llegada']),
      horaRepliegue: _asNullableString(json['hora_repliegue']),
      resultado: _asString(json['resultado']),
      relacionVictimaVictimario: _asNullableString(
        json['relacion_victima_victimario'],
      ),
      tipoLugar: _asNullableString(json['tipo_lugar']),
      tipoLugarOtro: _asNullableString(json['tipo_lugar_otro']),
      tipoVia: _asNullableString(json['tipo_via']),
      direccion: _asNullableString(json['direccion']),
      referencia: _asNullableString(json['referencia']),
      manzana: _asNullableString(json['manzana']),
      lote: _asNullableString(json['lote']),
      tipoZona: _asNullableString(json['tipo_zona']),
      nombreZona: _asNullableString(json['nombre_zona']),
      sectorPatrullaje: _asNullableString(json['sector_patrullaje']),
      ubigeo: _asNullableString(json['ubigeo']),
      latitud: _asNullableString(json['latitud']),
      longitud: _asNullableString(json['longitud']),
      datosImportantes: _asNullableString(json['datos_importantes']),
      estado: _asString(json['estado']),
      motivoAnulacion: _asNullableString(json['motivo_anulacion']),
      estadoRemision: _asString(json['estado_remision']),
      fechaRemision: _asNullableString(json['fecha_remision']),
      constanciaRemision: _asNullableString(json['constancia_remision']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      sereno: _fromMap(json['sereno'], OcurrenciaPaginatedSereno.fromJson),
      modalidad: _fromMap(
        json['modalidad'],
        OcurrenciaPaginatedModalidad.fromJson,
      ),
      incidencia: _fromMap(
        json['incidencia'],
        OcurrenciaPaginatedIncidencia.fromJson,
      ),
      patrullaje: _fromMap(
        json['patrullaje'],
        OcurrenciaPaginatedPatrullaje.fromJson,
      ),
      zonas: _asNullableMap(json['zonas']),
      unidad: _asNullableMap(json['unidad']),
    );
  }
}

// ==========================================================
// SERENO
// ==========================================================
class OcurrenciaPaginatedSereno {
  final int id;
  final int personaId;
  final OcurrenciaPaginatedPersona? persona;

  const OcurrenciaPaginatedSereno({
    required this.id,
    required this.personaId,
    this.persona,
  });

  factory OcurrenciaPaginatedSereno.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedSereno(
      id: _asInt(json['id']),
      personaId: _asInt(json['persona_id']),
      persona: _fromMap(json['persona'], OcurrenciaPaginatedPersona.fromJson),
    );
  }
}

class OcurrenciaPaginatedPersona {
  final int id;
  final String nombres;
  final String apellidos;
  final String documentoIdentidad;

  const OcurrenciaPaginatedPersona({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.documentoIdentidad,
  });

  String get nombreCompleto {
    return '$nombres $apellidos'.trim();
  }

  factory OcurrenciaPaginatedPersona.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedPersona(
      id: _asInt(json['id']),
      nombres: _asString(json['nombres']),
      apellidos: _asString(json['apellidos']),
      documentoIdentidad: _asString(json['documento_identidad']),
    );
  }
}

// ==========================================================
// MODALIDAD RESUMIDA
// ==========================================================
class OcurrenciaPaginatedModalidad {
  final int id;
  final String codigo;
  final String nombre;
  final bool estado;
  final OcurrenciaPaginatedCategoriaEspecifica? categoriaEspecifica;

  const OcurrenciaPaginatedModalidad({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.estado,
    this.categoriaEspecifica,
  });

  factory OcurrenciaPaginatedModalidad.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedModalidad(
      id: _asInt(json['id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
      estado: _asBool(json['estado']),
      categoriaEspecifica: _fromMap(
        json['categoria_especifica'],
        OcurrenciaPaginatedCategoriaEspecifica.fromJson,
      ),
    );
  }
}

class OcurrenciaPaginatedCategoriaEspecifica {
  final int id;
  final String codigo;
  final String nombre;
  final OcurrenciaPaginatedCategoriaGenerica? categoriaGenerica;

  const OcurrenciaPaginatedCategoriaEspecifica({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.categoriaGenerica,
  });

  factory OcurrenciaPaginatedCategoriaEspecifica.fromJson(
    Map<String, dynamic> json,
  ) {
    return OcurrenciaPaginatedCategoriaEspecifica(
      id: _asInt(json['id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
      categoriaGenerica: _fromMap(
        json['categoria_generica'],
        OcurrenciaPaginatedCategoriaGenerica.fromJson,
      ),
    );
  }
}

class OcurrenciaPaginatedCategoriaGenerica {
  final int id;
  final String codigo;
  final String nombre;

  const OcurrenciaPaginatedCategoriaGenerica({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  factory OcurrenciaPaginatedCategoriaGenerica.fromJson(
    Map<String, dynamic> json,
  ) {
    return OcurrenciaPaginatedCategoriaGenerica(
      id: _asInt(json['id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
    );
  }
}

// ==========================================================
// INCIDENCIA RESUMIDA
// ==========================================================
class OcurrenciaPaginatedIncidencia {
  final int id;
  final int usuarioId;
  final int? patrullajeId;
  final int zonaId;
  final String tipo;
  final String descripcion;
  final String latitud;
  final String longitud;
  final String fechaHora;
  final String estado;
  final int totalEvidencias;
  final String origen;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaPaginatedIncidencia({
    required this.id,
    required this.usuarioId,
    this.patrullajeId,
    required this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    required this.estado,
    required this.totalEvidencias,
    required this.origen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaPaginatedIncidencia.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedIncidencia(
      id: _asInt(json['id']),
      usuarioId: _asInt(json['usuario_id']),
      patrullajeId: _asNullableInt(json['patrullaje_id']),
      zonaId: _asInt(json['zona_id']),
      tipo: _asString(json['tipo']),
      descripcion: _asString(json['descripcion']),
      latitud: _asString(json['latitud']),
      longitud: _asString(json['longitud']),
      fechaHora: _asString(json['fecha_hora']),
      estado: _asString(json['estado']),
      totalEvidencias: _asInt(json['total_evidencias']),
      origen: _asString(json['origen']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// PATRULLAJE RESUMIDO
// ==========================================================
class OcurrenciaPaginatedPatrullaje {
  final int id;
  final int unidadId;
  final int zonaId;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final String? descripcion;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaPaginatedPatrullaje({
    required this.id,
    required this.unidadId,
    required this.zonaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.descripcion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaPaginatedPatrullaje.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPaginatedPatrullaje(
      id: _asInt(json['id']),
      unidadId: _asInt(json['unidad_id']),
      zonaId: _asInt(json['zona_id']),
      fecha: _asString(json['fecha']),
      horaInicio: _asString(json['hora_inicio']),
      horaFin: _asString(json['hora_fin']),
      estado: _asString(json['estado']),
      descripcion: _asNullableString(json['descripcion']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// PAGINACIÓN
// ==========================================================
class OcurrenciaPagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const OcurrenciaPagination({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  const OcurrenciaPagination.empty()
    : totalItems = 0,
      totalPages = 0,
      currentPage = 1,
      pageSize = 20,
      hasNextPage = false,
      hasPreviousPage = false;

  factory OcurrenciaPagination.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPagination(
      totalItems: _asInt(json['totalItems']),
      totalPages: _asInt(json['totalPages']),
      currentPage: _asInt(json['currentPage'], fallback: 1),
      pageSize: _asInt(json['pageSize'], fallback: 20),
      hasNextPage: _asBool(json['hasNextPage']),
      hasPreviousPage: _asBool(json['hasPreviousPage']),
    );
  }
}

// ==========================================================
// FILTROS APLICADOS POR EL BACKEND
// ==========================================================
class OcurrenciaAppliedFilters {
  final String? numero;
  final String? codigo;
  final String? fecha;
  final String? fechaDesde;
  final String? fechaHasta;
  final int? serenoId;
  final int? zonaId;
  final String? turno;
  final String? estado;
  final String? estadoRemision;

  const OcurrenciaAppliedFilters({
    this.numero,
    this.codigo,
    this.fecha,
    this.fechaDesde,
    this.fechaHasta,
    this.serenoId,
    this.zonaId,
    this.turno,
    this.estado,
    this.estadoRemision,
  });

  factory OcurrenciaAppliedFilters.fromJson(Map<String, dynamic> json) {
    return OcurrenciaAppliedFilters(
      numero: _asNullableString(json['numero']),
      codigo: _asNullableString(json['codigo']),
      fecha: _asNullableString(json['fecha']),
      fechaDesde: _asNullableString(json['fecha_desde']),
      fechaHasta: _asNullableString(json['fecha_hasta']),
      serenoId: _asNullableInt(json['sereno_id']),
      zonaId: _asNullableInt(json['zona_id']),
      turno: _asNullableString(json['turno']),
      estado: _asNullableString(json['estado']),
      estadoRemision: _asNullableString(json['estado_remision']),
    );
  }
}

// ==========================================================
// HELPERS PRIVADOS
// ==========================================================
int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}

String _asString(dynamic value) {
  return value?.toString() ?? '';
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;

  final result = value.toString().trim();

  return result.isEmpty ? null : result;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  return value?.toString().toLowerCase() == 'true';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);

  return <String, dynamic>{};
}

Map<String, dynamic>? _asNullableMap(dynamic value) {
  if (value == null) return null;

  return _asMap(value);
}

T? _fromMap<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value == null) return null;

  final map = _asMap(value);

  if (map.isEmpty) return null;

  return fromJson(map);
}

List<T> _fromList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
