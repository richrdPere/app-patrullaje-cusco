import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

class ContextoZonaQueryParams {
  final int page;
  final int limit;
  final int dias;

  final List<HistorialTipo> tipos;
  final List<HistorialPrioridad> prioridades;

  const ContextoZonaQueryParams({
    this.page = 1,
    this.limit = 20,
    this.dias = 30,
    this.tipos = const [],
    this.prioridades = const [],
  });

  Map<String, String> toQueryParameters() {
    return {
      'page': page.toString(),
      'limit': limit.toString(),
      'dias': dias.toString(),

      if (tipos.isNotEmpty) 'tipos': tipos.map((tipo) => tipo.value).join(','),

      if (prioridades.isNotEmpty)
        'prioridades': prioridades
            .map((prioridad) => prioridad.value)
            .join(','),
    };
  }

  ContextoZonaQueryParams copyWith({
    int? page,
    int? limit,
    int? dias,
    List<HistorialTipo>? tipos,
    List<HistorialPrioridad>? prioridades,
  }) {
    return ContextoZonaQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      dias: dias ?? this.dias,
      tipos: tipos ?? this.tipos,
      prioridades: prioridades ?? this.prioridades,
    );
  }
}
