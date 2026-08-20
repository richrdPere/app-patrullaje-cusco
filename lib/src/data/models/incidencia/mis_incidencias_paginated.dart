import 'package:sis_patrullaje_cusco/src/data/models/incidencia/incidencia_listado_data.dart';

class MisIncidenciasPaginated {
  final List<IncidenciaListadoData> items;
  final MisIncidenciasPagination pagination;
  final MisIncidenciasFilters filters;

  const MisIncidenciasPaginated({
    required this.items,
    required this.pagination,
    required this.filters,
  });

  factory MisIncidenciasPaginated.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return MisIncidenciasPaginated(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => IncidenciaListadoData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      pagination: json['pagination'] is Map
          ? MisIncidenciasPagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : const MisIncidenciasPagination(),
      filters: json['filters'] is Map
          ? MisIncidenciasFilters.fromJson(
              Map<String, dynamic>.from(json['filters'] as Map),
            )
          : const MisIncidenciasFilters(),
    );
  }
}

class MisIncidenciasPagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const MisIncidenciasPagination({
    this.page = 1,
    this.limit = 10,
    this.totalItems = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory MisIncidenciasPagination.fromJson(Map<String, dynamic> json) {
    return MisIncidenciasPagination(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 10),
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      hasNextPage: _parseBool(json['hasNextPage']),
      hasPreviousPage: _parseBool(json['hasPreviousPage']),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    return value?.toString().toLowerCase() == 'true';
  }
}

class MisIncidenciasFilters {
  final int? usuarioId;
  final String? mode;
  final String? estado;
  final String? tipo;
  final String? origen;
  final bool incluirArchivos;

  const MisIncidenciasFilters({
    this.usuarioId,
    this.mode,
    this.estado,
    this.tipo,
    this.origen,
    this.incluirArchivos = false,
  });

  factory MisIncidenciasFilters.fromJson(Map<String, dynamic> json) {
    return MisIncidenciasFilters(
      usuarioId: _parseNullableInt(json['usuario_id']),
      mode: json['mode']?.toString(),
      estado: json['estado']?.toString(),
      tipo: json['tipo']?.toString(),
      origen: json['origen']?.toString(),
      incluirArchivos: _parseBool(json['incluir_archivos']),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    return value?.toString().toLowerCase() == 'true';
  }
}
