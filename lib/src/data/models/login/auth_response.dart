import 'dart:convert';
import 'package:sis_patrullaje_cusco/src/data/models/login/login_data_model.dart';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  bool success;
  String message;
  LoginDataModel data;

  AuthResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json["success"],
    message: json["message"],
    data: LoginDataModel.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}
