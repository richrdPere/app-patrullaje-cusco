// ===================================
// HISTORIAL TIPO
// ===================================
enum HistorialTipo {
  observacion('OBSERVACION'),
  novedad('NOVEDAD'),
  alerta('ALERTA'),
  recomendacion('RECOMENDACION'),
  puntoCritico('PUNTO_CRITICO'),
  cambioTurno('CAMBIO_TURNO');

  final String value;

  const HistorialTipo(this.value);

  static HistorialTipo fromValue(String? value) {
    return HistorialTipo.values.firstWhere(
      (item) => item.value == value?.trim().toUpperCase(),
      orElse: () => HistorialTipo.observacion,
    );
  }
}

// ===================================
// HISTORIAL PRIORIDAD
// ===================================
enum HistorialPrioridad {
  baja('BAJA'),
  media('MEDIA'),
  alta('ALTA'),
  critica('CRITICA');

  final String value;

  const HistorialPrioridad(this.value);

  static HistorialPrioridad fromValue(String? value) {
    return HistorialPrioridad.values.firstWhere(
      (item) => item.value == value?.trim().toUpperCase(),
      orElse: () => HistorialPrioridad.media,
    );
  }
}

// ===================================
// HISTORIAL ORIGEN
// ===================================
enum HistorialOrigen {
  manual('MANUAL'),
  incidencia('INCIDENCIA'),
  alerta('ALERTA'),
  sistema('SISTEMA');

  final String value;

  const HistorialOrigen(this.value);

  static HistorialOrigen fromValue(String? value) {
    return HistorialOrigen.values.firstWhere(
      (item) => item.value == value?.trim().toUpperCase(),
      orElse: () => HistorialOrigen.manual,
    );
  }
}

// ===================================
// HISTORIAL ORIGEN
// ===================================
enum HistorialEstado {
  activo('ACTIVO'),
  archivado('ARCHIVADO');

  final String value;

  const HistorialEstado(this.value);

  static HistorialEstado fromValue(String? value) {
    return HistorialEstado.values.firstWhere(
      (item) => item.value == value?.trim().toUpperCase(),
      orElse: () => HistorialEstado.activo,
    );
  }
}