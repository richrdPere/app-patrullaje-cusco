class AlertaResumenModel {
  final int total;
  final int pendientes;
  final int recibidas;
  final int leidas;
  final int aceptadas;
  final int rechazadas;
  final int atendidas;

  final int noLeidas;
  final int requierenConfirmacion;
  final int criticas;

  const AlertaResumenModel({
    required this.total,
    required this.pendientes,
    required this.recibidas,
    required this.leidas,
    required this.aceptadas,
    required this.rechazadas,
    required this.atendidas,
    required this.noLeidas,
    required this.requierenConfirmacion,
    required this.criticas,
  });

  factory AlertaResumenModel.fromJson(Map<String, dynamic> json) {
    final data = _extractData(json);

    final pendientes = _parseInt(data['pendientes']);
    final recibidas = _parseInt(data['recibidas']);
    final leidas = _parseInt(data['leidas']);
    final aceptadas = _parseInt(data['aceptadas']);
    final rechazadas = _parseInt(data['rechazadas']);
    final atendidas = _parseInt(data['atendidas']);

    final totalCalculado =
        pendientes + recibidas + leidas + aceptadas + rechazadas + atendidas;

    return AlertaResumenModel(
      total: _parseInt(data['total']) > 0
          ? _parseInt(data['total'])
          : totalCalculado,
      pendientes: pendientes,
      recibidas: recibidas,
      leidas: leidas,
      aceptadas: aceptadas,
      rechazadas: rechazadas,
      atendidas: atendidas,
      noLeidas: _parseInt(
        data['no_leidas'] ?? data['total_no_leidas'] ?? data['sin_leer'],
      ),
      requierenConfirmacion: _parseInt(
        data['requieren_confirmacion'] ?? data['total_requieren_confirmacion'],
      ),
      criticas: _parseInt(data['criticas'] ?? data['total_criticas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pendientes': pendientes,
      'recibidas': recibidas,
      'leidas': leidas,
      'aceptadas': aceptadas,
      'rechazadas': rechazadas,
      'atendidas': atendidas,
      'no_leidas': noLeidas,
      'requieren_confirmacion': requierenConfirmacion,
      'criticas': criticas,
    };
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
