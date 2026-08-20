import 'package:sis_patrullaje_cusco/src/data/models/incidencia/mis_incidencias_query_params.dart';

class IncidenciasCercanasQueryParams {
  final double latitud;
  final double longitud;

  final double radio;
  final int limit;

  final MisIncidenciasMode mode;
  final IncidenciaTipoFilter? tipo;
  final IncidenciaEstadoFilter? estado;

  final bool incluirArchivos;

  const IncidenciasCercanasQueryParams({
    required this.latitud,
    required this.longitud,
    this.radio = 500,
    this.limit = 20,
    this.mode = MisIncidenciasMode.app,
    this.tipo,
    this.estado,
    this.incluirArchivos = false,
  });

  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'radio': radio.toString(),
      'limit': limit.toString(),
      'mode': mode.value,
      'incluir_archivos': incluirArchivos.toString(),
    };

    if (tipo != null) {
      query['tipo'] = tipo!.value;
    }

    if (estado != null) {
      query['estado'] = estado!.value;
    }

    return query;
  }

  IncidenciasCercanasQueryParams copyWith({
    double? latitud,
    double? longitud,
    double? radio,
    int? limit,
    MisIncidenciasMode? mode,
    IncidenciaTipoFilter? tipo,
    IncidenciaEstadoFilter? estado,
    bool? incluirArchivos,
    bool clearTipo = false,
    bool clearEstado = false,
  }) {
    return IncidenciasCercanasQueryParams(
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      radio: radio ?? this.radio,
      limit: limit ?? this.limit,
      mode: mode ?? this.mode,
      tipo: clearTipo ? null : tipo ?? this.tipo,
      estado: clearEstado ? null : estado ?? this.estado,
      incluirArchivos: incluirArchivos ?? this.incluirArchivos,
    );
  }
}
