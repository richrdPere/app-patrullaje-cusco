class Persona {
  int id;
  String nombres;
  String apellidos;
  String documentoIdentidad;
  String? telefono;
  String? direccion;
  String? departamento;
  String? provincia;
  String? distrito;
  String? fotoPerfil;

  Persona({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.documentoIdentidad,
    this.telefono,
    this.direccion,
    this.departamento,
    this.provincia,
    this.distrito,
    this.fotoPerfil,
  });

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json["id"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        documentoIdentidad: json["documento_identidad"],
        telefono: json["telefono"],
        direccion: json["direccion"],
        departamento: json["departamento"],
        provincia: json["provincia"],
        distrito: json["distrito"],
        fotoPerfil: json["foto_perfil"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombres": nombres,
        "apellidos": apellidos,
        "documento_identidad": documentoIdentidad,
        "telefono": telefono,
        "direccion": direccion,
        "departamento": departamento,
        "provincia": provincia,
        "distrito": distrito,
        "foto_perfil": fotoPerfil,
      };
}