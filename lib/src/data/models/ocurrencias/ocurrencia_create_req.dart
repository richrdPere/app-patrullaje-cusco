class CreateOcurrenciaRequest {
  final String uuidCliente;
  final String codigoOcurrencia;

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

  final double? latitud;
  final double? longitud;

  final String? datosImportantes;

  final List<CreateOcurrenciaPersonaRequest> personas;
  final List<CreateOcurrenciaConsecuenciaRequest> consecuencias;
  final List<CreateOcurrenciaMedioEmpleadoRequest> mediosEmpleados;
  final List<CreateOcurrenciaEfectivoPnpRequest> efectivosPnp;

  const CreateOcurrenciaRequest({
    required this.uuidCliente,
    required this.codigoOcurrencia,
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
    this.personas = const [],
    this.consecuencias = const [],
    this.mediosEmpleados = const [],
    this.efectivosPnp = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'uuid_cliente': uuidCliente.trim(),
      'codigo_ocurrencia': codigoOcurrencia.trim(),

      'incidencia_id': incidenciaId,
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'unidad_id': unidadId,

      'origen': origen,
      'origen_otro': _nullableText(origenOtro),
      'modalidad_patrullaje': modalidadPatrullaje,
      'tipo_patrullaje': tipoPatrullaje,
      'tipo_patrullaje_otro': _nullableText(tipoPatrullajeOtro),
      'turno': turno,

      'placa_vehiculo': _nullableText(placaVehiculo),
      'tipo_vehiculo': _nullableText(tipoVehiculo),
      'tipo_vehiculo_otro': _nullableText(tipoVehiculoOtro),

      'fecha_ocurrencia': fechaOcurrencia,
      'hora_alerta': _nullableText(horaAlerta),
      'hora_llegada': _nullableText(horaLlegada),
      'hora_repliegue': _nullableText(horaRepliegue),

      'resultado': resultado,
      'relacion_victima_victimario': _nullableText(relacionVictimaVictimario),

      'tipo_lugar': _nullableText(tipoLugar),
      'tipo_lugar_otro': _nullableText(tipoLugarOtro),
      'tipo_via': _nullableText(tipoVia),
      'direccion': _nullableText(direccion),
      'referencia': _nullableText(referencia),
      'manzana': _nullableText(manzana),
      'lote': _nullableText(lote),

      'tipo_zona': _nullableText(tipoZona),
      'nombre_zona': _nullableText(nombreZona),
      'sector_patrullaje': _nullableText(sectorPatrullaje),
      'ubigeo': _nullableText(ubigeo),

      'latitud': latitud,
      'longitud': longitud,

      'datos_importantes': _nullableText(datosImportantes),

      'personas': personas.map((item) => item.toJson()).toList(),
      'consecuencias': consecuencias.map((item) => item.toJson()).toList(),
      'medios_empleados': mediosEmpleados.map((item) => item.toJson()).toList(),
      'efectivos_pnp': efectivosPnp.map((item) => item.toJson()).toList(),
    };
  }

  CreateOcurrenciaRequest copyWith({
    String? uuidCliente,
    String? codigoOcurrencia,
    int? incidenciaId,
    int? patrullajeId,
    int? zonaId,
    int? unidadId,
    String? origen,
    String? origenOtro,
    String? modalidadPatrullaje,
    String? tipoPatrullaje,
    String? tipoPatrullajeOtro,
    String? turno,
    String? placaVehiculo,
    String? tipoVehiculo,
    String? tipoVehiculoOtro,
    String? fechaOcurrencia,
    String? horaAlerta,
    String? horaLlegada,
    String? horaRepliegue,
    String? resultado,
    String? relacionVictimaVictimario,
    String? tipoLugar,
    String? tipoLugarOtro,
    String? tipoVia,
    String? direccion,
    String? referencia,
    String? manzana,
    String? lote,
    String? tipoZona,
    String? nombreZona,
    String? sectorPatrullaje,
    String? ubigeo,
    double? latitud,
    double? longitud,
    String? datosImportantes,
    List<CreateOcurrenciaPersonaRequest>? personas,
    List<CreateOcurrenciaConsecuenciaRequest>? consecuencias,
    List<CreateOcurrenciaMedioEmpleadoRequest>? mediosEmpleados,
    List<CreateOcurrenciaEfectivoPnpRequest>? efectivosPnp,
  }) {
    return CreateOcurrenciaRequest(
      uuidCliente: uuidCliente ?? this.uuidCliente,
      codigoOcurrencia: codigoOcurrencia ?? this.codigoOcurrencia,
      incidenciaId: incidenciaId ?? this.incidenciaId,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      zonaId: zonaId ?? this.zonaId,
      unidadId: unidadId ?? this.unidadId,
      origen: origen ?? this.origen,
      origenOtro: origenOtro ?? this.origenOtro,
      modalidadPatrullaje: modalidadPatrullaje ?? this.modalidadPatrullaje,
      tipoPatrullaje: tipoPatrullaje ?? this.tipoPatrullaje,
      tipoPatrullajeOtro: tipoPatrullajeOtro ?? this.tipoPatrullajeOtro,
      turno: turno ?? this.turno,
      placaVehiculo: placaVehiculo ?? this.placaVehiculo,
      tipoVehiculo: tipoVehiculo ?? this.tipoVehiculo,
      tipoVehiculoOtro: tipoVehiculoOtro ?? this.tipoVehiculoOtro,
      fechaOcurrencia: fechaOcurrencia ?? this.fechaOcurrencia,
      horaAlerta: horaAlerta ?? this.horaAlerta,
      horaLlegada: horaLlegada ?? this.horaLlegada,
      horaRepliegue: horaRepliegue ?? this.horaRepliegue,
      resultado: resultado ?? this.resultado,
      relacionVictimaVictimario:
          relacionVictimaVictimario ?? this.relacionVictimaVictimario,
      tipoLugar: tipoLugar ?? this.tipoLugar,
      tipoLugarOtro: tipoLugarOtro ?? this.tipoLugarOtro,
      tipoVia: tipoVia ?? this.tipoVia,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      manzana: manzana ?? this.manzana,
      lote: lote ?? this.lote,
      tipoZona: tipoZona ?? this.tipoZona,
      nombreZona: nombreZona ?? this.nombreZona,
      sectorPatrullaje: sectorPatrullaje ?? this.sectorPatrullaje,
      ubigeo: ubigeo ?? this.ubigeo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      datosImportantes: datosImportantes ?? this.datosImportantes,
      personas: personas ?? this.personas,
      consecuencias: consecuencias ?? this.consecuencias,
      mediosEmpleados: mediosEmpleados ?? this.mediosEmpleados,
      efectivosPnp: efectivosPnp ?? this.efectivosPnp,
    );
  }
}

