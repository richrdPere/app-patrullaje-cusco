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
      String body = json.encode({
        'nombre': user.nombre,
        'apellidos': user.apellidos,
        'telefono': user.telefono,
        'direccion': user.direccion,
        'departamento': user.departamento,
        'provincia': user.provincia,
        'distrito': user.distrito,
      });

      // 4.- Request
      final resp = await http.put(url, headers: headers, body: body);
      final data = json.decode(resp.body);

      // 5.- Response
      if (resp.statusCode == 200) {
        Usuario userResponse = Usuario.fromJson(data);
        // return patrullajeResp;
        return Success(userResponse);
      } else {
        return ErrorData(data['message'] ?? "Error al actualizar usuario");
        //  return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print("Error: $e");
      return ErrorData("Error de conexión: $e");
      // return data['message'];
    }
  }
}
