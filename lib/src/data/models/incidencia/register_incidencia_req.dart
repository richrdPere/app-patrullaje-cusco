import 'dart:io';

class RegisterIncidenciaRequest {
  final int patrullajeId;
  final String tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final List<File> archivos;

  const RegisterIncidenciaRequest({
    required this.patrullajeId,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.archivos = const [],
  });

  RegisterIncidenciaRequest copyWith({
    int? patrullajeId,
    String? tipo,
    String? descripcion,
    double? latitud,
    double? longitud,
    List<File>? archivos,
  }) {
    return RegisterIncidenciaRequest(
      patrullajeId: patrullajeId ?? this.patrullajeId,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      archivos: archivos ?? this.archivos,
    );
  }

  Map<String, String> toFields() {
    return {
      'patrullaje_id': patrullajeId.toString(),
      'tipo': tipo.trim().toUpperCase(),
      'descripcion': descripcion.trim(),
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
    };
  }
}
