// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/data/models/login/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AuthService with ChangeNotifier {
  // APIS
  String get API_BASE => url_backend.Environment.mainUrl;
  String get API_LOGIN => '$API_BASE/auth/login';

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
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

  // *********************************************************
  // 1.- Login
  // *********************************************************
  Future<Resource<AuthResponse>> login(String username, String password) async {
    try {
      // this.autenticando = true;

      // 1.- URL Base
      Uri url = Uri.parse(API_LOGIN);

      // 2.- Headers
      final headers = _getHeaders();

      // 3.- Body
      String body = json.encode({'username': username, 'password': password});

      // 4.- Response
      final resp = await http.post(url, headers: headers, body: body);
      final response = _decodeResponse(resp);

      if (_isSuccess(resp.statusCode)) {
        final authResponse = AuthResponse.fromJson(response);
        return Success<AuthResponse>(authResponse);
      }

      return _buildError<AuthResponse>(response, resp.statusCode);
    } catch (error) {
      return ErrorData<AuthResponse>(
        message: 'Error al iniciar sesión.',
        error: error.toString(),
      );
    }
  }
}
