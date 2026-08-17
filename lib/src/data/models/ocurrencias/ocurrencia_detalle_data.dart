class OcurrenciaDetalleData {
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

  final OcurrenciaSerenoData? sereno;
  final OcurrenciaModalidadData? modalidad;
  final OcurrenciaIncidenciaData? incidencia;
  final OcurrenciaPatrullajeData? patrullaje;

  // El endpoint actualmente devuelve null en estos campos.
  final Map<String, dynamic>? zonas;
  final Map<String, dynamic>? unidad;

  final List<OcurrenciaPersonaData> personas;
  final List<OcurrenciaMedioEmpleadoData> mediosEmpleados;
  final List<OcurrenciaConsecuenciaData> consecuencias;
  final List<OcurrenciaHistorialData> historial;
  final List<OcurrenciaEfectivoPnpData> efectivosPnp;

  const OcurrenciaDetalleData({
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
    this.personas = const [],
    this.mediosEmpleados = const [],
    this.consecuencias = const [],
    this.historial = const [],
    this.efectivosPnp = const [],
  });

  factory OcurrenciaDetalleData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaDetalleData(
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
      sereno: _fromMap(json['sereno'], OcurrenciaSerenoData.fromJson),
      modalidad: _fromMap(json['modalidad'], OcurrenciaModalidadData.fromJson),
      incidencia: _fromMap(
        json['incidencia'],
        OcurrenciaIncidenciaData.fromJson,
      ),
      patrullaje: _fromMap(
        json['patrullaje'],
        OcurrenciaPatrullajeData.fromJson,
      ),
      zonas: _asNullableMap(json['zonas']),
      unidad: _asNullableMap(json['unidad']),
      personas: _fromList(json['personas'], OcurrenciaPersonaData.fromJson),
      mediosEmpleados: _fromList(
        json['medios_empleados'],
        OcurrenciaMedioEmpleadoData.fromJson,
      ),
      consecuencias: _fromList(
        json['consecuencias'],
        OcurrenciaConsecuenciaData.fromJson,
      ),
      historial: _fromList(json['historial'], OcurrenciaHistorialData.fromJson),
      efectivosPnp: _fromList(
        json['efectivos_pnp'],
        OcurrenciaEfectivoPnpData.fromJson,
      ),
    );
  }
}

// ==========================================================
// SERENO
// ==========================================================
class OcurrenciaSerenoData {
  final int id;
  final int personaId;
  final OcurrenciaPersonaSerenoData? persona;

  const OcurrenciaSerenoData({
    required this.id,
    required this.personaId,
    this.persona,
  });

  factory OcurrenciaSerenoData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaSerenoData(
      id: _asInt(json['id']),
      personaId: _asInt(json['persona_id']),
      persona: _fromMap(json['persona'], OcurrenciaPersonaSerenoData.fromJson),
    );
  }
}

class OcurrenciaPersonaSerenoData {
  final int id;
  final String nombres;
  final String apellidos;
  final String documentoIdentidad;

  const OcurrenciaPersonaSerenoData({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.documentoIdentidad,
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory OcurrenciaPersonaSerenoData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPersonaSerenoData(
      id: _asInt(json['id']),
      nombres: _asString(json['nombres']),
      apellidos: _asString(json['apellidos']),
      documentoIdentidad: _asString(json['documento_identidad']),
    );
  }
}

// ==========================================================
// CLASIFICADOR
// ==========================================================
class OcurrenciaModalidadData {
  final int id;
  final int categoriaEspecificaId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final bool requiereAutor;
  final bool requiereVictima;
  final bool requiereConductor;
  final bool requiereDatosPnp;
  final bool requiereDescripcion;
  final int orden;
  final String vigenciaDesde;
  final String? vigenciaHasta;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final OcurrenciaCategoriaEspecificaData? categoriaEspecifica;
  final List<OcurrenciaReglaData> reglas;

  const OcurrenciaModalidadData({
    required this.id,
    required this.categoriaEspecificaId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.requiereAutor,
    required this.requiereVictima,
    required this.requiereConductor,
    required this.requiereDatosPnp,
    required this.requiereDescripcion,
    required this.orden,
    required this.vigenciaDesde,
    this.vigenciaHasta,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.categoriaEspecifica,
    this.reglas = const [],
  });

