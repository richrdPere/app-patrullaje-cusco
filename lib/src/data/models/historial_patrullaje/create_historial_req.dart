import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

class CreateHistorialRequest {
  final int patrullajeId;
  final int? incidenciaId;

  final HistorialTipo tipo;
  final String titulo;
  final String descripcion;
  final HistorialPrioridad prioridad;

  final double? latitud;
  final double? longitud;

  final bool visibleParaSiguienteTurno;

  const CreateHistorialRequest({
    required this.patrullajeId,
    this.incidenciaId,
    this.tipo = HistorialTipo.observacion,
    required this.titulo,
    required this.descripcion,
    this.prioridad = HistorialPrioridad.media,
    this.latitud,
    this.longitud,
    this.visibleParaSiguienteTurno = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'patrullaje_id': patrullajeId,

      if (incidenciaId != null) 'incidencia_id': incidenciaId,

      'tipo': tipo.value,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'prioridad': prioridad.value,

      if (latitud != null) 'latitud': latitud,

      if (longitud != null) 'longitud': longitud,

      'visible_para_siguiente_turno': visibleParaSiguienteTurno,
    };
  }

  CreateHistorialRequest copyWith({
    int? patrullajeId,
    int? incidenciaId,
    bool clearIncidenciaId = false,
    HistorialTipo? tipo,
    String? titulo,
    String? descripcion,
    HistorialPrioridad? prioridad,
    double? latitud,
    double? longitud,
    bool clearUbicacion = false,
    bool? visibleParaSiguienteTurno,
  }) {
    return CreateHistorialRequest(
      patrullajeId: patrullajeId ?? this.patrullajeId,
      incidenciaId: clearIncidenciaId
          ? null
          : incidenciaId ?? this.incidenciaId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      latitud: clearUbicacion ? null : latitud ?? this.latitud,
      longitud: clearUbicacion ? null : longitud ?? this.longitud,
      visibleParaSiguienteTurno:
          visibleParaSiguienteTurno ?? this.visibleParaSiguienteTurno,
    );
  }
}
