import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

class HistorialPatrullajeData {
  final int id;

  final HistorialTipo tipo;
  final String titulo;
  final String descripcion;
  final HistorialPrioridad prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;
  final DateTime fechaHora;

  final HistorialSerenoData? sereno;
  final HistorialZonaData? zona;

  const HistorialPatrullajeData({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    required this.fechaHora,
    this.sereno,
    this.zona,
  });

  factory HistorialPatrullajeData.fromJson(Map<String, dynamic> json) {
    return HistorialPatrullajeData(
      id: _parseInt(json['id']),

      tipo: HistorialTipo.fromValue(json['tipo']?.toString()),

      titulo: json['titulo']?.toString().trim() ?? '',

      descripcion: json['descripcion']?.toString().trim() ?? '',

      prioridad: HistorialPrioridad.fromValue(json['prioridad']?.toString()),

      latitud: _parseNullableDouble(json['latitud']),

      longitud: _parseNullableDouble(json['longitud']),

      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
        defaultValue: true,
      ),

      fechaHora: _parseDateTime(json['fecha_hora']),

      sereno: _parseMap(json['sereno']) == null
          ? null
          : HistorialSerenoData.fromJson(_parseMap(json['sereno'])!),

      zona: _parseMap(json['zona']) == null
          ? null
          : HistorialZonaData.fromJson(_parseMap(json['zona'])!),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.value,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
      'fecha_hora': fechaHora.toIso8601String(),
      'sereno': sereno?.toJson(),
      'zona': zona?.toJson(),
    };
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get esPrioridadAlta {
    return prioridad == HistorialPrioridad.alta ||
        prioridad == HistorialPrioridad.critica;
  }

  bool get esVisibleSiguienteTurno {
    return visibleParaSiguienteTurno;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
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

  static DateTime _parseDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}

class HistorialSerenoData {
  final int id;
  final String nombres;
  final String apellidos;

  const HistorialSerenoData({
    required this.id,
    required this.nombres,
    required this.apellidos,
  });

  factory HistorialSerenoData.fromJson(Map<String, dynamic> json) {
    return HistorialSerenoData(
      id: _parseInt(json['id']),
      nombres: json['nombres']?.toString().trim() ?? '',
      apellidos: json['apellidos']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombres': nombres, 'apellidos': apellidos};
  }

  String get nombreCompleto {
    return [nombres, apellidos].where((value) => value.isNotEmpty).join(' ');
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class HistorialZonaData {
  final int id;
  final String nombre;
  final String? riesgo;

  const HistorialZonaData({
    required this.id,
    required this.nombre,
    this.riesgo,
  });

  factory HistorialZonaData.fromJson(Map<String, dynamic> json) {
    return HistorialZonaData(
      id: _parseInt(json['id']),
      nombre: json['nombre']?.toString().trim() ?? '',
      riesgo: _parseNullableString(json['riesgo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'riesgo': riesgo};
  }

  bool get tieneRiesgo {
    return riesgo != null && riesgo!.isNotEmpty;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _parseNullableString(dynamic value) {
    final parsed = value?.toString().trim();

    if (parsed == null || parsed.isEmpty) {
      return null;
    }

    return parsed;
  }
}
