import 'package:sis_patrullaje_cusco/src/data/models/coordenada_model.dart';

class Zona {
  final int id;
  final String nombre;
  final String riesgo;
  final String descripcion;
  final List<Coordenada> coordenadas;

  Zona({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.riesgo,
    required this.coordenadas,
  });
}