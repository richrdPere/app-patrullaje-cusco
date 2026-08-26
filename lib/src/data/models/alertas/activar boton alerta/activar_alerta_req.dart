class ActivarAlertaRequest {
  final int patrullajeId;
  final String titulo;
  final String tipo;
  final double latitud;
  final double longitud;

  const ActivarAlertaRequest({
    required this.patrullajeId,
    this.titulo = 'APOYO INMEDIATO',
    this.tipo = 'PANICO',
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> toJson() {
    return {
      'patrullaje_id': patrullajeId,
      'titulo': titulo.trim(),
      'tipo': tipo.trim().toUpperCase(),
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  ActivarAlertaRequest copyWith({
    int? patrullajeId,
    String? titulo,
    String? tipo,
    double? latitud,
    double? longitud,
  }) {
    return ActivarAlertaRequest(
      patrullajeId: patrullajeId ?? this.patrullajeId,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }
}
