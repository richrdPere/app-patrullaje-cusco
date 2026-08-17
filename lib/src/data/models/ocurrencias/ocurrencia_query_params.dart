class OcurrenciaQueryParams {
  final int page;
  final int limit;

  final String? numero;
  final String? codigo;

  /// Formato: yyyy-MM-dd
  final String? fecha;

  /// Formato: yyyy-MM-dd
  final String? fechaDesde;

  /// Formato: yyyy-MM-dd
  final String? fechaHasta;

  final int? serenoId;
  final int? zonaId;

  final String? turno;
  final String? estado;
  final String? estadoRemision;

  const OcurrenciaQueryParams({
    this.page = 1,
    this.limit = 20,
    this.numero,
    this.codigo,
    this.fecha,
    this.fechaDesde,
    this.fechaHasta,
    this.serenoId,
    this.zonaId,
    this.turno,
    this.estado,
    this.estadoRemision,
  });

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    _addString(params, 'numero', numero);
    _addString(params, 'codigo', codigo);

    _addString(params, 'fecha', fecha);
    _addString(params, 'fecha_desde', fechaDesde);
    _addString(params, 'fecha_hasta', fechaHasta);

    _addInt(params, 'sereno_id', serenoId);
    _addInt(params, 'zona_id', zonaId);

    _addString(params, 'turno', turno);
    _addString(params, 'estado', estado);
    _addString(params, 'estado_remision', estadoRemision);

    return params;
  }

  OcurrenciaQueryParams copyWith({
    int? page,
    int? limit,
    String? numero,
    String? codigo,
    String? fecha,
    String? fechaDesde,
    String? fechaHasta,
    int? serenoId,
    int? zonaId,
    String? turno,
    String? estado,
    String? estadoRemision,
    bool clearNumero = false,
    bool clearCodigo = false,
    bool clearFecha = false,
    bool clearFechaDesde = false,
    bool clearFechaHasta = false,
    bool clearSerenoId = false,
    bool clearZonaId = false,
    bool clearTurno = false,
    bool clearEstado = false,
    bool clearEstadoRemision = false,
  }) {
    return OcurrenciaQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      numero: clearNumero ? null : numero ?? this.numero,
      codigo: clearCodigo ? null : codigo ?? this.codigo,
      fecha: clearFecha ? null : fecha ?? this.fecha,
      fechaDesde: clearFechaDesde ? null : fechaDesde ?? this.fechaDesde,
      fechaHasta: clearFechaHasta ? null : fechaHasta ?? this.fechaHasta,
      serenoId: clearSerenoId ? null : serenoId ?? this.serenoId,
      zonaId: clearZonaId ? null : zonaId ?? this.zonaId,
      turno: clearTurno ? null : turno ?? this.turno,
      estado: clearEstado ? null : estado ?? this.estado,
      estadoRemision: clearEstadoRemision
          ? null
          : estadoRemision ?? this.estadoRemision,
    );
  }

  OcurrenciaQueryParams nextPage() {
    return copyWith(page: page + 1);
  }

  OcurrenciaQueryParams previousPage() {
    return copyWith(page: page > 1 ? page - 1 : 1);
  }

  OcurrenciaQueryParams resetPage() {
    return copyWith(page: 1);
  }

  OcurrenciaQueryParams clearFilters() {
    return OcurrenciaQueryParams(page: 1, limit: limit);
  }

  static void _addString(
    Map<String, String> params,
    String key,
    String? value,
  ) {
    final normalized = value?.trim();

    if (normalized != null && normalized.isNotEmpty) {
      params[key] = normalized;
    }
  }

  static void _addInt(Map<String, String> params, String key, int? value) {
    if (value != null && value > 0) {
      params[key] = value.toString();
    }
  }
}
