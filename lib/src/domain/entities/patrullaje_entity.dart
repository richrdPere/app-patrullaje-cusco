class PatrullajeEntity {
  final int id;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final Zona zona;
  final Unidad unidad;

  PatrullajeEntity({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.zona,
    required this.unidad,
  });
}

class Zona {
  final String nombre;
  final String riesgo;
  final String descripcion;
  final List<Coordenada> coordenadas;

  Zona({
    required this.nombre,
    required this.descripcion,
    required this.riesgo,
    required this.coordenadas,
  });
}

class Coordenada {
  final double lat;
  final double lng;

  Coordenada({required this.lat, required this.lng});
}

class Unidad {
  final String codigo;
  final String tipo;
  final String placa;

  Unidad({required this.codigo, required this.tipo, required this.placa});
}
