import 'package:sis_patrullaje_cusco/src/data/models/incidencia/mis_incidencias_query_params.dart';

class IncidenciasZonaQueryParams {
  final int page;
  final int limit;

  final MisIncidenciasMode mode;
  final IncidenciaEstadoFilter? estado;
  final IncidenciaTipoFilter? tipo;
  final IncidenciaOrigenFilter? origen;

  const IncidenciasZonaQueryParams({
    this.page = 1,
    this.limit = 10,
    this.mode = MisIncidenciasMode.app,
    this.estado,
    this.tipo,
    this.origen,
  });

  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'mode': mode.value,
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

  IncidenciasZonaQueryParams copyWith({
    int? page,
    int? limit,
    MisIncidenciasMode? mode,
    IncidenciaEstadoFilter? estado,
    IncidenciaTipoFilter? tipo,
    IncidenciaOrigenFilter? origen,
    bool clearEstado = false,
    bool clearTipo = false,
    bool clearOrigen = false,
  }) {
    return IncidenciasZonaQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      mode: mode ?? this.mode,
      estado: clearEstado ? null : estado ?? this.estado,
      tipo: clearTipo ? null : tipo ?? this.tipo,
      origen: clearOrigen ? null : origen ?? this.origen,
    );
  }
}
