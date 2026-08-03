import 'dart:io';
import 'package:equatable/equatable.dart';

class EvidenciaPendienteModel extends Equatable {
  final int? id;
  final String uuidLocal;

  final String incidenciaUuidLocal;

  final String rutaLocal;
  final String? nombreArchivo;

  final String tipoArchivo;
  final String? mimeType;
  final int? tamanio;

  final String estadoSync;
  final String? urlRemota;

  final int intentos;
  final String? ultimoError;

  final DateTime fechaCreacionLocal;

  const EvidenciaPendienteModel({
    this.id,
    required this.uuidLocal,
    required this.incidenciaUuidLocal,
    required this.rutaLocal,
    this.nombreArchivo,
    required this.tipoArchivo,
    this.mimeType,
    this.tamanio,
    this.estadoSync = 'PENDIENTE',
    this.urlRemota,
    this.intentos = 0,
    this.ultimoError,
    required this.fechaCreacionLocal,
  });

  factory EvidenciaPendienteModel.fromMap(Map<String, dynamic> map) {
    return EvidenciaPendienteModel(
      id: _toInt(map['evp_id']),
      uuidLocal: map['evp_uuid_local']?.toString() ?? '',
      incidenciaUuidLocal: map['evp_incidencia_uuid_local']?.toString() ?? '',
      rutaLocal: map['evp_ruta_local']?.toString() ?? '',
      nombreArchivo: map['evp_nombre_archivo']?.toString(),
      tipoArchivo: map['evp_tipo_archivo']?.toString() ?? 'OTRO',
      mimeType: map['evp_mime_type']?.toString(),
      tamanio: _toInt(map['evp_tamanio']),
      estadoSync: map['evp_estado_sync']?.toString() ?? 'PENDIENTE',
      urlRemota: map['evp_url_remota']?.toString(),
      intentos: _toInt(map['evp_intentos']) ?? 0,
      ultimoError: map['evp_ultimo_error']?.toString(),
      fechaCreacionLocal:
          _toDateTime(map['evp_fecha_creacion_local']) ??
          DateTime.now().toUtc(),
    );
  }

  factory EvidenciaPendienteModel.fromFile({
    required String uuidLocal,
    required String incidenciaUuidLocal,
    required File archivo,
    required String tipoArchivo,
    String? mimeType,
    DateTime? fechaCreacionLocal,
  }) {
    return EvidenciaPendienteModel(
      uuidLocal: uuidLocal,
      incidenciaUuidLocal: incidenciaUuidLocal,
      rutaLocal: archivo.path,
      nombreArchivo: _obtenerNombreArchivo(archivo.path),
      tipoArchivo: tipoArchivo,
      mimeType: mimeType,
      tamanio: archivo.existsSync() ? archivo.lengthSync() : null,
      estadoSync: 'PENDIENTE',
      intentos: 0,
      fechaCreacionLocal: fechaCreacionLocal?.toUtc() ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'evp_uuid_local': uuidLocal,
      'evp_incidencia_uuid_local': incidenciaUuidLocal,
      'evp_ruta_local': rutaLocal,
      'evp_nombre_archivo': nombreArchivo,
      'evp_tipo_archivo': tipoArchivo,
      'evp_mime_type': mimeType,
      'evp_tamanio': tamanio,
      'evp_estado_sync': estadoSync,
      'evp_url_remota': urlRemota,
      'evp_intentos': intentos,
      'evp_ultimo_error': ultimoError,
      'evp_fecha_creacion_local': fechaCreacionLocal.toUtc().toIso8601String(),
    };

    if (includeId && id != null) {
      map['evp_id'] = id;
    }

    return map;
  }

  File get archivo => File(rutaLocal);

  bool get existeArchivo => archivo.existsSync();

  EvidenciaPendienteModel copyWith({
    int? id,
    String? uuidLocal,
    String? incidenciaUuidLocal,
    String? rutaLocal,
    String? nombreArchivo,
    String? tipoArchivo,
    String? mimeType,
    int? tamanio,
    String? estadoSync,
    String? urlRemota,
    int? intentos,
    String? ultimoError,
    DateTime? fechaCreacionLocal,
    bool clearNombreArchivo = false,
    bool clearMimeType = false,
    bool clearTamanio = false,
    bool clearUrlRemota = false,
    bool clearUltimoError = false,
  }) {
    return EvidenciaPendienteModel(
      id: id ?? this.id,
      uuidLocal: uuidLocal ?? this.uuidLocal,
      incidenciaUuidLocal: incidenciaUuidLocal ?? this.incidenciaUuidLocal,
      rutaLocal: rutaLocal ?? this.rutaLocal,
      nombreArchivo: clearNombreArchivo
          ? null
          : nombreArchivo ?? this.nombreArchivo,
      tipoArchivo: tipoArchivo ?? this.tipoArchivo,
      mimeType: clearMimeType ? null : mimeType ?? this.mimeType,
      tamanio: clearTamanio ? null : tamanio ?? this.tamanio,
      estadoSync: estadoSync ?? this.estadoSync,
      urlRemota: clearUrlRemota ? null : urlRemota ?? this.urlRemota,
      intentos: intentos ?? this.intentos,
      ultimoError: clearUltimoError ? null : ultimoError ?? this.ultimoError,
      fechaCreacionLocal: fechaCreacionLocal ?? this.fechaCreacionLocal,
    );
  }

  static String _obtenerNombreArchivo(String ruta) {
    final segmentos = ruta.replaceAll('\\', '/').split('/');

    return segmentos.isNotEmpty ? segmentos.last : ruta;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    uuidLocal,
    incidenciaUuidLocal,
    rutaLocal,
    nombreArchivo,
    tipoArchivo,
    mimeType,
    tamanio,
    estadoSync,
    urlRemota,
    intentos,
    ultimoError,
    fechaCreacionLocal,
  ];
}
