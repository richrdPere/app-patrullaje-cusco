import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

class PatrullajeModel extends PatrullajeEntity {
  PatrullajeModel({
    required super.id,
    required super.fecha,
    required super.horaInicio,
    required super.horaFin,
    required super.estado,
    required super.zona,
    required super.unidad,
  });

  factory PatrullajeModel.fromJson(Map<String, dynamic> json) {
    return PatrullajeModel(
      id: json['id'] ?? 0,
      fecha: json['fecha'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      estado: json['estado'] ?? '',

      zona: Zona(
        nombre: json['zona']?['nombre'] ?? '',
        descripcion: json['zona']?['descripcion'] ?? '',
        riesgo: json['zona']?['riesgo'] ?? '',

        coordenadas: (json['zona']?['coordenadas'] as List? ?? [])
            .map(
              (c) => Coordenada(
                lat: (c['lat'] ?? 0).toDouble(),
                lng: (c['lng'] ?? 0).toDouble(),
              ),
            )
            .toList(),
      ),

      unidad: Unidad(
        codigo: json['unidad']?['codigo'] ?? '',
        tipo: json['unidad']?['tipo'] ?? '',
        placa: json['unidad']?['placa'] ?? '',
      ),
    );
  }
}
