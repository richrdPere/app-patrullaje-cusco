import 'package:sis_patrullaje_cusco/src/domain/entities/incidencia_archivo_entity.dart';

class IncidenciaEntity {
  final int? id;
  final int usuarioId;
  final int? patrullajeId;
  final String tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final DateTime? fechaHora;
  final String estado;
  final List<IncidenciaArchivoEntity> archivos;

  IncidenciaEntity({
    this.id,
    required this.usuarioId,
    this.patrullajeId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.fechaHora,
    this.estado = "REPORTADO",
    this.archivos = const [],
  });
}