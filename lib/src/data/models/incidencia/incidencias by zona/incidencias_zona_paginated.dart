import 'package:sis_patrullaje_cusco/src/data/models/incidencia/detalle%20incidencia/incidencia_detalle_data.dart';

class IncidenciasZonaPaginated {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  /*
   * El backend utiliza "data", pero en Flutter
   * la lista será expuesta como "items".
   */
  final List<IncidenciaDetalleData> items;

  const IncidenciasZonaPaginated({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.items,
  });

  factory IncidenciasZonaPaginated.fromJson(Map<String, dynamic> json) {
    final rawItems = json['data'];

    return IncidenciasZonaPaginated(
      total: _parseInt(json['total']),
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 10),
      totalPages: _parseInt(json['totalPages']),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => IncidenciaDetalleData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  bool get estaVacio => items.isEmpty;

  bool get tieneResultados => items.isNotEmpty;

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
