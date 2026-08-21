import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial%20contexto%20zona/contexto_zona_data.dart';

class SiguienteTurnoData {
  final ContextoZona zona;

  final SiguienteTurnoPatrullajeData patrullajeActual;

  final SiguienteTurnoPatrullajeData? patrullajeAnterior;

  final ContextoResumen resumen;

  final List<ContextoHistorialItem> historial;

  final ContextoPagination pagination;

  final bool tienePatrullajeAnterior;
  final bool tieneContextoAnterior;

  const SiguienteTurnoData({
    required this.zona,
    required this.patrullajeActual,
    this.patrullajeAnterior,
    required this.resumen,
    required this.historial,
    required this.pagination,
    required this.tienePatrullajeAnterior,
    required this.tieneContextoAnterior,
  });

  factory SiguienteTurnoData.fromJson(Map<String, dynamic> json) {
    final zonaJson = _parseMap(json['zona']);

    final patrullajeActualJson = _parseMap(json['patrullaje_actual']);

    final patrullajeAnteriorJson = _parseNullableMap(
      json['patrullaje_anterior'],
    );

    final resumenJson = _parseMap(json['resumen']);

    final paginationJson = _parseMap(json['pagination']);

    return SiguienteTurnoData(
      zona: ContextoZona.fromJson(zonaJson),

      patrullajeActual: SiguienteTurnoPatrullajeData.fromJson(
        patrullajeActualJson,
      ),

      patrullajeAnterior: patrullajeAnteriorJson == null
          ? null
          : SiguienteTurnoPatrullajeData.fromJson(patrullajeAnteriorJson),

      resumen: ContextoResumen.fromJson(resumenJson),

      historial: _parseHistorial(json['historial']),

      pagination: ContextoPagination.fromJson(paginationJson),

      tienePatrullajeAnterior: _parseBool(
        json['tiene_patrullaje_anterior'],
        defaultValue: patrullajeAnteriorJson != null,
      ),

      tieneContextoAnterior: _parseBool(
        json['tiene_contexto_anterior'],
        defaultValue: false,
      ),
    );
  }

  bool get tieneHistorial {
    return historial.isNotEmpty;
  }

  bool get tieneMasPaginas {
    return pagination.hasNextPage;
  }

  bool get esPrimerPatrullajeZona {
    return !tienePatrullajeAnterior;
  }

  static List<ContextoHistorialItem> _parseHistorial(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              ContextoHistorialItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static Map<String, dynamic>? _parseNullableMap(dynamic value) {
    if (value == null) {
      return null;
    }

    final parsed = _parseMap(value);

    return parsed.isEmpty ? null : parsed;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    final normalized = value?.toString().trim().toLowerCase();

    if (normalized == 'true' || normalized == '1') {
      return true;
    }

    if (normalized == 'false' || normalized == '0') {
      return false;
    }

    return defaultValue;
  }
}

class SiguienteTurnoPatrullajeData {
  final int id;
  final int? unidadId;
  final int zonaId;

  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  final String estado;
  final String? descripcion;

  const SiguienteTurnoPatrullajeData({
    required this.id,
    this.unidadId,
    required this.zonaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.descripcion,
  });

  factory SiguienteTurnoPatrullajeData.fromJson(Map<String, dynamic> json) {
    return SiguienteTurnoPatrullajeData(
      id: _parseInt(json['id']),

      unidadId: _parseNullableInt(json['unidad_id']),

      zonaId: _parseInt(json['zona_id']),

      fecha: _parseDateOnly(json['fecha']),

      horaInicio: json['hora_inicio']?.toString().trim() ?? '',

      horaFin: json['hora_fin']?.toString().trim() ?? '',

      estado: json['estado']?.toString().trim() ?? '',

      descripcion: _parseNullableString(json['descripcion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidad_id': unidadId,
      'zona_id': zonaId,
      'fecha': _formatDateOnly(fecha),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'descripcion': descripcion,
    };
  }

  bool get estaEnCurso {
    return estado == 'EN_CURSO';
  }

  bool get estaFinalizado {
    return estado == 'FINALIZADO';
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
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

  static DateTime _parseDateOnly(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String? _parseNullableString(dynamic value) {
    final parsed = value?.toString().trim();

    if (parsed == null || parsed.isEmpty) {
      return null;
    }

    return parsed;
  }

  static String _formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
