import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

class LocationMapper {
  const LocationMapper._();

  static Map<String, dynamic> toApiJson(LocationEntity location) {
    return {
      'latitud': location.latitud,
      'longitud': location.longitud,
      'velocidad': location.velocidad,
      'precision': location.precision,
      'tipo': location.tipo,
      'fecha_hora': location.fechaHora.toIso8601String(),
    };
  }

  static Map<String, dynamic> toSocketJson(
    LocationEntity location, {
    required int? patrullajeId,
  }) {
    return {
      'lat': location.latitud,
      'lng': location.longitud,
      'velocidad': location.velocidad,
      'precision': location.precision,
      'tipo': location.tipo,
      'timestamp': location.fechaHora.toIso8601String(),
      'patrullaje_id': patrullajeId,
    };
  }
}
