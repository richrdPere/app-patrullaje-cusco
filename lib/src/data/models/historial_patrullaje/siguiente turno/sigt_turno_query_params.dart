import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

class SiguienteTurnoQueryParams {
  final int page;
  final int limit;

  final List<HistorialTipo> tipos;
  final List<HistorialPrioridad> prioridades;

  const SiguienteTurnoQueryParams({
    this.page = 1,
    this.limit = 20,
    this.tipos = const [],
    this.prioridades = const [],
  });

  Map<String, String> toQueryParameters() {
    return {
      'page': page.toString(),
      'limit': limit.toString(),

      if (tipos.isNotEmpty) 'tipos': tipos.map((tipo) => tipo.value).join(','),

      if (prioridades.isNotEmpty)
        'prioridades': prioridades
            .map((prioridad) => prioridad.value)
            .join(','),
    };
  }

  SiguienteTurnoQueryParams copyWith({
    int? page,
    int? limit,
    List<HistorialTipo>? tipos,
    List<HistorialPrioridad>? prioridades,
  }) {
    return SiguienteTurnoQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      tipos: tipos ?? this.tipos,
      prioridades: prioridades ?? this.prioridades,
    );
  }
}
