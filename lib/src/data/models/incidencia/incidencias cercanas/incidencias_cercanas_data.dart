class IncidenciasCercanasData {
  final double latitud;
  final double longitud;
  final double radioMetros;
  final int limit;
  final int total;

  final List<IncidenciaCercanaData> items;

  const IncidenciasCercanasData({
    required this.latitud,
    required this.longitud,
    required this.radioMetros,
    required this.limit,
    required this.total,
    required this.items,
  });

  factory IncidenciasCercanasData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return IncidenciasCercanasData(
      latitud: _CercanasJsonParser.parseDouble(json['latitud']),
      longitud: _CercanasJsonParser.parseDouble(json['longitud']),
      radioMetros: _CercanasJsonParser.parseDouble(json['radio_metros']),
      limit: _CercanasJsonParser.parseInt(json['limit']),
      total: _CercanasJsonParser.parseInt(json['total']),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => IncidenciaCercanaData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get tieneResultados => items.isNotEmpty;

  bool get estaVacio => items.isEmpty;
}

class IncidenciaCercanaData {
  final int id;
  final int usuarioId;
  final int? patrullajeId;
  final int zonaId;

  final String tipo;
  final String descripcion;

  final double latitud;
  final double longitud;
  final double distanciaMetros;

  final DateTime fechaHora;
  final String estado;
  final int totalEvidencias;
  final String origen;

  final DateTime createdAt;
  final DateTime updatedAt;

  final IncidenciaCercanaUsuarioData? usuario;
  final IncidenciaCercanaZonaData? zona;
  final List<IncidenciaCercanaArchivoData> archivos;

  const IncidenciaCercanaData({
    required this.id,
    required this.usuarioId,
    required this.patrullajeId,
    required this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.distanciaMetros,
    required this.fechaHora,
    required this.estado,
    required this.totalEvidencias,
    required this.origen,
    required this.createdAt,
    required this.updatedAt,
    required this.usuario,
    required this.zona,
    required this.archivos,
  });

  factory IncidenciaCercanaData.fromJson(Map<String, dynamic> json) {
    final rawArchivos = json['archivos'];

    return IncidenciaCercanaData(
      id: _CercanasJsonParser.parseInt(json['id']),
      usuarioId: _CercanasJsonParser.parseInt(json['usuario_id']),
      patrullajeId: _CercanasJsonParser.parseNullableInt(json['patrullaje_id']),
      zonaId: _CercanasJsonParser.parseInt(json['zona_id']),
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _CercanasJsonParser.parseDouble(json['latitud']),
      longitud: _CercanasJsonParser.parseDouble(json['longitud']),
      distanciaMetros: _CercanasJsonParser.parseDouble(
        json['distancia_metros'],
      ),
      fechaHora: _CercanasJsonParser.parseDateTime(json['fecha_hora']),
      estado: json['estado']?.toString() ?? '',
      totalEvidencias: _CercanasJsonParser.parseInt(json['total_evidencias']),
      origen: json['origen']?.toString() ?? '',
      createdAt: _CercanasJsonParser.parseDateTime(json['createdAt']),
      updatedAt: _CercanasJsonParser.parseDateTime(json['updatedAt']),
      usuario: json['usuario'] is Map
          ? IncidenciaCercanaUsuarioData.fromJson(
              Map<String, dynamic>.from(json['usuario'] as Map),
            )
          : null,
      zona: json['zona'] is Map
          ? IncidenciaCercanaZonaData.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            )
          : null,
      archivos: rawArchivos is List
          ? rawArchivos
                .whereType<Map>()
                .map(
                  (archivo) => IncidenciaCercanaArchivoData.fromJson(
                    Map<String, dynamic>.from(archivo),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get tieneEvidencias => totalEvidencias > 0;

  String get distanciaFormateada {
    if (distanciaMetros < 1000) {
      return '${distanciaMetros.toStringAsFixed(0)} m';
    }

    final kilometros = distanciaMetros / 1000;

    return '${kilometros.toStringAsFixed(1)} km';
  }
}

class IncidenciaCercanaUsuarioData {
  final int id;
  final String username;
  final IncidenciaCercanaPersonaData? persona;

  const IncidenciaCercanaUsuarioData({
    required this.id,
    required this.username,
    required this.persona,
  });

  factory IncidenciaCercanaUsuarioData.fromJson(Map<String, dynamic> json) {
    return IncidenciaCercanaUsuarioData(
      id: _CercanasJsonParser.parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      persona: json['persona'] is Map
          ? IncidenciaCercanaPersonaData.fromJson(
              Map<String, dynamic>.from(json['persona'] as Map),
            )
          : null,
    );
  }

  String get nombreCompleto {
    final nombre = persona?.nombreCompleto ?? '';

    return nombre.trim().isNotEmpty ? nombre : username;
  }
}

class IncidenciaCercanaPersonaData {
  final int id;
  final String nombres;
  final String apellidos;
  final String? fotoPerfil;

  const IncidenciaCercanaPersonaData({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.fotoPerfil,
  });

  factory IncidenciaCercanaPersonaData.fromJson(Map<String, dynamic> json) {
    return IncidenciaCercanaPersonaData(
      id: _CercanasJsonParser.parseInt(json['id']),
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      fotoPerfil: json['foto_perfil']?.toString(),
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}

class IncidenciaCercanaZonaData {
  final int id;
  final String nombre;

  const IncidenciaCercanaZonaData({required this.id, required this.nombre});

  factory IncidenciaCercanaZonaData.fromJson(Map<String, dynamic> json) {
    return IncidenciaCercanaZonaData(
      id: _CercanasJsonParser.parseInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class IncidenciaCercanaArchivoData {
  final int id;
  final String urlArchivo;
  final String tipoArchivo;
  final String mimeType;
  final int? peso;
  final DateTime? createdAt;

  const IncidenciaCercanaArchivoData({
    required this.id,
    required this.urlArchivo,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
    required this.createdAt,
  });

  factory IncidenciaCercanaArchivoData.fromJson(Map<String, dynamic> json) {
    return IncidenciaCercanaArchivoData(
      id: _CercanasJsonParser.parseInt(json['id']),
      urlArchivo: json['url_archivo']?.toString() ?? '',
      tipoArchivo: json['tipo_archivo']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      peso: _CercanasJsonParser.parseNullableInt(json['peso']),
      createdAt: _CercanasJsonParser.parseNullableDateTime(json['createdAt']),
    );
  }

  bool get esImagen => tipoArchivo.toUpperCase() == 'IMAGEN';

  bool get esVideo => tipoArchivo.toUpperCase() == 'VIDEO';
}

class _CercanasJsonParser {
  const _CercanasJsonParser._();

  static int parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw FormatException('La fecha recibida no es válida: $value');
    }

    return parsed;
  }

  static DateTime? parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}
