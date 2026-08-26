
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta%20activa/alerta_patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta%20activa/alerta_zona_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta%20detalle/alerta_detalle_permisos.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta%20detalle/alerta_resumen_estado.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_usuario_estado_data.dart';

class AlertaDetalleData {
  final int id;
  final int emisorId;

  final int? patrullajeId;
  final int? zonaId;
  final int? incidenciaId;

  final String titulo;
  final String tipo;
  final String prioridad;
  final String descripcion;

  final double? latitud;
  final double? longitud;

  final bool requiereConfirmacion;
  final DateTime? fechaExpiracion;

  final String estado;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final AlertaEmisorData? emisor;
  final AlertaZonaData? zona;
  final AlertaPatrullajeData? patrullaje;

  /*
   * Se mantiene como Map hasta conocer el JSON completo
   * de la relación incidencia.
   */
  final Map<String, dynamic>? incidencia;

  final List<AlertaUsuarioEstadoData> destinatarios;

  /*
   * Es nullable porque un usuario puede ser emisor o usuario
   * central sin encontrarse entre los destinatarios.
   */
  final AlertaUsuarioEstadoData? recepcionUsuario;

  final AlertaDetallePermisos permisos;
  final AlertaResumenEstado resumenEstado;

  const AlertaDetalleData({
    required this.id,
    required this.emisorId,
    this.patrullajeId,
    this.zonaId,
    this.incidenciaId,
    required this.titulo,
    required this.tipo,
    required this.prioridad,
    required this.descripcion,
    this.latitud,
    this.longitud,
    required this.requiereConfirmacion,
    this.fechaExpiracion,
    required this.estado,
    this.createdAt,
    this.updatedAt,
    this.emisor,
    this.zona,
    this.patrullaje,
    this.incidencia,
    this.destinatarios = const [],
    this.recepcionUsuario,
    required this.permisos,
    required this.resumenEstado,
  });

  factory AlertaDetalleData.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawDestinatarios = json['destinatarios'];

    return AlertaDetalleData(
      id: _parseInt(json['id']),
      emisorId: _parseInt(json['emisor_id']),
      patrullajeId: _parseNullableInt(
        json['patrullaje_id'],
      ),
      zonaId: _parseNullableInt(json['zona_id']),
      incidenciaId: _parseNullableInt(
        json['incidencia_id'],
      ),
      titulo: json['titulo']?.toString().trim() ?? '',
      tipo: json['tipo']?.toString().trim() ?? '',
      prioridad:
          json['prioridad']?.toString().trim() ?? '',
      descripcion:
          json['descripcion']?.toString().trim() ?? '',
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      requiereConfirmacion: _parseBool(
        json['requiere_confirmacion'],
      ),
      fechaExpiracion: _parseDateTime(
        json['fecha_expiracion'],
      ),
      estado: json['estado']?.toString().trim() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      emisor: json['emisor'] is Map
          ? AlertaEmisorData.fromJson(
              Map<String, dynamic>.from(
                json['emisor'] as Map,
              ),
            )
          : null,
      zona: json['zona'] is Map
          ? AlertaZonaData.fromJson(
              Map<String, dynamic>.from(
                json['zona'] as Map,
              ),
            )
          : null,
      patrullaje: json['patrullaje'] is Map
          ? AlertaPatrullajeData.fromJson(
              Map<String, dynamic>.from(
                json['patrullaje'] as Map,
              ),
            )
          : null,
      incidencia: json['incidencia'] is Map
          ? Map<String, dynamic>.from(
              json['incidencia'] as Map,
            )
          : null,
      destinatarios: rawDestinatarios is List
          ? rawDestinatarios
                .whereType<Map>()
                .map(
                  (item) =>
                      AlertaUsuarioEstadoData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      recepcionUsuario: json['recepcion_usuario'] is Map
          ? AlertaUsuarioEstadoData.fromJson(
              Map<String, dynamic>.from(
                json['recepcion_usuario'] as Map,
              ),
            )
          : null,
      permisos: json['permisos'] is Map
          ? AlertaDetallePermisos.fromJson(
              Map<String, dynamic>.from(
                json['permisos'] as Map,
              ),
            )
          : const AlertaDetallePermisos.empty(),
      resumenEstado: json['resumen_estado'] is Map
          ? AlertaResumenEstado.fromJson(
              Map<String, dynamic>.from(
                json['resumen_estado'] as Map,
              ),
            )
          : const AlertaResumenEstado.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emisor_id': emisorId,
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'incidencia_id': incidenciaId,
      'titulo': titulo,
      'tipo': tipo,
      'prioridad': prioridad,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'requiere_confirmacion': requiereConfirmacion,
      'fecha_expiracion': fechaExpiracion?.toIso8601String(),
      'estado': estado,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emisor': emisor?.toJson(),
      'zona': zona?.toJson(),
      'patrullaje': patrullaje?.toJson(),
      'incidencia': incidencia,
      'destinatarios': destinatarios
          .map((item) => item.toJson())
          .toList(),
      'recepcion_usuario': recepcionUsuario?.toJson(),
      'permisos': permisos.toJson(),
      'resumen_estado': resumenEstado.toJson(),
    };
  }

  // *********************************************************
  // GETTERS
  // *********************************************************

  bool get esPanico => tipo == 'PANICO';

  bool get esCritica => prioridad == 'CRITICA';

  bool get tieneUbicacion {
    return latitud != null && longitud != null;
  }

  bool get tieneDestinatarios {
    return destinatarios.isNotEmpty;
  }

  bool get usuarioYaRecibio {
    return recepcionUsuario?.fechaRecibida != null;
  }

  bool get usuarioYaLeyo {
    return recepcionUsuario?.fechaLeida != null;
  }

  bool get usuarioYaRespondio {
    return recepcionUsuario?.fechaRespuesta != null;
  }

  bool get usuarioYaAtendio {
    return recepcionUsuario?.fechaAtendida != null;
  }

  // *********************************************************
  // PARSERS
  // *********************************************************

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value
        ?.toString()
        .trim()
        .toLowerCase();

    return normalizedValue == 'true' ||
        normalizedValue == '1';
  }

  static DateTime? _parseDateTime(dynamic value) {
    final rawValue = value?.toString().trim();

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }
}