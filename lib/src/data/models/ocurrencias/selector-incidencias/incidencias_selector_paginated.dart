import 'package:equatable/equatable.dart';

import 'incidencias_selector_data.dart';

class IncidenciasSelectorPaginated extends Equatable {
  final List<IncidenciaSelectorData> items;
  final IncidenciasSelectorPagination pagination;

  const IncidenciasSelectorPaginated({
    this.items = const [],
    required this.pagination,
  });

  factory IncidenciasSelectorPaginated.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => IncidenciaSelectorData.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <IncidenciaSelectorData>[];

    final rawPagination = json['pagination'];

    return IncidenciasSelectorPaginated(
      items: items,
      pagination: rawPagination is Map
          ? IncidenciasSelectorPagination.fromJson(
              Map<String, dynamic>.from(rawPagination),
            )
          : const IncidenciasSelectorPagination(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  @override
  List<Object?> get props => [items, pagination];
}

class IncidenciasSelectorPagination extends Equatable {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const IncidenciasSelectorPagination({
    this.page = 1,
    this.limit = 20,
    this.totalItems = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory IncidenciasSelectorPagination.fromJson(Map<String, dynamic> json) {
    return IncidenciasSelectorPagination(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 20),
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      hasNextPage: _parseBool(json['hasNextPage']),
      hasPreviousPage: _parseBool(json['hasPreviousPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;

    return value?.toString().toLowerCase() == 'true';
  }

  @override
  List<Object?> get props => [
    page,
    limit,
    totalItems,
    totalPages,
    hasNextPage,
    hasPreviousPage,
  ];
}
