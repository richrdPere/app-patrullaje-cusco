import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_data.dart';

class HistorialDetalleData {
  final int id;
  final int patrullajeId;

  final HistorialTipo tipo;
  final String titulo;
  final String descripcion;
  final HistorialPrioridad prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;
  final DateTime fechaHora;
  final HistorialEstado estado;

  final HistorialSerenoData? sereno;
  final HistorialZonaData? zona;

  const HistorialDetalleData({
    required this.id,
    required this.patrullajeId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    required this.fechaHora,
    required this.estado,
    this.sereno,
    this.zona,
  });

  factory HistorialDetalleData.fromJson(Map<String, dynamic> json) {
    final serenoJson = _parseNonEmptyMap(json['sereno']);

    final zonaJson = _parseNonEmptyMap(json['zona']);

    return HistorialDetalleData(
      id: _parseInt(json['id']),

      patrullajeId: _parseInt(json['patrullaje_id']),

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

      estado: HistorialEstado.fromValue(json['estado']?.toString()),

      /*
       * El backend actualmente devuelve "sereno": {}.
       * Un mapa vacío se interpreta como null.
       */
      sereno: serenoJson == null
          ? null
          : HistorialSerenoData.fromJson(serenoJson),

      zona: zonaJson == null ? null : HistorialZonaData.fromJson(zonaJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrullaje_id': patrullajeId,
      'tipo': tipo.value,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
      'fecha_hora': fechaHora.toIso8601String(),
      'estado': estado.value,
      'sereno': sereno?.toJson(),
      'zona': zona?.toJson(),
    };
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get tieneSereno {
    return sereno != null;
  }

  bool get tieneZona {
    return zona != null;
  }

  bool get esVisibleParaSiguienteTurno {
    return visibleParaSiguienteTurno;
  }

  bool get esPrioridadImportante {
    return prioridad == HistorialPrioridad.alta ||
        prioridad == HistorialPrioridad.critica;
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

  static Map<String, dynamic>? _parseNonEmptyMap(dynamic value) {
    Map<String, dynamic>? parsed;

    if (value is Map<String, dynamic>) {
      parsed = value;
    } else if (value is Map) {
      parsed = Map<String, dynamic>.from(value);
    }

    if (parsed == null || parsed.isEmpty) {
      return null;
    }

    return parsed;
  }
}
