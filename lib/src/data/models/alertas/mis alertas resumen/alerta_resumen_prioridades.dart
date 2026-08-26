class AlertasResumenPrioridades {
  final int bajas;
  final int medias;
  final int altas;
  final int criticas;

  const AlertasResumenPrioridades({
    required this.bajas,
    required this.medias,
    required this.altas,
    required this.criticas,
  });

  const AlertasResumenPrioridades.empty()
    : bajas = 0,
      medias = 0,
      altas = 0,
      criticas = 0;

  factory AlertasResumenPrioridades.fromJson(Map<String, dynamic> json) {
    return AlertasResumenPrioridades(
      bajas: _parseInt(json['bajas']),
      medias: _parseInt(json['medias']),
      altas: _parseInt(json['altas']),
      criticas: _parseInt(json['criticas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bajas': bajas,
      'medias': medias,
      'altas': altas,
      'criticas': criticas,
    };
  }

  int get total {
    return bajas + medias + altas + criticas;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}


