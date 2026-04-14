import 'dart:convert';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';

class AuthResponse {
  String message;
  String token;
  List<String> roles;
  Usuario usuario;

  AuthResponse({
    required this.message,
    required this.token,
    required this.roles,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    message: json["message"],
    token: json["token"],
    roles: List<String>.from(json["roles"].map((x) => x)),
    usuario: Usuario.fromJson(json["usuario"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "token": token,
    "roles": List<dynamic>.from(roles.map((x) => x)),
    "usuario": usuario.toJson(),
  };
}

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());
