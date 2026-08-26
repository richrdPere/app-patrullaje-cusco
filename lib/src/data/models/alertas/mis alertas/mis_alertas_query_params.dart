class MisAlertasQueryParams {
  final int page;
  final int limit;

  /// Estado de la alerta recibida:
  /// PENDIENTE, RECIBIDA, LEIDA, RESPONDIDA, ATENDIDA, etc.
  final String? estado;

  /// BAJA, MEDIA, ALTA, CRITICA
  final String? prioridad;

  /// INFORMATIVA, INCIDENCIA, EMERGENCIA, PANICO, SOS, etc.
  final String? tipo;

  /// true: devuelve únicamente alertas no leídas.
  final bool? noLeidas;

  const MisAlertasQueryParams({
    this.page = 1,
    this.limit = 10,
    this.estado,
    this.prioridad,
    this.tipo,
    this.noLeidas,
  });

  Map<String, String> toQueryParameters() {
    final normalizedEstado = estado?.trim();
    final normalizedPrioridad = prioridad?.trim();
    final normalizedTipo = tipo?.trim();

    return {
      'page': page.toString(),
      'limit': limit.toString(),

      if (normalizedEstado != null && normalizedEstado.isNotEmpty)
        'estado': normalizedEstado,

      if (normalizedPrioridad != null && normalizedPrioridad.isNotEmpty)
        'prioridad': normalizedPrioridad,

      if (normalizedTipo != null && normalizedTipo.isNotEmpty)
        'tipo': normalizedTipo,

      if (noLeidas != null) 'no_leidas': noLeidas.toString(),
    };
  }

  MisAlertasQueryParams copyWith({
    int? page,
    int? limit,
    String? estado,
    String? prioridad,
    String? tipo,
    bool? noLeidas,
    bool clearEstado = false,
    bool clearPrioridad = false,
    bool clearTipo = false,
    bool clearNoLeidas = false,
  }) {
    return MisAlertasQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      estado: clearEstado ? null : estado ?? this.estado,
      prioridad: clearPrioridad ? null : prioridad ?? this.prioridad,
      tipo: clearTipo ? null : tipo ?? this.tipo,
      noLeidas: clearNoLeidas ? null : noLeidas ?? this.noLeidas,
    );
  }
}
