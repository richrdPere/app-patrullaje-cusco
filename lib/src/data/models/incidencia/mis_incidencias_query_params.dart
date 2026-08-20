enum MisIncidenciasMode {
  app('app'),
  web('web');

  final String value;

  const MisIncidenciasMode(this.value);
}

enum IncidenciaEstadoFilter {
  reportado('REPORTADO'),
  enProceso('EN_PROCESO'),
  atendido('ATENDIDO'),
  cerrado('CERRADO');

  final String value;

  const IncidenciaEstadoFilter(this.value);
}

enum IncidenciaTipoFilter {
  robo('ROBO'),
  accidente('ACCIDENTE'),
  incendio('INCENDIO'),
  violencia('VIOLENCIA'),
  sospechoso('SOSPECHOSO'),
  otro('OTRO');

  final String value;

  const IncidenciaTipoFilter(this.value);
}

enum IncidenciaOrigenFilter {
  appMovil('APP_MOVIL'),
  central('CENTRAL'),
  sistema('SISTEMA');

  final String value;

  const IncidenciaOrigenFilter(this.value);
}

class MisIncidenciasQueryParams {
  final int page;
  final int limit;

  final MisIncidenciasMode mode;
  final IncidenciaEstadoFilter? estado;
  final IncidenciaTipoFilter? tipo;
  final IncidenciaOrigenFilter? origen;

  final bool incluirArchivos;

  const MisIncidenciasQueryParams({
    this.page = 1,
    this.limit = 10,
    this.mode = MisIncidenciasMode.app,
    this.estado,
    this.tipo,
    this.origen,
    this.incluirArchivos = false,
  });

  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'mode': mode.value,
      'incluir_archivos': incluirArchivos.toString(),
    };

    if (estado != null) {
      query['estado'] = estado!.value;
    }

    if (tipo != null) {
      query['tipo'] = tipo!.value;
    }

    if (origen != null) {
      query['origen'] = origen!.value;
    }

    return query;
  }

  MisIncidenciasQueryParams copyWith({
    int? page,
    int? limit,
    MisIncidenciasMode? mode,
    IncidenciaEstadoFilter? estado,
    IncidenciaTipoFilter? tipo,
    IncidenciaOrigenFilter? origen,
    bool? incluirArchivos,
    bool clearEstado = false,
    bool clearTipo = false,
    bool clearOrigen = false,
  }) {
    return MisIncidenciasQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      mode: mode ?? this.mode,
      estado: clearEstado ? null : estado ?? this.estado,
      tipo: clearTipo ? null : tipo ?? this.tipo,
      origen: clearOrigen ? null : origen ?? this.origen,
      incluirArchivos: incluirArchivos ?? this.incluirArchivos,
    );
  }
}
