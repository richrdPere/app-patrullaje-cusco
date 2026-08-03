import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double latitud;
  final double longitud;
  final double? velocidad;
  final double? precision;
  final DateTime fechaHora;

  /// Valores esperados:
  /// TRACKING, EMERGENCIA, MANUAL
  final String tipo;

  const LocationEntity({
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    this.velocidad,
    this.precision,
    this.tipo = 'TRACKING',
  });

  LocationEntity copyWith({
    double? latitud,
    double? longitud,
    double? velocidad,
    double? precision,
    DateTime? fechaHora,
    String? tipo,
  }) {
    return LocationEntity(
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      velocidad: velocidad ?? this.velocidad,
      precision: precision ?? this.precision,
      fechaHora: fechaHora ?? this.fechaHora,
      tipo: tipo ?? this.tipo,
    );
  }

  bool get hasValidCoordinates {
    return latitud >= -90 &&
        latitud <= 90 &&
        longitud >= -180 &&
        longitud <= 180;
  }

  @override
  List<Object?> get props => [
    latitud,
    longitud,
    velocidad,
    precision,
    fechaHora,
    tipo,
  ];
}
