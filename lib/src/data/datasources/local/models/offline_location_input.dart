class OfflineLocationInput {
  final String clientId;
  final int usuarioId;
  final int patrullajeId;
  final double latitud;
  final double longitud;
  final double? velocidad;
  final double? precision;
  final DateTime fechaHora;
  final String tipo;

  const OfflineLocationInput({
    required this.clientId,
    required this.usuarioId,
    required this.patrullajeId,
    required this.latitud,
    required this.longitud,
    this.velocidad,
    this.precision,
    required this.fechaHora,
    this.tipo = 'TRACKING',
  });

  Map<String, dynamic> toSyncJson() {
    return {
      'client_id': clientId,
      'patrullaje_id': patrullajeId,
      'latitud': latitud,
      'longitud': longitud,
      'velocidad': velocidad,
      'precision': precision,
      'fecha_hora': fechaHora.toUtc().toIso8601String(),
      'tipo': tipo,
    };
  }
}
