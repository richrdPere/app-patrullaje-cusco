import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_resumen_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

class PatrullajeData {
  final int id;
  final String estado;
  final DateTime? fecha;
  final String horaInicio;
  final String horaFin;
  final String descripcion;
  final Zona zona;
  final Unidad unidad;
  final PatrullajeResumenData? resumen;

  const PatrullajeData({
    required this.id,
    required this.estado,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.descripcion,
    required this.zona,
    required this.unidad,
    this.resumen,
  });

  factory PatrullajeData.fromJson(Map<String, dynamic> json) {
    final resumenJson = json['resumen'];

    return PatrullajeData(
      id: _toInt(json['id']),
      estado: json['estado']?.toString() ?? '',
      fecha: _toDateTime(json['fecha']),
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      zona: Zona(
        id: _toInt(json['zona']?['id']),
        nombre: json['zona']?['nombre']?.toString() ?? '',
        descripcion: json['zona']?['descripcion']?.toString() ?? '',
        riesgo: json['zona']?['riesgo']?.toString() ?? '',
        coordenadas: (json['zona']?['coordenadas'] as List? ?? [])
            .map(
              (c) => Coordenada(
                lat: _toDouble(c['lat']),
                lng: _toDouble(c['lng']),
              ),
            )
            .toList(),
      ),
      unidad: Unidad(
        id: _toInt(json['unidad']?['id']),
        codigo: json['unidad']?['codigo']?.toString() ?? '',
        tipo: json['unidad']?['tipo']?.toString() ?? '',
        placa: json['unidad']?['placa']?.toString() ?? '',
      ),
      resumen: resumenJson is Map<String, dynamic>
          ? PatrullajeResumenData.fromJson(resumenJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estado': estado,
      'fecha': fecha?.toIso8601String().split('T').first,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'descripcion': descripcion,
      'zona': {
        'id': zona.id,
        'nombre': zona.nombre,
        'descripcion': zona.descripcion,
        'riesgo': zona.riesgo,
        'coordenadas': zona.coordenadas
            .map((c) => {'lat': c.lat, 'lng': c.lng})
            .toList(),
      },
      'unidad': {
        'id': unidad.id,
        'codigo': unidad.codigo,
        'tipo': unidad.tipo,
        'placa': unidad.placa,
      },
    };
  }

  PatrullajeData copyWith({
    int? id,
    String? estado,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    String? descripcion,
    Zona? zona,
    Unidad? unidad,
  }) {
    return PatrullajeData(
      id: id ?? this.id,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      descripcion: descripcion ?? this.descripcion,
      zona: zona ?? this.zona,
      unidad: unidad ?? this.unidad,
    );
  }

  static PatrullajeData empty() {
    return PatrullajeData(
      id: 0,
      estado: '',
      fecha: null,
      horaInicio: '',
      horaFin: '',
      descripcion: '',
      zona: Zona(
        id: 0,
        nombre: '',
        descripcion: '',
        riesgo: '',
        coordenadas: const [],
      ),
      unidad: Unidad(codigo: '', tipo: '', placa: '', id: 0),
    );
  }

  @override
  String toString() {
    return 'PatrullajeData(id: $id, estado: $estado, fecha: $fecha, horaInicio: $horaInicio, horaFin: $horaFin)';
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
