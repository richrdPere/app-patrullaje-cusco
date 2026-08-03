import 'package:equatable/equatable.dart';

class UbicacionPendienteModel extends Equatable {
  final int? id;
  final String uuidLocal;

  final int patrullajeId;
  final int? usuarioId;

  final double latitud;
  final double longitud;
  final double? velocidad;
  final double? precision;

  final String tipo;
  final DateTime fechaHora;

  final String estadoSync;
  final int intentos;
  final String? ultimoError;

  final DateTime fechaCreacionLocal;
  final DateTime? fechaUltimoIntento;

  const UbicacionPendienteModel({
    this.id,
    required this.uuidLocal,
    required this.patrullajeId,
    this.usuarioId,
    required this.latitud,
    required this.longitud,
    this.velocidad,
    this.precision,
    this.tipo = 'TRACKING',
    required this.fechaHora,
    this.estadoSync = 'PENDIENTE',
    this.intentos = 0,
    this.ultimoError,
    required this.fechaCreacionLocal,
    this.fechaUltimoIntento,
  });

  factory UbicacionPendienteModel.fromMap(Map<String, dynamic> map) {
    return UbicacionPendienteModel(
      id: _toInt(map['ubc_id']),
      uuidLocal: map['ubc_uuid_local']?.toString() ?? '',
      patrullajeId: _toInt(map['ubc_patrullaje_id']) ?? 0,
      usuarioId: _toInt(map['ubc_usuario_id']),
      latitud: _toDouble(map['ubc_latitud']) ?? 0,
      longitud: _toDouble(map['ubc_longitud']) ?? 0,
      velocidad: _toDouble(map['ubc_velocidad']),
      precision: _toDouble(map['ubc_precision']),
      tipo: map['ubc_tipo']?.toString() ?? 'TRACKING',
      fechaHora: _toDateTime(map['ubc_fecha_hora']) ?? DateTime.now().toUtc(),
      estadoSync: map['ubc_estado_sync']?.toString() ?? 'PENDIENTE',
      intentos: _toInt(map['ubc_intentos']) ?? 0,
      ultimoError: map['ubc_ultimo_error']?.toString(),
      fechaCreacionLocal:
          _toDateTime(map['ubc_fecha_creacion_local']) ??
          DateTime.now().toUtc(),
      fechaUltimoIntento: _toDateTime(map['ubc_fecha_ultimo_intento']),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'ubc_uuid_local': uuidLocal,
      'ubc_patrullaje_id': patrullajeId,
      'ubc_usuario_id': usuarioId,
      'ubc_latitud': latitud,
      'ubc_longitud': longitud,
      'ubc_velocidad': velocidad,
      'ubc_precision': precision,
      'ubc_tipo': tipo,
      'ubc_fecha_hora': fechaHora.toUtc().toIso8601String(),
      'ubc_estado_sync': estadoSync,
      'ubc_intentos': intentos,
      'ubc_ultimo_error': ultimoError,
      'ubc_fecha_creacion_local': fechaCreacionLocal.toUtc().toIso8601String(),
      'ubc_fecha_ultimo_intento': fechaUltimoIntento?.toUtc().toIso8601String(),
    };

    if (includeId && id != null) {
      map['ubc_id'] = id;
    }

    return map;
  }

  /// Datos que posteriormente se enviarán al backend.
  Map<String, dynamic> toSyncJson() {
    return {
      'uuid_local': uuidLocal,
      'patrullaje_id': patrullajeId,
      'usuario_id': usuarioId,
      'latitud': latitud,
      'longitud': longitud,
      'velocidad': velocidad,
      'precision': precision,
      'tipo': tipo,
      'fecha_hora': fechaHora.toUtc().toIso8601String(),
    };
  }

  UbicacionPendienteModel copyWith({
    int? id,
    String? uuidLocal,
    int? patrullajeId,
    int? usuarioId,
    double? latitud,
    double? longitud,
    double? velocidad,
    double? precision,
    String? tipo,
    DateTime? fechaHora,
    String? estadoSync,
    int? intentos,
    String? ultimoError,
    DateTime? fechaCreacionLocal,
    DateTime? fechaUltimoIntento,
    bool clearUsuarioId = false,
    bool clearVelocidad = false,
    bool clearPrecision = false,
    bool clearUltimoError = false,
    bool clearFechaUltimoIntento = false,
  }) {
    return UbicacionPendienteModel(
      id: id ?? this.id,
      uuidLocal: uuidLocal ?? this.uuidLocal,
      patrullajeId: patrullajeId ?? this.patrullajeId,
      usuarioId: clearUsuarioId ? null : usuarioId ?? this.usuarioId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      velocidad: clearVelocidad ? null : velocidad ?? this.velocidad,
      precision: clearPrecision ? null : precision ?? this.precision,
      tipo: tipo ?? this.tipo,
      fechaHora: fechaHora ?? this.fechaHora,
      estadoSync: estadoSync ?? this.estadoSync,
      intentos: intentos ?? this.intentos,
      ultimoError: clearUltimoError ? null : ultimoError ?? this.ultimoError,
      fechaCreacionLocal: fechaCreacionLocal ?? this.fechaCreacionLocal,
      fechaUltimoIntento: clearFechaUltimoIntento
          ? null
          : fechaUltimoIntento ?? this.fechaUltimoIntento,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    uuidLocal,
    patrullajeId,
    usuarioId,
    latitud,
    longitud,
    velocidad,
    precision,
    tipo,
    fechaHora,
    estadoSync,
    intentos,
    ultimoError,
    fechaCreacionLocal,
    fechaUltimoIntento,
  ];
}
