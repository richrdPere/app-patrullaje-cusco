import 'package:sis_patrullaje_cusco/src/domain/models/persona_model.dart';

class Usuario {
  int id;
  String username;
  String correo;
  bool estado;
  Persona persona;

  Usuario({
    required this.id,
    required this.username,
    required this.correo,
    required this.estado,
    required this.persona,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json["id"],
    username: json["username"],
    correo: json["correo"],
    estado: json["estado"],
    persona: Persona.fromJson(json["persona"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "correo": correo,
    "estado": estado,
    "persona": persona.toJson(),
  };
}
