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

Map<String, dynamic> locationToSocketJson(
  LocationEntity location,
  int? patrullajeId,
) {
  return {
    "lat": location.latitud,
    "lng": location.longitud,
    "velocidad": location.velocidad,
    "precision": location.precision,
    "tipo": location.tipo,
    "timestamp": location.fechaHora.toIso8601String(),
    "patrullaje_id": patrullajeId,
  };
}