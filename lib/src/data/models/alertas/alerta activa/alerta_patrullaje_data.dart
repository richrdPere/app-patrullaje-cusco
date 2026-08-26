class AlertaPatrullajeData {
  final int id;
  final int unidadId;
  final int zonaId;

  /*
   * Se mantienen como String porque fecha es DATEONLY y
   * las horas no contienen información de zona horaria.
   */
  final String fecha;
  final String horaInicio;
  final String horaFin;

  final String estado;
  final String? descripcion;

  const AlertaPatrullajeData({
    required this.id,
    required this.unidadId,
    required this.zonaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.descripcion,
  });

  factory AlertaPatrullajeData.fromJson(Map<String, dynamic> json) {
    return AlertaPatrullajeData(
      id: _parseInt(json['id']),
      unidadId: _parseInt(json['unidad_id']),
      zonaId: _parseInt(json['zona_id']),
      fecha: json['fecha']?.toString().trim() ?? '',
      horaInicio: json['hora_inicio']?.toString().trim() ?? '',
      horaFin: json['hora_fin']?.toString().trim() ?? '',
      estado: json['estado']?.toString().trim() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidad_id': unidadId,
      'zona_id': zonaId,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'descripcion': descripcion,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _parseNullableString(dynamic value) {
    final parsedValue = value?.toString().trim();

    if (parsedValue == null || parsedValue.isEmpty) {
      return null;
    }

    return parsedValue;
  }
}
