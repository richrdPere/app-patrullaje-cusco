import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

class IncidenciaPendienteModel extends Equatable {
  final int? id;
  final String uuidLocal;

  final int usuarioId;
  final int? patrullajeId;
  final int? zonaId;

  final String tipo;
  final String descripcion;

  final double latitud;
  final double longitud;

  final DateTime fechaHora;
  final String origen;

  final String estadoLocal;
  final String estadoSync;

  final int? incidenciaServidorId;

  final int intentos;
  final String? ultimoError;

  final DateTime fechaCreacionLocal;
  final DateTime? fechaUltimoIntento;

  const IncidenciaPendienteModel({
    this.id,
    required this.uuidLocal,
    required this.usuarioId,
    this.patrullajeId,
    this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    this.origen = 'APP_MOVIL',
    this.estadoLocal = 'PENDIENTE',
    this.estadoSync = 'PENDIENTE',
    this.incidenciaServidorId,
    this.intentos = 0,
    this.ultimoError,
    required this.fechaCreacionLocal,
    this.fechaUltimoIntento,
  });

  factory IncidenciaPendienteModel.fromMap(Map<String, dynamic> map) {
    return IncidenciaPendienteModel(
      id: _toInt(map['ipe_id']),
      uuidLocal: map['ipe_uuid_local']?.toString() ?? '',
      usuarioId: _toInt(map['ipe_usuario_id']) ?? 0,
      patrullajeId: _toInt(map['ipe_patrullaje_id']),
      zonaId: _toInt(map['ipe_zona_id']),
      tipo: map['ipe_tipo']?.toString() ?? 'OTRO',
      descripcion: map['ipe_descripcion']?.toString() ?? '',
      latitud: _toDouble(map['ipe_latitud']) ?? 0,
      longitud: _toDouble(map['ipe_longitud']) ?? 0,
      fechaHora: _toDateTime(map['ipe_fecha_hora']) ?? DateTime.now().toUtc(),
      origen: map['ipe_origen']?.toString() ?? 'APP_MOVIL',
      estadoLocal: map['ipe_estado_local']?.toString() ?? 'PENDIENTE',
      estadoSync: map['ipe_estado_sync']?.toString() ?? 'PENDIENTE',
      incidenciaServidorId: _toInt(map['ipe_incidencia_servidor_id']),
      intentos: _toInt(map['ipe_intentos']) ?? 0,
      ultimoError: map['ipe_ultimo_error']?.toString(),
      fechaCreacionLocal:
          _toDateTime(map['ipe_fecha_creacion_local']) ??
          DateTime.now().toUtc(),
      fechaUltimoIntento: _toDateTime(map['ipe_fecha_ultimo_intento']),
    );
  }

  /// Construye el modelo local tomando como base el modelo
  /// utilizado actualmente para registrar una incidencia.
  factory IncidenciaPendienteModel.fromIncidente({
    required IncidenteModel incidente,
    required String uuidLocal,
    required int usuarioId,
    int? zonaId,
    DateTime? fechaCreacionLocal,
  }) {
    final ahora = DateTime.now().toUtc();

    return IncidenciaPendienteModel(
      uuidLocal: uuidLocal,
      usuarioId: usuarioId,
      patrullajeId: incidente.patrullajeId,
      zonaId: zonaId,
      tipo: incidente.tipo,
      descripcion: incidente.descripcion,
      latitud: incidente.latitud,
      longitud: incidente.longitud,
      fechaHora: incidente.fechaHora?.toUtc() ?? ahora,
      origen: incidente.origen,
      estadoLocal: 'PENDIENTE',
      estadoSync: 'PENDIENTE',
      intentos: 0,
      fechaCreacionLocal: fechaCreacionLocal?.toUtc() ?? ahora,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'ipe_uuid_local': uuidLocal,
      'ipe_usuario_id': usuarioId,
      'ipe_patrullaje_id': patrullajeId,
      'ipe_zona_id': zonaId,
      'ipe_tipo': tipo,
      'ipe_descripcion': descripcion,
      'ipe_latitud': latitud,
      'ipe_longitud': longitud,
      'ipe_fecha_hora': fechaHora.toUtc().toIso8601String(),
      'ipe_origen': origen,
      'ipe_estado_local': estadoLocal,
      'ipe_estado_sync': estadoSync,
      'ipe_incidencia_servidor_id': incidenciaServidorId,
      'ipe_intentos': intentos,
      'ipe_ultimo_error': ultimoError,
      'ipe_fecha_creacion_local': fechaCreacionLocal.toUtc().toIso8601String(),
      'ipe_fecha_ultimo_intento': fechaUltimoIntento?.toUtc().toIso8601String(),
    };

    if (includeId && id != null) {
      map['ipe_id'] = id;
    }

    return map;
  }

  /// Convierte nuevamente la incidencia local al modelo
  /// que utiliza actualmente el repositorio remoto.
  IncidenteModel toIncidenteModel() {
    return IncidenteModel(
      id: incidenciaServidorId,
      patrullajeId: patrullajeId,
      tipo: tipo,
      descripcion: descripcion,
      latitud: latitud,
      longitud: longitud,
      fechaHora: fechaHora,
      estado: estadoLocal,
      origen: origen,
      archivos: const [],
      evidencias: const [],
    );
  }

  /// Datos serializables para sincronización con el backend.
  Map<String, dynamic> toSyncJson() {
    return {
      'uuid_local': uuidLocal,
      'usuario_id': usuarioId,
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_hora': fechaHora.toUtc().toIso8601String(),
      'origen': origen,
      'registrada_offline': true,
    };
  }

  IncidenciaPendienteModel copyWith({
    int? id,
    String? uuidLocal,
    int? usuarioId,
    int? patrullajeId,
    int? zonaId,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    DateTime? fechaHora,
    String? origen,
    String? estadoLocal,
    String? estadoSync,
    int? incidenciaServidorId,
    int? intentos,
    String? ultimoError,
    DateTime? fechaCreacionLocal,
    DateTime? fechaUltimoIntento,
    bool clearPatrullajeId = false,
    bool clearZonaId = false,
    bool clearIncidenciaServidorId = false,
    bool clearUltimoError = false,
    bool clearFechaUltimoIntento = false,
  }) {
    return IncidenciaPendienteModel(
      id: id ?? this.id,
      uuidLocal: uuidLocal ?? this.uuidLocal,
      usuarioId: usuarioId ?? this.usuarioId,
      patrullajeId: clearPatrullajeId
          ? null
          : patrullajeId ?? this.patrullajeId,
      zonaId: clearZonaId ? null : zonaId ?? this.zonaId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaHora: fechaHora ?? this.fechaHora,
      origen: origen ?? this.origen,
      estadoLocal: estadoLocal ?? this.estadoLocal,
      estadoSync: estadoSync ?? this.estadoSync,
      incidenciaServidorId: clearIncidenciaServidorId
          ? null
          : incidenciaServidorId ?? this.incidenciaServidorId,
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
    usuarioId,
    patrullajeId,
    zonaId,
    tipo,
    descripcion,
    latitud,
    longitud,
    fechaHora,
    origen,
    estadoLocal,
    estadoSync,
    incidenciaServidorId,
    intentos,
    ultimoError,
    fechaCreacionLocal,
    fechaUltimoIntento,
  ];
}
