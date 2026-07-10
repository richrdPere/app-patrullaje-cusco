// ignore_for_file: non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Model
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class UsersService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/usuario';

  String API_UPDATE_USER(int id) => '$API_BASE/editar/$id';

  // Helpers
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Respuesta inválida del servidor'};
    }
  }

  ErrorData<T> _buildError<T>(Map<String, dynamic> body, int statusCode) {
    return ErrorData<T>(
      message: body['message']?.toString() ?? 'Ocurrió un error.',
      error: body['error']?.toString(),
      statusCode: statusCode,
    );
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // =====================================================
  // 1. ACTUALIZAR USUARIO
  // =====================================================
  Future<Resource<Usuario>> updateUsuario({
    required int id,
    required Usuario user,
    required String token,
  }) async {
    try {
      final url = Uri.parse(API_UPDATE_USER(id));
      final headers = _getHeaders(token);

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

      final response = await http.put(url, headers: headers, body: body);

      final responseBody = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = responseBody['data'] ?? responseBody['usuario'];

        if (data != null) {
          return Success<Usuario>(Usuario.fromJson(data));
        }

        return Success<Usuario>(user);
      }

      return _buildError<Usuario>(responseBody, response.statusCode);
    } catch (error) {
      return ErrorData<Usuario>(
        message: 'Error al actualizar usuario.',
        error: error.toString(),
      );
    }
  }
}
