// ignore_for_file: non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Model
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

class UsersService {
  final AuthRepository authRepository;

  UsersService(this.authRepository);

  // APIS
  String get API_BASE => url_backend.Environment.mainUrl + '/usuario';
  String get API_UPDATE_USER => '$API_BASE/editar/';

  // ============================
  // HEADERS
  // ============================
  Future<Map<String, String>> _getHeaders() async {
    final session = await authRepository.getUserSession();

    if (session == null) {
      throw Exception('No hay sesión activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.token}',
    };
  }

  // =====================================================
  // 1. ACTUALIZAR USUARIO
  // =====================================================
  Future<Resource<Usuario>> updateUsuario(int id, Usuario user) async {
    try {
      // 1.- Header
      final headers = await _getHeaders();

      // 2.- URL Base
      Uri url = Uri.http("$API_UPDATE_USER$id");

      // 3.- Body
      final body = json.encode({
        "persona": {
          "nombres": user.persona.nombres,
          "apellidos": user.persona.apellidos,
          "telefono": user.persona.telefono,
          "direccion": user.persona.direccion,
          "departamento": user.persona.departamento,
          "provincia": user.persona.provincia,
          "distrito": user.persona.distrito,
        },
      });

      // 4.- Request
      final resp = await http.put(url, headers: headers, body: body);
      final data = json.decode(resp.body);

      // 5.- Response
      if (resp.statusCode == 200) {
        // Tu backend devuelve solo message normalmente
        // si no devuelve usuario → no intentes mapear directo

        if (data['usuario'] != null) {
          final userResponse = Usuario.fromJson(data['usuario']);
          return Success(userResponse);
        }

        // fallback (si solo viene message)
        return Success(user);
      } else {
        return ErrorData(data['message'] ?? "Error al actualizar usuario");
      }
    } catch (e) {
      print("Error: $e");
      return ErrorData("Error de conexión: $e");
      // return data['message'];
    }
  }
}
