class ClasificadorCodigoData {
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
  final DateTime? vigenciaDesde;
  final DateTime? vigenciaHasta;
  final bool estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ClasificadorCodigoCategoriaEspecifica? categoriaEspecifica;
  final List<ClasificadorCodigoRegla> reglas;

  const ClasificadorCodigoData({
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
    this.vigenciaDesde,
    this.vigenciaHasta,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.categoriaEspecifica,
    required this.reglas,
  });

  factory ClasificadorCodigoData.fromJson(Map<String, dynamic> json) {
    return ClasificadorCodigoData(
      id: _parseInt(json['id']),
      categoriaEspecificaId: _parseInt(json['categoria_especifica_id']),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      requiereAutor: _parseBool(json['requiere_autor']),
      requiereVictima: _parseBool(json['requiere_victima']),
      requiereConductor: _parseBool(json['requiere_conductor']),
      requiereDatosPnp: _parseBool(json['requiere_datos_pnp']),
      requiereDescripcion: _parseBool(json['requiere_descripcion']),
      orden: _parseInt(json['orden']),
      vigenciaDesde: _parseDateTime(json['vigencia_desde']),
      vigenciaHasta: _parseDateTime(json['vigencia_hasta']),
      estado: _parseBool(json['estado']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      categoriaEspecifica: json['categoria_especifica'] is Map
          ? ClasificadorCodigoCategoriaEspecifica.fromJson(
              Map<String, dynamic>.from(json['categoria_especifica']),
            )
          : null,
      reglas: _parseList(json['reglas'], ClasificadorCodigoRegla.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria_especifica_id': categoriaEspecificaId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'requiere_autor': requiereAutor,
      'requiere_victima': requiereVictima,
      'requiere_conductor': requiereConductor,
      'requiere_datos_pnp': requiereDatosPnp,
      'requiere_descripcion': requiereDescripcion,
      'orden': orden,
      'vigencia_desde': _formatDate(vigenciaDesde),
      'vigencia_hasta': _formatDate(vigenciaHasta),
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'categoria_especifica': categoriaEspecifica?.toJson(),
      'reglas': reglas.map((regla) => regla.toJson()).toList(),
    };
  }

  bool get estaActivo => estado;

  bool get tieneReglas => reglas.isNotEmpty;

  bool get tieneVigenciaVencida {
    if (vigenciaHasta == null) {
      return false;
    }

    return DateTime.now().isAfter(vigenciaHasta!);
  }

  bool get requierePersonas {
    return requiereAutor || requiereVictima || requiereConductor;
  }

  bool get requiereDatosAdicionales {
    return requiereDatosPnp ||
        requiereDescripcion ||
        requierePersonas ||
        reglas.isNotEmpty;
  }
}

// ==========================================================
// CATEGORÍA ESPECÍFICA
// ==========================================================
class ClasificadorCodigoCategoriaEspecifica {
  final int id;
  final int categoriaGenericaId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ClasificadorCodigoCategoriaGenerica? categoriaGenerica;

  const ClasificadorCodigoCategoriaEspecifica({
    required this.id,
    required this.categoriaGenericaId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.categoriaGenerica,
  });

  factory ClasificadorCodigoCategoriaEspecifica.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClasificadorCodigoCategoriaEspecifica(
      id: _parseInt(json['id']),
      categoriaGenericaId: _parseInt(json['categoria_generica_id']),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      orden: _parseInt(json['orden']),
      estado: _parseBool(json['estado']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      categoriaGenerica: json['categoria_generica'] is Map
          ? ClasificadorCodigoCategoriaGenerica.fromJson(
              Map<String, dynamic>.from(json['categoria_generica']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria_generica_id': categoriaGenericaId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'orden': orden,
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'categoria_generica': categoriaGenerica?.toJson(),
    };
  }
}

// ==========================================================
// CATEGORÍA GENÉRICA
// ==========================================================
class ClasificadorCodigoCategoriaGenerica {
  final int id;
  final int versionId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ClasificadorCodigoVersion? version;

  const ClasificadorCodigoCategoriaGenerica({
    required this.id,
    required this.versionId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory ClasificadorCodigoCategoriaGenerica.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClasificadorCodigoCategoriaGenerica(
      id: _parseInt(json['id']),
      versionId: _parseInt(json['version_id']),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      orden: _parseInt(json['orden']),
      estado: _parseBool(json['estado']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      version: json['version'] is Map
          ? ClasificadorCodigoVersion.fromJson(
              Map<String, dynamic>.from(json['version']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_id': versionId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'orden': orden,
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version?.toJson(),
    };
  }
}

// ==========================================================
// VERSIÓN
// ==========================================================
class ClasificadorCodigoVersion {
  final int id;
  final String nombre;
  final String? resolucion;
  final String? descripcion;

  final DateTime? fechaPublicacion;
  final DateTime? vigenciaDesde;
  final DateTime? vigenciaHasta;

  final bool estado;

  const ClasificadorCodigoVersion({
    required this.id,
    required this.nombre,
    this.resolucion,
    this.descripcion,
    this.fechaPublicacion,
    this.vigenciaDesde,
    this.vigenciaHasta,
    required this.estado,
  });

  factory ClasificadorCodigoVersion.fromJson(Map<String, dynamic> json) {
    return ClasificadorCodigoVersion(
      id: _parseInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
      resolucion: _parseNullableString(json['resolucion']),
      descripcion: _parseNullableString(json['descripcion']),
      fechaPublicacion: _parseDateTime(json['fecha_publicacion']),
      vigenciaDesde: _parseDateTime(json['vigencia_desde']),
      vigenciaHasta: _parseDateTime(json['vigencia_hasta']),
      estado: _parseBool(json['estado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'resolucion': resolucion,
      'descripcion': descripcion,
      'fecha_publicacion': _formatDate(fechaPublicacion),
      'vigencia_desde': _formatDate(vigenciaDesde),
      'vigencia_hasta': _formatDate(vigenciaHasta),
      'estado': estado,
    };
  }
}

// ==========================================================
// REGLA
// ==========================================================
class ClasificadorCodigoRegla {
  final int id;
  final int modalidadId;
  final String clave;
  final String? descripcion;
  final Map<String, dynamic> parametros;
  final bool estado;

  const ClasificadorCodigoRegla({
    required this.id,
    required this.modalidadId,
    required this.clave,
    this.descripcion,
    required this.parametros,
    required this.estado,
  });

  factory ClasificadorCodigoRegla.fromJson(Map<String, dynamic> json) {
    return ClasificadorCodigoRegla(
      id: _parseInt(json['id']),
      modalidadId: _parseInt(json['modalidad_id']),
      clave: json['clave']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      parametros: json['parametros'] is Map
          ? Map<String, dynamic>.from(json['parametros'])
          : <String, dynamic>{},
      estado: _parseBool(json['estado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modalidad_id': modalidadId,
      'clave': clave,
      'descripcion': descripcion,
      'parametros': parametros,
      'estado': estado,
    };
  }

  String? get campo => parametros['campo']?.toString();
  int? get maximoCaracteres {
    return int.tryParse(parametros['maximo_caracteres']?.toString() ?? '');
  }
  String? get origen => parametros['origen']?.toString();
  String? get destino => parametros['destino']?.toString();
}

// ==========================================================
// PARSERS
// ==========================================================
List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final normalized = value?.toString().trim().toLowerCase();

  return normalized == 'true' || normalized == '1';
}

String? _parseNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  if (text.isEmpty) {
    return null;
  }

  return DateTime.tryParse(text);
}

String? _formatDate(DateTime? value) {
  if (value == null) {
    return null;
  }

  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
