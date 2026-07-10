import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';

class LoginDataModel {
  final String token;
  List<String> roles;
  final Usuario usuario;

  LoginDataModel({
    required this.token,
    required this.roles,
    required this.usuario,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      token: json["token"],
      roles: List<String>.from(json["roles"].map((x) => x)),
      usuario: Usuario.fromJson(json["usuario"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "roles": List<dynamic>.from(roles.map((x) => x)),
      "usuario": usuario.toJson(),
    };
  }
}