  factory OcurrenciaModalidadData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaModalidadData(
      id: _asInt(json['id']),
      categoriaEspecificaId: _asInt(json['categoria_especifica_id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
      descripcion: _asNullableString(json['descripcion']),
      requiereAutor: _asBool(json['requiere_autor']),
      requiereVictima: _asBool(json['requiere_victima']),
      requiereConductor: _asBool(json['requiere_conductor']),
      requiereDatosPnp: _asBool(json['requiere_datos_pnp']),
      requiereDescripcion: _asBool(json['requiere_descripcion']),
      orden: _asInt(json['orden']),
      vigenciaDesde: _asString(json['vigencia_desde']),
      vigenciaHasta: _asNullableString(json['vigencia_hasta']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      categoriaEspecifica: _fromMap(
        json['categoria_especifica'],
        OcurrenciaCategoriaEspecificaData.fromJson,
      ),
      reglas: _fromList(json['reglas'], OcurrenciaReglaData.fromJson),
    );
  }
}

class OcurrenciaCategoriaEspecificaData {
  final int id;
  final int categoriaGenericaId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final OcurrenciaCategoriaGenericaData? categoriaGenerica;

  const OcurrenciaCategoriaEspecificaData({
    required this.id,
    required this.categoriaGenericaId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.categoriaGenerica,
  });

  factory OcurrenciaCategoriaEspecificaData.fromJson(
    Map<String, dynamic> json,
  ) {
    return OcurrenciaCategoriaEspecificaData(
      id: _asInt(json['id']),
      categoriaGenericaId: _asInt(json['categoria_generica_id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
      descripcion: _asNullableString(json['descripcion']),
      orden: _asInt(json['orden']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      categoriaGenerica: _fromMap(
        json['categoria_generica'],
        OcurrenciaCategoriaGenericaData.fromJson,
      ),
    );
  }
}

class OcurrenciaCategoriaGenericaData {
  final int id;
  final int versionId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final OcurrenciaClasificadorVersionData? version;

  const OcurrenciaCategoriaGenericaData({
    required this.id,
    required this.versionId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.version,
  });

  factory OcurrenciaCategoriaGenericaData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaCategoriaGenericaData(
      id: _asInt(json['id']),
      versionId: _asInt(json['version_id']),
      codigo: _asString(json['codigo']),
      nombre: _asString(json['nombre']),
      descripcion: _asNullableString(json['descripcion']),
      orden: _asInt(json['orden']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      version: _fromMap(
        json['version'],
        OcurrenciaClasificadorVersionData.fromJson,
      ),
    );
  }
}

class OcurrenciaClasificadorVersionData {
  final int id;
  final String nombre;
  final String resolucion;
  final String? descripcion;
  final String fechaPublicacion;
  final String vigenciaDesde;
  final String? vigenciaHasta;
  final bool estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaClasificadorVersionData({
    required this.id,
    required this.nombre,
    required this.resolucion,
    this.descripcion,
    required this.fechaPublicacion,
    required this.vigenciaDesde,
    this.vigenciaHasta,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaClasificadorVersionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return OcurrenciaClasificadorVersionData(
      id: _asInt(json['id']),
      nombre: _asString(json['nombre']),
      resolucion: _asString(json['resolucion']),
      descripcion: _asNullableString(json['descripcion']),
      fechaPublicacion: _asString(json['fecha_publicacion']),
      vigenciaDesde: _asString(json['vigencia_desde']),
      vigenciaHasta: _asNullableString(json['vigencia_hasta']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class OcurrenciaReglaData {
  final int id;
  final int modalidadId;
  final String clave;
  final String? descripcion;
  final Map<String, dynamic>? parametros;
  final bool estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaReglaData({
    required this.id,
    required this.modalidadId,
    required this.clave,
    this.descripcion,
    this.parametros,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaReglaData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaReglaData(
      id: _asInt(json['id']),
      modalidadId: _asInt(json['modalidad_id']),
      clave: _asString(json['clave']),
      descripcion: _asNullableString(json['descripcion']),
      parametros: _asNullableMap(json['parametros']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// INCIDENCIA Y EVIDENCIAS
// ==========================================================
class OcurrenciaIncidenciaData {
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
  final List<OcurrenciaArchivoData> archivos;

  const OcurrenciaIncidenciaData({
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
    this.archivos = const [],
  });

  factory OcurrenciaIncidenciaData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaIncidenciaData(
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
      archivos: _fromList(json['archivos'], OcurrenciaArchivoData.fromJson),
    );
  }
}

class OcurrenciaArchivoData {
  final int id;
  final int incidenciaId;
  final String urlArchivo;
  final String keyS3;
  final String tipoArchivo;
  final String mimeType;
  final int peso;
  final int serenoId;
  final String estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaArchivoData({
    required this.id,
    required this.incidenciaId,
    required this.urlArchivo,
    required this.keyS3,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
    required this.serenoId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaArchivoData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaArchivoData(
      id: _asInt(json['id']),
      incidenciaId: _asInt(json['incidencia_id']),
      urlArchivo: _asString(json['url_archivo']),
      keyS3: _asString(json['key_s3']),
      tipoArchivo: _asString(json['tipo_archivo']),
      mimeType: _asString(json['mime_type']),
      peso: _asInt(json['peso']),
      serenoId: _asInt(json['sereno_id']),
      estado: _asString(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// PATRULLAJE
// ==========================================================
class OcurrenciaPatrullajeData {
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

  const OcurrenciaPatrullajeData({
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

  factory OcurrenciaPatrullajeData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPatrullajeData(
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
// PERSONAS
// ==========================================================
class OcurrenciaPersonaData {
  final int id;
  final int ocurrenciaId;
  final int orden;
  final String tipoPersona;
  final bool identificado;
  final String? documentoIdentidad;
  final String? nombresApellidos;
  final String? genero;
  final int? edad;
  final bool edadEsAproximada;
  final String? placa;
  final String? caracteristicasFisicas;
  final bool esComunidad;
  final String fuenteDatos;
  final String? observacion;
  final bool estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaPersonaData({
    required this.id,
    required this.ocurrenciaId,
    required this.orden,
    required this.tipoPersona,
    required this.identificado,
    this.documentoIdentidad,
    this.nombresApellidos,
    this.genero,
    this.edad,
    required this.edadEsAproximada,
    this.placa,
    this.caracteristicasFisicas,
    required this.esComunidad,
    required this.fuenteDatos,
    this.observacion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaPersonaData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaPersonaData(
      id: _asInt(json['id']),
      ocurrenciaId: _asInt(json['ocurrencia_id']),
      orden: _asInt(json['orden']),
      tipoPersona: _asString(json['tipo_persona']),
      identificado: _asBool(json['identificado']),
      documentoIdentidad: _asNullableString(json['documento_identidad']),
      nombresApellidos: _asNullableString(json['nombres_apellidos']),
      genero: _asNullableString(json['genero']),
      edad: _asNullableInt(json['edad']),
      edadEsAproximada: _asBool(json['edad_es_aproximada']),
      placa: _asNullableString(json['placa']),
      caracteristicasFisicas: _asNullableString(
        json['caracteristicas_fisicas'],
      ),
      esComunidad: _asBool(json['es_comunidad']),
      fuenteDatos: _asString(json['fuente_datos']),
      observacion: _asNullableString(json['observacion']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// MEDIOS Y CONSECUENCIAS
// ==========================================================
class OcurrenciaMedioEmpleadoData {
  final int id;
  final int ocurrenciaId;
  final String tipo;
  final String? descripcion;
  final bool estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaMedioEmpleadoData({
    required this.id,
    required this.ocurrenciaId,
    required this.tipo,
    this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaMedioEmpleadoData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaMedioEmpleadoData(
      id: _asInt(json['id']),
      ocurrenciaId: _asInt(json['ocurrencia_id']),
      tipo: _asString(json['tipo']),
      descripcion: _asNullableString(json['descripcion']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class OcurrenciaConsecuenciaData {
  final int id;
  final int ocurrenciaId;
  final String tipo;
  final String? descripcion;
  final bool estado;
  final String createdAt;
  final String updatedAt;

  const OcurrenciaConsecuenciaData({
    required this.id,
    required this.ocurrenciaId,
    required this.tipo,
    this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcurrenciaConsecuenciaData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaConsecuenciaData(
      id: _asInt(json['id']),
      ocurrenciaId: _asInt(json['ocurrencia_id']),
      tipo: _asString(json['tipo']),
      descripcion: _asNullableString(json['descripcion']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

// ==========================================================
// HISTORIAL
// ==========================================================
class OcurrenciaHistorialData {
  final int id;
  final int ocurrenciaId;
  final int usuarioId;
  final String accion;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final String? comentario;
  final Map<String, dynamic>? datosCambiados;
  final String origen;
  final String? direccionIp;
  final String? userAgent;
  final String createdAt;
  final OcurrenciaHistorialUsuarioData? usuario;

  const OcurrenciaHistorialData({
    required this.id,
    required this.ocurrenciaId,
    required this.usuarioId,
    required this.accion,
    this.estadoAnterior,
    this.estadoNuevo,
    this.comentario,
    this.datosCambiados,
    required this.origen,
    this.direccionIp,
    this.userAgent,
    required this.createdAt,
    this.usuario,
  });

  factory OcurrenciaHistorialData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaHistorialData(
      id: _asInt(json['id']),
      ocurrenciaId: _asInt(json['ocurrencia_id']),
      usuarioId: _asInt(json['usuario_id']),
      accion: _asString(json['accion']),
      estadoAnterior: _asNullableString(json['estado_anterior']),
      estadoNuevo: _asNullableString(json['estado_nuevo']),
      comentario: _asNullableString(json['comentario']),
      datosCambiados: _asNullableMap(json['datos_cambiados']),
      origen: _asString(json['origen']),
      direccionIp: _asNullableString(json['direccion_ip']),
      userAgent: _asNullableString(json['user_agent']),
      createdAt: _asString(json['created_at']),
      usuario: _fromMap(
        json['usuario'],
        OcurrenciaHistorialUsuarioData.fromJson,
      ),
    );
  }
}

class OcurrenciaHistorialUsuarioData {
  final int id;
  final int personaId;

  const OcurrenciaHistorialUsuarioData({
    required this.id,
    required this.personaId,
  });

  factory OcurrenciaHistorialUsuarioData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaHistorialUsuarioData(
      id: _asInt(json['id']),
      personaId: _asInt(json['persona_id']),
    );
  }
}

// ==========================================================
// EFECTIVOS PNP
// ==========================================================

class OcurrenciaEfectivoPnpData {
  final int id;
  final int ocurrenciaId;
  final int? policiaId;
  final String? apellidos;
  final String? nombres;
  final String? grado;
  final String? comisaria;
  final String? codigoInstitucional;
  final String fuenteRegistro;
  final String? observacion;
  final String tipoParticipacion;
  final String? tipoParticipacionOtro;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? policia;

  const OcurrenciaEfectivoPnpData({
    required this.id,
    required this.ocurrenciaId,
    this.policiaId,
    this.apellidos,
    this.nombres,
    this.grado,
    this.comisaria,
    this.codigoInstitucional,
    required this.fuenteRegistro,
    this.observacion,
    required this.tipoParticipacion,
    this.tipoParticipacionOtro,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.policia,
  });

  String get nombreCompleto {
    return [
      nombres,
      apellidos,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  }

  factory OcurrenciaEfectivoPnpData.fromJson(Map<String, dynamic> json) {
    return OcurrenciaEfectivoPnpData(
      id: _asInt(json['id']),
      ocurrenciaId: _asInt(json['ocurrencia_id']),
      policiaId: _asNullableInt(json['policia_id']),
      apellidos: _asNullableString(json['apellidos']),
      nombres: _asNullableString(json['nombres']),
      grado: _asNullableString(json['grado']),
      comisaria: _asNullableString(json['comisaria']),
      codigoInstitucional: _asNullableString(json['codigo_institucional']),
      fuenteRegistro: _asString(json['fuente_registro']),
      observacion: _asNullableString(json['observacion']),
      tipoParticipacion: _asString(json['tipo_participacion']),
      tipoParticipacionOtro: _asNullableString(json['tipo_participacion_otro']),
      estado: _asBool(json['estado']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
      policia: _asNullableMap(json['policia']),
    );
  }
}

// ==========================================================
// HELPERS PRIVADOS DE PARSEO
// ==========================================================
int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
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

  final result = value.toString();
  return result;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  return value?.toString().toLowerCase() == 'true';
}

Map<String, dynamic>? _asNullableMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);

  return null;
}

T? _fromMap<T>(dynamic value, T Function(Map<String, dynamic> json) fromJson) {
  final map = _asNullableMap(value);

  if (map == null) return null;

  return fromJson(map);
}

List<T> _fromList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
