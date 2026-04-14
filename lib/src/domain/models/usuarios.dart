class Usuario {
  int id;
  String nombre;
  String apellidos;
  String username;
  String telefono;
  String direccion;
  String distrito;
  String provincia;
  String departamento;
  bool online;
  dynamic fotoPerfil;

  Usuario({
    this.id = 0,
    this.nombre = "",
    this.apellidos = "",
    this.username = "",
    this.telefono = "",
    this.direccion = "",
    this.distrito = "",
    this.provincia = "",
    this.departamento = "",
    this.online = false,
    this.fotoPerfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json["id"],
    nombre: json["nombre"],
    apellidos: json["apellidos"],
    username: json["username"],
    telefono: json["telefono"],
    direccion: json["direccion"],
    distrito: json["distrito"],
    provincia: json["provincia"],
    departamento: json["departamento"],
    online: json["online"],
    fotoPerfil: json["foto_perfil"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "apellidos": apellidos,
    "username": username,
    "telefono": telefono,
    "direccion": direccion,
    "distrito": distrito,
    "provincia": provincia,
    "departamento": departamento,
    "online": online,
    "foto_perfil": fotoPerfil,
  };
}
