class AlertaResumenEstado {
  final bool estaActiva;
  final bool estaCancelada;
  final bool estaFinalizada;

  const AlertaResumenEstado({
    required this.estaActiva,
    required this.estaCancelada,
    required this.estaFinalizada,
  });

  const AlertaResumenEstado.empty()
    : estaActiva = false,
      estaCancelada = false,
      estaFinalizada = false;

  factory AlertaResumenEstado.fromJson(Map<String, dynamic> json) {
    return AlertaResumenEstado(
      estaActiva: _parseBool(json['esta_activa']),
      estaCancelada: _parseBool(json['esta_cancelada']),
      estaFinalizada: _parseBool(json['esta_finalizada']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esta_activa': estaActiva,
      'esta_cancelada': estaCancelada,
      'esta_finalizada': estaFinalizada,
    };
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalizedValue = value?.toString().trim().toLowerCase();

    return normalizedValue == 'true' || normalizedValue == '1';
  }
}
