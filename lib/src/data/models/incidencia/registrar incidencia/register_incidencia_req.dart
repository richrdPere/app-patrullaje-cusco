import 'dart:io';

enum RegisterIncidenciaTipo {
  robo('ROBO'),
  accidente('ACCIDENTE'),
  incendio('INCENDIO'),
  violencia('VIOLENCIA'),
  sospechoso('SOSPECHOSO'),
  otro('OTRO');

  final String value;

  const RegisterIncidenciaTipo(this.value);
}

class RegisterIncidenciaRequest {
  final int patrullajeId;
  final RegisterIncidenciaTipo tipo;
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

  Map<String, String> toFields() {
    return {
      'patrullaje_id': patrullajeId.toString(),
      'tipo': tipo.value,
      'descripcion': descripcion.trim(),
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
    };
  }

  RegisterIncidenciaRequest copyWith({
    int? patrullajeId,
    RegisterIncidenciaTipo? tipo,
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
}
