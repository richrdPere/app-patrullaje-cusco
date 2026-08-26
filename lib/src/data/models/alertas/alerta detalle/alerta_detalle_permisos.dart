class AlertaDetallePermisos {
  final bool esEmisor;
  final bool esDestinatario;
  final bool esUsuarioCentral;
  final bool puedeCancelar;
  final bool puedeResponder;

  const AlertaDetallePermisos({
    required this.esEmisor,
    required this.esDestinatario,
    required this.esUsuarioCentral,
    required this.puedeCancelar,
    required this.puedeResponder,
  });

  const AlertaDetallePermisos.empty()
    : esEmisor = false,
      esDestinatario = false,
      esUsuarioCentral = false,
      puedeCancelar = false,
      puedeResponder = false;

  factory AlertaDetallePermisos.fromJson(Map<String, dynamic> json) {
    return AlertaDetallePermisos(
      esEmisor: _parseBool(json['es_emisor']),
      esDestinatario: _parseBool(json['es_destinatario']),
      esUsuarioCentral: _parseBool(json['es_usuario_central']),
      puedeCancelar: _parseBool(json['puede_cancelar']),
      puedeResponder: _parseBool(json['puede_responder']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'es_emisor': esEmisor,
      'es_destinatario': esDestinatario,
      'es_usuario_central': esUsuarioCentral,
      'puede_cancelar': puedeCancelar,
      'puede_responder': puedeResponder,
    };
  }

  bool get tieneAccionesDisponibles {
    return puedeCancelar || puedeResponder;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }
}
