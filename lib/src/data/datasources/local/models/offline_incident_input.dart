import 'offline_incident_file_input.dart';

class OfflineIncidentInput {
  final String clientId;
  final int usuarioId;
  final int? patrullajeId;
  final int? zonaId;
  final String tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final DateTime fechaHora;
  final List<OfflineIncidentFileInput> archivos;

  const OfflineIncidentInput({
    required this.clientId,
    required this.usuarioId,
    this.patrullajeId,
    this.zonaId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
    this.archivos = const [],
  });

  Map<String, String> toSyncFields() {
    return {
      'client_id': clientId,
      if (patrullajeId != null) 'patrullaje_id': patrullajeId.toString(),
      if (zonaId != null) 'zona_id': zonaId.toString(),
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'fecha_hora': fechaHora.toUtc().toIso8601String(),
    };
  }
}
