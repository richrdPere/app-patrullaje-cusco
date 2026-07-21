class PatrullajeResumenData {
  final int id;
  final int patrullajeId;
  final int duracionSegundos;
  final double distanciaTotalMetros;
  final int totalPuntosRecorrido;
  final int totalIncidencias;
  final int totalObservaciones;
  final String? observacionFinal;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const PatrullajeResumenData({
    required this.id,
    required this.patrullajeId,
    required this.duracionSegundos,
    required this.distanciaTotalMetros,
    required this.totalPuntosRecorrido,
    required this.totalIncidencias,
    required this.totalObservaciones,
    this.observacionFinal,
    this.fechaInicio,
    this.fechaFin,
  });

  factory PatrullajeResumenData.fromJson(Map<String, dynamic> json) {
    return PatrullajeResumenData(
      id: _parseInt(json['id']),
      patrullajeId: _parseInt(json['patrullaje_id']),
      duracionSegundos: _parseInt(json['duracion_segundos']),
      distanciaTotalMetros: _parseDouble(json['distancia_total_metros']),
      totalPuntosRecorrido: _parseInt(json['total_puntos_recorrido']),
      totalIncidencias: _parseInt(json['total_incidencias']),
      totalObservaciones: _parseInt(json['total_observaciones']),
      observacionFinal: json['observacion_final']?.toString(),
      fechaInicio: _parseDateTime(json['fecha_inicio']),
      fechaFin: _parseDateTime(json['fecha_fin']),
    );
  }

  double get distanciaKilometros {
    return distanciaTotalMetros / 1000;
  }

  Duration get duracion {
    return Duration(seconds: duracionSegundos);
  }

  String get duracionFormateada {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60);

    if (horas == 0) {
      return '$minutos min';
    }

    return '${horas}h ${minutos}min';
  }

  String get distanciaFormateada {
    if (distanciaTotalMetros < 1000) {
      return '${distanciaTotalMetros.toStringAsFixed(0)} m';
    }

    return '${distanciaKilometros.toStringAsFixed(2)} km';
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
