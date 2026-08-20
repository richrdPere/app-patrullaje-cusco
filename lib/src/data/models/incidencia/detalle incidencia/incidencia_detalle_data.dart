class IncidenciaDetalleData {
  final int id;
  final int usuarioId;
  final int? patrullajeId;
  final int zonaId;

  final String tipo;
  final String descripcion;

  final double latitud;
  final double longitud;

  final DateTime fechaHora;
  final String estado;
  final int totalEvidencias;
  final String origen;

  final DateTime createdAt;
  final DateTime updatedAt;

  final IncidenciaDetalleUsuario? usuario;
  final IncidenciaDetalleZona? zona;
  final IncidenciaDetallePatrullaje? patrullaje;

  final List<IncidenciaDetalleArchivo> archivos;

  const IncidenciaDetalleData({
    required this.id,
    required this.usuarioId,
    required this.patrullajeId,
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
    required this.usuario,
    required this.zona,
    required this.patrullaje,
    required this.archivos,
  });

  factory IncidenciaDetalleData.fromJson(Map<String, dynamic> json) {
    final rawArchivos = json['archivos'];

    return IncidenciaDetalleData(
      id: _JsonParser.parseInt(json['id']),
      usuarioId: _JsonParser.parseInt(json['usuario_id']),
      patrullajeId: _JsonParser.parseNullableInt(json['patrullaje_id']),
      zonaId: _JsonParser.parseInt(json['zona_id']),
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _JsonParser.parseDouble(json['latitud']),
      longitud: _JsonParser.parseDouble(json['longitud']),
      fechaHora: _JsonParser.parseDateTime(json['fecha_hora']),
      estado: json['estado']?.toString() ?? '',
      totalEvidencias: _JsonParser.parseInt(json['total_evidencias']),
      origen: json['origen']?.toString() ?? '',
      createdAt: _JsonParser.parseDateTime(json['createdAt']),
      updatedAt: _JsonParser.parseDateTime(json['updatedAt']),
      usuario: json['usuario'] is Map
          ? IncidenciaDetalleUsuario.fromJson(
              Map<String, dynamic>.from(json['usuario'] as Map),
            )
          : null,
      zona: json['zona'] is Map
          ? IncidenciaDetalleZona.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            )
          : null,
      patrullaje: json['patrullaje'] is Map
          ? IncidenciaDetallePatrullaje.fromJson(
              Map<String, dynamic>.from(json['patrullaje'] as Map),
            )
          : null,
      archivos: rawArchivos is List
          ? rawArchivos
                .whereType<Map>()
                .map(
                  (archivo) => IncidenciaDetalleArchivo.fromJson(
                    Map<String, dynamic>.from(archivo),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get tieneArchivos => archivos.isNotEmpty;

  bool get tienePatrullaje => patrullajeId != null && patrullaje != null;
}

class IncidenciaDetalleUsuario {
  final int id;
  final String username;
  final IncidenciaDetallePersona? persona;

  const IncidenciaDetalleUsuario({
    required this.id,
    required this.username,
    required this.persona,
  });

  factory IncidenciaDetalleUsuario.fromJson(Map<String, dynamic> json) {
    return IncidenciaDetalleUsuario(
      id: _JsonParser.parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      persona: json['persona'] is Map
          ? IncidenciaDetallePersona.fromJson(
              Map<String, dynamic>.from(json['persona'] as Map),
            )
          : null,
    );
  }

  String get nombreCompleto {
    final nombre = persona?.nombreCompleto.trim() ?? '';

    return nombre.isNotEmpty ? nombre : username;
  }
}

class IncidenciaDetallePersona {
  final int id;
  final String nombres;
  final String apellidos;

  const IncidenciaDetallePersona({
    required this.id,
    required this.nombres,
    required this.apellidos,
  });

  factory IncidenciaDetallePersona.fromJson(Map<String, dynamic> json) {
    return IncidenciaDetallePersona(
      id: _JsonParser.parseInt(json['id']),
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();
}

class IncidenciaDetalleZona {
  final int id;
  final String nombre;

  const IncidenciaDetalleZona({required this.id, required this.nombre});

  factory IncidenciaDetalleZona.fromJson(Map<String, dynamic> json) {
    return IncidenciaDetalleZona(
      id: _JsonParser.parseInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class IncidenciaDetallePatrullaje {
  final int id;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;

  const IncidenciaDetallePatrullaje({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  factory IncidenciaDetallePatrullaje.fromJson(Map<String, dynamic> json) {
    return IncidenciaDetallePatrullaje(
      id: _JsonParser.parseInt(json['id']),
      fecha: _JsonParser.parseDateTime(json['fecha']),
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
    );
  }
}

class IncidenciaDetalleArchivo {
  final int id;
  final String urlArchivo;
  final String tipoArchivo;
  final String mimeType;
  final int? peso;

  const IncidenciaDetalleArchivo({
    required this.id,
    required this.urlArchivo,
    required this.tipoArchivo,
    required this.mimeType,
    required this.peso,
  });

  factory IncidenciaDetalleArchivo.fromJson(Map<String, dynamic> json) {
    return IncidenciaDetalleArchivo(
      id: _JsonParser.parseInt(json['id']),
      urlArchivo: json['url_archivo']?.toString() ?? '',
      tipoArchivo: json['tipo_archivo']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      peso: _JsonParser.parseNullableInt(json['peso']),
    );
  }

  bool get esImagen => tipoArchivo.toUpperCase() == 'IMAGEN';

  bool get esVideo => tipoArchivo.toUpperCase() == 'VIDEO';

  bool get esPdf => tipoArchivo.toUpperCase() == 'PDF';

  double? get pesoEnMb {
    if (peso == null) {
      return null;
    }

    return peso! / (1024 * 1024);
  }
}

class _JsonParser {
  const _JsonParser._();

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
}
