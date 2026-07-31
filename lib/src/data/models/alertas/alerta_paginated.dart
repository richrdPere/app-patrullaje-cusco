import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';

class AlertaPaginated {
  final List<AlertaDestinatarioModel> alertas;

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  final bool hasNextPage;
  final bool hasPreviousPage;

  const AlertaPaginated({
    required this.alertas,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory AlertaPaginated.fromJson(Map<String, dynamic> json) {
    final list = _extractList(json);
    final pagination = _extractPagination(json);

    final page =
        _parseInt(
          pagination['page'] ??
              pagination['current_page'] ??
              pagination['currentPage'],
        ) ??
        1;

    final limit =
        _parseInt(
          pagination['limit'] ??
              pagination['per_page'] ??
              pagination['pageSize'],
        ) ??
        10;

    final total =
        _parseInt(
          pagination['total'] ??
              pagination['count'] ??
              pagination['total_items'],
        ) ??
        list.length;

    final totalPages =
        _parseInt(
          pagination['total_pages'] ??
              pagination['totalPages'] ??
              pagination['last_page'],
        ) ??
        (limit > 0 ? (total / limit).ceil() : 1);

    return AlertaPaginated(
      alertas: list
          .whereType<Map>()
          .map(
            (item) => AlertaDestinatarioModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages <= 0 ? 1 : totalPages,
      hasNextPage:
          _parseBool(
            pagination['has_next_page'] ?? pagination['hasNextPage'],
          ) ||
          page < totalPages,
      hasPreviousPage:
          _parseBool(
            pagination['has_previous_page'] ?? pagination['hasPreviousPage'],
          ) ||
          page > 1,
    );
  }

  static List<dynamic> _extractList(Map<String, dynamic> json) {
    final candidates = [
      json['alertas'],
      json['rows'],
      json['items'],
      json['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }

      if (candidate is Map) {
        final nested =
            candidate['data'] ??
            candidate['alertas'] ??
            candidate['rows'] ??
            candidate['items'];

        if (nested is List) {
          return nested;
        }
      }
    }

    return <dynamic>[];
  }

  static Map<String, dynamic> _extractPagination(Map<String, dynamic> json) {
    final pagination = json['pagination'];

    if (pagination is Map) {
      return Map<String, dynamic>.from(pagination);
    }

    final data = json['data'];

    if (data is Map) {
      final nestedPagination = data['pagination'];

      if (nestedPagination is Map) {
        return Map<String, dynamic>.from(nestedPagination);
      }

      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;

    return value.toString().toLowerCase() == 'true';
  }
}
