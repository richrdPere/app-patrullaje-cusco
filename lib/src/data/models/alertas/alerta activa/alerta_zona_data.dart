class AlertaZonaData {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? riesgo;
  final bool estado;

  const AlertaZonaData({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.riesgo,
    required this.estado,
  });

  factory AlertaZonaData.fromJson(Map<String, dynamic> json) {
    return AlertaZonaData(
      id: _parseInt(json['id']),
      nombre: json['nombre']?.toString().trim() ?? '',
      descripcion: _parseNullableString(json['descripcion']),
      riesgo: _parseNullableString(json['riesgo']),
      estado: _parseBool(json['estado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'riesgo': riesgo,
      'estado': estado,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }

  static String? _parseNullableString(dynamic value) {
    final parsedValue = value?.toString().trim();

    if (parsedValue == null || parsedValue.isEmpty) {
      return null;
    }

    return parsedValue;
  }
}
