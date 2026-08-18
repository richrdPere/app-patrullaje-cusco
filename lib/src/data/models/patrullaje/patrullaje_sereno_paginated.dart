// patrullaje_sereno_paginated.dart

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';

class PatrullajeSerenoPaginated {
  final List<PatrullajeListadoData> items;
  final PatrullajePagination pagination;
  final PatrullajeAppliedFilters filters;

  const PatrullajeSerenoPaginated({
    required this.items,
    required this.pagination,
    required this.filters,
  });

  factory PatrullajeSerenoPaginated.fromJson(Map<String, dynamic> json) {
    return PatrullajeSerenoPaginated(
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => PatrullajeListadoData.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      pagination: PatrullajePagination.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map? ?? {}),
      ),
      filters: PatrullajeAppliedFilters.fromJson(
        Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
      'filters': filters.toJson(),
    };
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get hasNextPage => pagination.hasNextPage;

  bool get hasPreviousPage => pagination.hasPreviousPage;
}

class PatrullajePagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PatrullajePagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PatrullajePagination.fromJson(Map<String, dynamic> json) {
    return PatrullajePagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit'], fallback: 10),
      totalItems: _parseInt(json['totalItems']),
      totalPages: _parseInt(json['totalPages']),
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
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
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class PatrullajeAppliedFilters {
  final int? serenoId;
  final String? estado;
  final String? estadoPersonal;
  final int? zonaId;
  final int? unidadId;
  final String? fechaDesde;
  final String? fechaHasta;
  final String? search;

  const PatrullajeAppliedFilters({
    this.serenoId,
    this.estado,
    this.estadoPersonal,
    this.zonaId,
    this.unidadId,
    this.fechaDesde,
    this.fechaHasta,
    this.search,
  });

  factory PatrullajeAppliedFilters.fromJson(Map<String, dynamic> json) {
    return PatrullajeAppliedFilters(
      serenoId: _parseNullableInt(json['sereno_id']),
      estado: json['estado']?.toString(),
      estadoPersonal: json['estado_personal']?.toString(),
      zonaId: _parseNullableInt(json['zona_id']),
      unidadId: _parseNullableInt(json['unidad_id']),
      fechaDesde: json['fecha_desde']?.toString(),
      fechaHasta: json['fecha_hasta']?.toString(),
      search: json['search']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sereno_id': serenoId,
      'estado': estado,
      'estado_personal': estadoPersonal,
      'zona_id': zonaId,
      'unidad_id': unidadId,
      'fecha_desde': fechaDesde,
      'fecha_hasta': fechaHasta,
      'search': search,
    };
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
