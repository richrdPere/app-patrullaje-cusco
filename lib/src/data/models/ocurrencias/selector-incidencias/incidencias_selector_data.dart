import 'package:equatable/equatable.dart';

class IncidenciaSelectorData extends Equatable {
  final int id;
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

  const IncidenciaSelectorData({
    required this.id,
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
  });

  factory IncidenciaSelectorData.fromJson(Map<String, dynamic> json) {
    return IncidenciaSelectorData(
      id: _parseRequiredInt(json['id'], fieldName: 'id'),
      patrullajeId: _parseNullableInt(json['patrullaje_id']),
      zonaId: _parseRequiredInt(json['zona_id'], fieldName: 'zona_id'),
      tipo: json['tipo']?.toString() ?? 'OTRO',
      descripcion: json['descripcion']?.toString() ?? '',
      latitud: _parseRequiredDouble(json['latitud'], fieldName: 'latitud'),
      longitud: _parseRequiredDouble(json['longitud'], fieldName: 'longitud'),
      fechaHora: _parseRequiredDateTime(
        json['fecha_hora'],
        fieldName: 'fecha_hora',
      ),
      estado: json['estado']?.toString() ?? 'REPORTADO',
      totalEvidencias: _parseNullableInt(json['total_evidencias']) ?? 0,
      origen: json['origen']?.toString() ?? 'APP_MOVIL',
      createdAt: _parseRequiredDateTime(
        json['createdAt'] ?? json['created_at'],
        fieldName: 'createdAt',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patrullaje_id': patrullajeId,
      'zona_id': zonaId,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'fecha_hora': fechaHora.toIso8601String(),
      'estado': estado,
      'total_evidencias': totalEvidencias,
      'origen': origen,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IncidenciaSelectorData copyWith({
    int? id,
    int? patrullajeId,
    int? zonaId,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    DateTime? fechaHora,
    String? estado,
    int? totalEvidencias,
    String? origen,
    DateTime? createdAt,
    bool clearPatrullajeId = false,
  }) {
    return IncidenciaSelectorData(
      id: id ?? this.id,
      patrullajeId: clearPatrullajeId
          ? null
          : patrullajeId ?? this.patrullajeId,
      zonaId: zonaId ?? this.zonaId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaHora: fechaHora ?? this.fechaHora,
      estado: estado ?? this.estado,
      totalEvidencias: totalEvidencias ?? this.totalEvidencias,
      origen: origen ?? this.origen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _parseRequiredInt(dynamic value, {required String fieldName}) {
    final parsed = _parseNullableInt(value);

    if (parsed == null) {
      throw FormatException(
        'El campo $fieldName no contiene un entero válido.',
      );
    }

    return parsed;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static double _parseRequiredDouble(
    dynamic value, {
    required String fieldName,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw FormatException(
        'El campo $fieldName no contiene un decimal válido.',
      );
    }

    return parsed;
  }

  static DateTime _parseRequiredDateTime(
    dynamic value, {
    required String fieldName,
  }) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');

    if (parsed == null) {
      throw FormatException(
        'El campo $fieldName no contiene una fecha válida.',
      );
    }

    return parsed;
  }

  @override
  List<Object?> get props => [
    id,
    patrullajeId,
    zonaId,
    tipo,
    descripcion,
    latitud,
    longitud,
    fechaHora,
    estado,
    totalEvidencias,
    origen,
    createdAt,
  ];
}
