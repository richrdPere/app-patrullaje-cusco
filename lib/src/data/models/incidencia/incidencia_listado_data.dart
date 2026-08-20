class IncidenciaListadoData {
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

  final IncidenciaUsuarioData? usuario;
  final IncidenciaZonaData? zona;

  const IncidenciaListadoData({
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
  });

  factory IncidenciaListadoData.fromJson(Map<String, dynamic> json) {
    return IncidenciaListadoData(
      id: _parseInt(json['id']),
      usuarioId: _parseInt(json['usuario_id']),
      patrullajeId: _parseNullableInt(json['patrullaje_id']),
      zonaId: _parseInt(json['zona_id']),
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
      fechaHora: _parseDateTime(json['fecha_hora']),
      estado: json['estado']?.toString() ?? '',
      totalEvidencias: _parseInt(json['total_evidencias']),
      origen: json['origen']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      usuario: json['usuario'] is Map
          ? IncidenciaUsuarioData.fromJson(
              Map<String, dynamic>.from(json['usuario'] as Map),
            )
          : null,
      zona: json['zona'] is Map
          ? IncidenciaZonaData.fromJson(
              Map<String, dynamic>.from(json['zona'] as Map),
            )
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class IncidenciaUsuarioData {
  final int id;
  final String username;
  final IncidenciaPersonaData? persona;

  const IncidenciaUsuarioData({
    required this.id,
    required this.username,
    required this.persona,
  });

  factory IncidenciaUsuarioData.fromJson(Map<String, dynamic> json) {
    return IncidenciaUsuarioData(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      persona: json['persona'] is Map
          ? IncidenciaPersonaData.fromJson(
              Map<String, dynamic>.from(json['persona'] as Map),
            )
          : null,
    );
  }

  String get nombreCompleto {
    return persona?.nombreCompleto ?? username;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class IncidenciaPersonaData {
  final int id;
  final String nombres;
  final String apellidos;
  final String? fotoPerfil;

  const IncidenciaPersonaData({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.fotoPerfil,
  });

  factory IncidenciaPersonaData.fromJson(Map<String, dynamic> json) {
    return IncidenciaPersonaData(
      id: _parseInt(json['id']),
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      fotoPerfil: json['foto_perfil']?.toString(),
    );
  }

  String get nombreCompleto {
    return '$nombres $apellidos'.trim();
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class IncidenciaZonaData {
  final int id;
  final String nombre;

  const IncidenciaZonaData({required this.id, required this.nombre});

  factory IncidenciaZonaData.fromJson(Map<String, dynamic> json) {
    return IncidenciaZonaData(
      id: _parseInt(json['id']),
      nombre: json['nombre']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
