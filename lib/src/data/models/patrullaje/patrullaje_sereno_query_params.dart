// patrullaje_sereno_query_params.dart

enum PatrullajeEstadoFilter {
  programado('PROGRAMADO'),
  asignado('ASIGNADO'),
  aceptado('ACEPTADO'),
  enCurso('EN_CURSO'),
  finalizado('FINALIZADO');

  final String value;

  const PatrullajeEstadoFilter(this.value);
}

enum PatrullajePersonalEstadoFilter {
  asignado('ASIGNADO'),
  aceptado('ACEPTADO'),
  rechazado('RECHAZADO'),
  enServicio('EN_SERVICIO'),
  finalizado('FINALIZADO');

  final String value;

  const PatrullajePersonalEstadoFilter(this.value);
}

enum PatrullajeOrderBy {
  fecha('fecha'),
  horaInicio('hora_inicio'),
  horaFin('hora_fin'),
  estado('estado'),
  createdAt('createdAt');

  final String value;

  const PatrullajeOrderBy(this.value);
}

enum OrderDirection {
  asc('ASC'),
  desc('DESC');

  final String value;

  const OrderDirection(this.value);
}

class PatrullajeSerenoQueryParams {
  final int page;
  final int limit;

  final PatrullajeEstadoFilter? estado;
  final PatrullajePersonalEstadoFilter? estadoPersonal;

  final int? zonaId;
  final int? unidadId;

  /// Fecha exacta del patrullaje.
  ///
  /// Cuando [dia] tiene valor, no se envían [fechaDesde]
  /// ni [fechaHasta].
  final DateTime? dia;

  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  final String? search;

  final PatrullajeOrderBy orderBy;
  final OrderDirection orderDirection;

  const PatrullajeSerenoQueryParams({
    this.page = 1,
    this.limit = 10,
    this.estado,
    this.estadoPersonal,
    this.zonaId,
    this.unidadId,
    this.dia,
    this.fechaDesde,
    this.fechaHasta,
    this.search,
    this.orderBy = PatrullajeOrderBy.fecha,
    this.orderDirection = OrderDirection.desc,
  });

  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'order_by': orderBy.value,
      'order_direction': orderDirection.value,
    };

    if (estado != null) {
      query['estado'] = estado!.value;
    }

    if (estadoPersonal != null) {
      query['estado_personal'] = estadoPersonal!.value;
    }

    if (zonaId != null) {
      query['zona_id'] = zonaId.toString();
    }

    if (unidadId != null) {
      query['unidad_id'] = unidadId.toString();
    }

    // ==========================================================
    // FILTRO POR DÍA O RANGO DE FECHAS
    // ==========================================================
    if (dia != null) {
      query['dia'] = _formatDate(dia!);
    } else {
      if (fechaDesde != null) {
        query['fecha_desde'] = _formatDate(fechaDesde!);
      }

      if (fechaHasta != null) {
        query['fecha_hasta'] = _formatDate(fechaHasta!);
      }
    }

    final normalizedSearch = search?.trim();

    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      query['search'] = normalizedSearch;
    }

    return query;
  }

  PatrullajeSerenoQueryParams copyWith({
    int? page,
    int? limit,
    PatrullajeEstadoFilter? estado,
    PatrullajePersonalEstadoFilter? estadoPersonal,
    int? zonaId,
    int? unidadId,
    DateTime? dia,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? search,
    PatrullajeOrderBy? orderBy,
    OrderDirection? orderDirection,

    bool clearEstado = false,
    bool clearEstadoPersonal = false,
    bool clearZonaId = false,
    bool clearUnidadId = false,
    bool clearDia = false,
    bool clearFechaDesde = false,
    bool clearFechaHasta = false,
    bool clearSearch = false,
  }) {
    return PatrullajeSerenoQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      estado: clearEstado ? null : estado ?? this.estado,
      estadoPersonal: clearEstadoPersonal
          ? null
          : estadoPersonal ?? this.estadoPersonal,
      zonaId: clearZonaId ? null : zonaId ?? this.zonaId,
      unidadId: clearUnidadId ? null : unidadId ?? this.unidadId,
      dia: clearDia ? null : dia ?? this.dia,
      fechaDesde: clearFechaDesde ? null : fechaDesde ?? this.fechaDesde,
      fechaHasta: clearFechaHasta ? null : fechaHasta ?? this.fechaHasta,
      search: clearSearch ? null : search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
    );
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
