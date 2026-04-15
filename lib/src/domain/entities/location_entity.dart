class LocationEntity {
  final double latitud;
  final double longitud;
  final double? velocidad;
  final double? precision;
  final DateTime fechaHora;
  final String tipo; // TRACKING, EMERGENCIA, MANUAL

  LocationEntity({
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    this.velocidad,
    this.precision,
    this.tipo = 'TRACKING',
  });
}

Map<String, dynamic> locationToJson(LocationEntity location) {
  return {
    "latitud": location.latitud,
    "longitud": location.longitud,
    "velocidad": location.velocidad,
    "precision": location.precision,
    "tipo": location.tipo,
  };
}
