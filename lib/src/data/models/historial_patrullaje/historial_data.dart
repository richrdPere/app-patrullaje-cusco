import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_archivo_data.dart';

class HistorialData {
  final int id;

  final int patrullajeId;
  final int usuarioId;
  final int zonaId;
  final int? incidenciaId;

  final HistorialTipo tipo;
  final String titulo;
  final String descripcion;
  final HistorialPrioridad prioridad;
  final HistorialOrigen origen;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;

  final DateTime fechaHora;
  final HistorialEstado estado;

  final List<HistorialArchivoData> archivos;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistorialData({
    required this.id,
    required this.patrullajeId,
    required this.usuarioId,
    required this.zonaId,
    this.incidenciaId,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.origen,
    this.latitud,
    this.longitud,
    required this.visibleParaSiguienteTurno,
    required this.fechaHora,
    required this.estado,
    this.archivos = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory HistorialData.fromJson(Map<String, dynamic> json) {
    return HistorialData(
      id: _parseInt(json['id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      usuarioId: _parseInt(json['usuario_id']),
      zonaId: _parseInt(json['zona_id']),
      incidenciaId: _parseNullableInt(json['incidencia_id']),
      tipo: HistorialTipo.fromValue(json['tipo']?.toString()),
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      prioridad: HistorialPrioridad.fromValue(json['prioridad']?.toString()),
      origen: HistorialOrigen.fromValue(json['origen']?.toString()),
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      visibleParaSiguienteTurno: _parseBool(
        json['visible_para_siguiente_turno'],
        defaultValue: true,
      ),
      archivos: _parseArchivos(json['archivos']),
      fechaHora: _parseDateTime(json['fecha_hora']),
      estado: HistorialEstado.fromValue(json['estado']?.toString()),
      createdAt: _parseNullableDateTime(json['createdAt']),
      updatedAt: _parseNullableDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrullaje_id': patrullajeId,
      'usuario_id': usuarioId,
      'zona_id': zonaId,
      'incidencia_id': incidenciaId,
      'tipo': tipo.value,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'origen': origen.value,
      'latitud': latitud,
      'longitud': longitud,
      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
      'archivos': archivos.map((archivo) => archivo.toJson()).toList(),
      'fecha_hora': fechaHora.toIso8601String(),
      'estado': estado.value,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get estaVinculadoAIncidencia {
    return incidenciaId != null;
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

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static List<HistorialArchivoData> _parseArchivos(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              HistorialArchivoData.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
