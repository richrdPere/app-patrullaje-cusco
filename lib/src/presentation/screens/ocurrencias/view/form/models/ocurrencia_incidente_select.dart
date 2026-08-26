enum ModoRegistroOcurrencia { incidencia, manual }

class OcurrenciaIncidenteSeleccionado {
  final int id;
  final String titulo;
  final String? tipo;
  final String? descripcion;

  final int? patrullajeId;
  final int? zonaId;
  final int? unidadId;

  final double? latitud;
  final double? longitud;
  final String? direccion;

  final DateTime? fecha;

  const OcurrenciaIncidenteSeleccionado({
    required this.id,
    required this.titulo,
    this.tipo,
    this.descripcion,
    this.patrullajeId,
    this.zonaId,
    this.unidadId,
    this.latitud,
    this.longitud,
    this.direccion,
    this.fecha,
  });
}
