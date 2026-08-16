class ClasificadorArbolData {
  final List<CategoriaGenericaModel> categorias;

  const ClasificadorArbolData({required this.categorias});

  factory ClasificadorArbolData.fromJson(dynamic json) {
    if (json is! List) {
      return const ClasificadorArbolData(categorias: []);
    }

    return ClasificadorArbolData(
      categorias: json
          .whereType<Map>()
          .map(
            (item) => CategoriaGenericaModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return categorias.map((item) => item.toJson()).toList();
  }

  bool get isEmpty => categorias.isEmpty;

  bool get isNotEmpty => categorias.isNotEmpty;

  int get totalCategoriasEspecificas {
    return categorias.fold(
      0,
      (total, categoria) => total + categoria.categoriasEspecificas.length,
    );
  }

  int get totalModalidades {
    return categorias.fold(
      0,
      (total, categoria) =>
          total +
          categoria.categoriasEspecificas.fold(
            0,
            (subtotal, categoriaEspecifica) =>
                subtotal + categoriaEspecifica.modalidades.length,
          ),
    );
  }

  List<ModalidadClasificadorModel> get todasLasModalidades {
    return categorias
        .expand((categoria) => categoria.categoriasEspecificas)
        .expand((categoria) => categoria.modalidades)
        .toList();
  }

  ModalidadClasificadorModel? findModalidadByCodigo(String codigo) {
    final normalizedCode = codigo.trim();

    for (final modalidad in todasLasModalidades) {
      if (modalidad.codigo == normalizedCode) {
        return modalidad;
      }
    }

    return null;
  }
}

// ==========================================================
// CATEGORÍA GENÉRICA
// ==========================================================
class CategoriaGenericaModel {
  final int id;
  final int versionId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;

  final ClasificadorVersionModel? version;

  final List<CategoriaEspecificaModel> categoriasEspecificas;

  const CategoriaGenericaModel({
    required this.id,
    required this.versionId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    this.version,
    required this.categoriasEspecificas,
  });

  factory CategoriaGenericaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaGenericaModel(
      id: _parseInt(json['id']),
      versionId: _parseInt(json['version_id']),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      orden: _parseInt(json['orden']),
      estado: _parseBool(json['estado']),
      version: json['version'] is Map
          ? ClasificadorVersionModel.fromJson(
              Map<String, dynamic>.from(json['version']),
            )
          : null,
      categoriasEspecificas: _parseList(
        json['categorias_especificas'],
        CategoriaEspecificaModel.fromJson,
      ),
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
      if (version != null) 'version': version!.toJson(),
      'categorias_especificas': categoriasEspecificas
          .map((item) => item.toJson())
          .toList(),
    };
  }
}

// ==========================================================
// VERSIÓN DEL CLASIFICADOR
// ==========================================================
class ClasificadorVersionModel {
  final int id;
  final String nombre;
  final String? resolucion;
  final String? descripcion;

  final DateTime? fechaPublicacion;
  final DateTime? vigenciaDesde;
  final DateTime? vigenciaHasta;

  final bool estado;

  const ClasificadorVersionModel({
    required this.id,
    required this.nombre,
    this.resolucion,
    this.descripcion,
    this.fechaPublicacion,
    this.vigenciaDesde,
    this.vigenciaHasta,
    required this.estado,
  });

  factory ClasificadorVersionModel.fromJson(Map<String, dynamic> json) {
    return ClasificadorVersionModel(
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
// CATEGORÍA ESPECÍFICA
// ==========================================================
class CategoriaEspecificaModel {
  final int id;
  final int categoriaGenericaId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int orden;
  final bool estado;

  final List<ModalidadClasificadorModel> modalidades;

  const CategoriaEspecificaModel({
    required this.id,
    required this.categoriaGenericaId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.orden,
    required this.estado,
    required this.modalidades,
  });

  factory CategoriaEspecificaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaEspecificaModel(
      id: _parseInt(json['id']),
      categoriaGenericaId: _parseInt(json['categoria_generica_id']),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      orden: _parseInt(json['orden']),
      estado: _parseBool(json['estado']),
      modalidades: _parseList(
        json['modalidades'],
        ModalidadClasificadorModel.fromJson,
      ),
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
      'modalidades': modalidades.map((item) => item.toJson()).toList(),
    };
  }
}

// ==========================================================
// MODALIDAD
// ==========================================================
class ModalidadClasificadorModel {
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

  final List<ReglaClasificadorModel> reglas;

  const ModalidadClasificadorModel({
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
    required this.reglas,
  });

  factory ModalidadClasificadorModel.fromJson(Map<String, dynamic> json) {
    return ModalidadClasificadorModel(
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
      reglas: _parseList(json['reglas'], ReglaClasificadorModel.fromJson),
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
      'reglas': reglas.map((item) => item.toJson()).toList(),
    };
  }

  bool get tieneReglas => reglas.isNotEmpty;

  bool get requiereDatosPersona {
    return requiereAutor || requiereVictima || requiereConductor;
  }
}

// ==========================================================
// REGLA
// ==========================================================
class ReglaClasificadorModel {
  final int id;
  final int modalidadId;
  final String clave;
  final String? descripcion;

  final Map<String, dynamic> parametros;

  final bool estado;

  const ReglaClasificadorModel({
    required this.id,
    required this.modalidadId,
    required this.clave,
    this.descripcion,
    required this.parametros,
    required this.estado,
  });

  factory ReglaClasificadorModel.fromJson(Map<String, dynamic> json) {
    return ReglaClasificadorModel(
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
// HELPERS DE PARSEO
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

  final normalizedValue = value?.toString().trim().toLowerCase();

  return normalizedValue == 'true' || normalizedValue == '1';
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