// ==========================================================
// PERSONA INVOLUCRADA
// ==========================================================
class CreateOcurrenciaPersonaRequest {
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

  const CreateOcurrenciaPersonaRequest({
    required this.orden,
    required this.tipoPersona,
    required this.identificado,
    this.documentoIdentidad,
    this.nombresApellidos,
    this.genero,
    this.edad,
    this.edadEsAproximada = false,
    this.placa,
    this.caracteristicasFisicas,
    this.esComunidad = false,
    this.fuenteDatos = 'DIRECTA',
    this.observacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'orden': orden,
      'tipo_persona': tipoPersona,
      'identificado': identificado,
      'documento_identidad': _nullableText(documentoIdentidad),
      'nombres_apellidos': _nullableText(nombresApellidos),
      'genero': _nullableText(genero),
      'edad': edad,
      'edad_es_aproximada': edadEsAproximada,
      'placa': _nullableText(placa),
      'caracteristicas_fisicas': _nullableText(caracteristicasFisicas),
      'es_comunidad': esComunidad,
      'fuente_datos': fuenteDatos,
      'observacion': _nullableText(observacion),
    };
  }
}

// ==========================================================
// CONSECUENCIA
// ==========================================================
class CreateOcurrenciaConsecuenciaRequest {
  final String tipo;
  final String? descripcion;

  const CreateOcurrenciaConsecuenciaRequest({
    required this.tipo,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {'tipo': tipo, 'descripcion': _nullableText(descripcion)};
  }
}

// ==========================================================
// MEDIO EMPLEADO
// ==========================================================
class CreateOcurrenciaMedioEmpleadoRequest {
  final String tipo;
  final String? descripcion;

  const CreateOcurrenciaMedioEmpleadoRequest({
    required this.tipo,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {'tipo': tipo, 'descripcion': _nullableText(descripcion)};
  }
}

// ==========================================================
// EFECTIVO PNP
// ==========================================================
class CreateOcurrenciaEfectivoPnpRequest {
  final int? policiaId;

  // Se usan cuando el efectivo no proviene del catálogo.
  final String? apellidos;
  final String? nombres;
  final String? grado;
  final String? comisaria;
  final String? codigoInstitucional;

  final String? fuenteRegistro;
  final String? observacion;
  final String tipoParticipacion;
  final String? tipoParticipacionOtro;

  const CreateOcurrenciaEfectivoPnpRequest({
    this.policiaId,
    this.apellidos,
    this.nombres,
    this.grado,
    this.comisaria,
    this.codigoInstitucional,
    this.fuenteRegistro,
    this.observacion,
    required this.tipoParticipacion,
    this.tipoParticipacionOtro,
  });

  Map<String, dynamic> toJson() {
    return {
      'policia_id': policiaId,
      'apellidos': _nullableText(apellidos),
      'nombres': _nullableText(nombres),
      'grado': _nullableText(grado),
      'comisaria': _nullableText(comisaria),
      'codigo_institucional': _nullableText(codigoInstitucional),
      'fuente_registro': _nullableText(fuenteRegistro),
      'observacion': _nullableText(observacion),
      'tipo_participacion': tipoParticipacion,
      'tipo_participacion_otro': _nullableText(tipoParticipacionOtro),
    };
  }
}

// ==========================================================
// HELPER
// ==========================================================
String? _nullableText(String? value) {
  final normalized = value?.trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}
