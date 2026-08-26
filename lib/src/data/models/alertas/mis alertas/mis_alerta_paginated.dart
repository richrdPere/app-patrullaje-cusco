import 'package:sis_patrullaje_cusco/src/data/models/alertas/mis%20alertas/mis_alertas_data.dart';

class MisAlertasPaginated {
  final List<MisAlertasData> items;
  final AlertasPaginationData pagination;
  final int noLeidas;

  const MisAlertasPaginated({
    required this.items,
    required this.pagination,
    required this.noLeidas,
  });

  factory MisAlertasPaginated.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return MisAlertasPaginated(
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) =>
                      MisAlertasData.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      pagination: json['pagination'] is Map
          ? AlertasPaginationData.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : const AlertasPaginationData(
              page: 1,
              limit: 10,
              total: 0,
              totalPages: 0,
            ),
      noLeidas: _parseInt(json['no_leidas']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
      'no_leidas': noLeidas,
    };
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get tieneAlertasNoLeidas => noLeidas > 0;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AlertasPaginationData {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const AlertasPaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AlertasPaginationData.fromJson(Map<String, dynamic> json) {
    return AlertasPaginationData(
      page: _parseInt(json['page'], defaultValue: 1),
      limit: _parseInt(json['limit'], defaultValue: 10),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['totalPages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  bool get hasPreviousPage => page > 1;

  bool get hasNextPage => page < totalPages;

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
