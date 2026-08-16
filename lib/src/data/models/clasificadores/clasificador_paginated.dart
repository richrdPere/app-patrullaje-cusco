import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';

class ClasificadorPaginated {
  final List<ClasificadorCodigoData> items;
  final ClasificadorPagination pagination;

  const ClasificadorPaginated({
    required this.items,
    required this.pagination,
  });

  factory ClasificadorPaginated.fromJson(Map<String, dynamic> json) {
    final rawData = json['items'];

    return ClasificadorPaginated(
      items: rawData is List
          ? rawData
                .whereType<Map>()
                .map(
                  (item) => ClasificadorCodigoData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <ClasificadorCodigoData>[],
      pagination: json['pagination'] is Map
          ? ClasificadorPagination.fromJson(
              Map<String, dynamic>.from(json['pagination']),
            )
          : const ClasificadorPagination(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get length => items.length;

  ClasificadorCodigoData? findByCodigo(String codigo) {
    final normalizedCodigo = codigo.trim();

    for (final clasificador in items) {
      if (clasificador.codigo == normalizedCodigo) {
        return clasificador;
      }
    }

    return null;
  }
}

// ==========================================================
// PAGINACIÓN
// ==========================================================
class ClasificadorPagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const ClasificadorPagination({
    this.totalItems = 0,
    this.totalPages = 0,
    this.currentPage = 1,
    this.pageSize = 20,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory ClasificadorPagination.fromJson(Map<String, dynamic> json) {
    return ClasificadorPagination(
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      currentPage: _parseInt(json['currentPage'], fallback: 1),
      pageSize: _parseInt(json['pageSize'], fallback: 20),
      hasNextPage: _parseBool(json['hasNextPage']),
      hasPreviousPage: _parseBool(json['hasPreviousPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}

// ==========================================================
// PARSERS
// ==========================================================

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final normalized = value?.toString().trim().toLowerCase();

  return normalized == 'true' || normalized == '1';
}
