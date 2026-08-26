import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_data.dart';

class UltimaAlertaDetalleData {
  final int id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String prioridad;

  final double? latitud;
  final double? longitud;

  final bool requiereConfirmacion;
  final DateTime? fechaExpiracion;

  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final AlertaEmisorData? emisor;

  /*
   * Se mantiene como Map hasta conocer la estructura exacta
   * que devuelve la relación zona cuando no es null.
   */
  final Map<String, dynamic>? zona;

  const UltimaAlertaDetalleData({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.prioridad,
    this.latitud,
    this.longitud,
    required this.requiereConfirmacion,
    this.fechaExpiracion,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.emisor,
    this.zona,
  });

  factory UltimaAlertaDetalleData.fromJson(Map<String, dynamic> json) {
    return UltimaAlertaDetalleData(
      id: _parseInt(json['id']),
      titulo: json['titulo']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      prioridad: json['prioridad']?.toString().trim() ?? '',
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      requiereConfirmacion: _parseBool(json['requiere_confirmacion']),
      fechaExpiracion: _parseDateTime(json['fecha_expiracion']),
      estado: json['estado']?.toString().trim() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      emisor: json['emisor'] is Map
          ? AlertaEmisorData.fromJson(
              Map<String, dynamic>.from(json['emisor'] as Map),
            )
          : null,
      zona: json['zona'] is Map
          ? Map<String, dynamic>.from(json['zona'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'prioridad': prioridad,
      'latitud': latitud,
      'longitud': longitud,
      'requiere_confirmacion': requiereConfirmacion,
      'fecha_expiracion': fechaExpiracion?.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emisor': emisor?.toJson(),
      'zona': zona,
    };
  }

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }

  static DateTime? _parseDateTime(dynamic value) {
    final rawValue = value?.toString().trim();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}
