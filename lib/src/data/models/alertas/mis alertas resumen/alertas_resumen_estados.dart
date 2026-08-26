class AlertasResumenEstados {
  final int pendientes;
  final int recibidas;
  final int leidas;
  final int aceptadas;
  final int rechazadas;
  final int atendidas;

  const AlertasResumenEstados({
    required this.pendientes,
    required this.recibidas,
    required this.leidas,
    required this.aceptadas,
    required this.rechazadas,
    required this.atendidas,
  });

  const AlertasResumenEstados.empty()
    : pendientes = 0,
      recibidas = 0,
      leidas = 0,
      aceptadas = 0,
      rechazadas = 0,
      atendidas = 0;

  factory AlertasResumenEstados.fromJson(Map<String, dynamic> json) {
    return AlertasResumenEstados(
      pendientes: _parseInt(json['pendientes']),
      recibidas: _parseInt(json['recibidas']),
      leidas: _parseInt(json['leidas']),
      aceptadas: _parseInt(json['aceptadas']),
      rechazadas: _parseInt(json['rechazadas']),
      atendidas: _parseInt(json['atendidas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendientes': pendientes,
      'recibidas': recibidas,
      'leidas': leidas,
      'aceptadas': aceptadas,
      'rechazadas': rechazadas,
      'atendidas': atendidas,
    };
  }

  int get total {
    return pendientes + recibidas + leidas + aceptadas + rechazadas + atendidas;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
