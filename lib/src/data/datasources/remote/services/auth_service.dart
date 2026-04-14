// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AuthService with ChangeNotifier {
  // APIS
  String get API_BASE => url_backend.Environment.mainUrl;
  String get API_LOGIN => '$API_BASE/auth/login';

  // Esta autenticado - set y get
  // bool _autenticando = false;

  // bool get autenticando => this._autenticando;
  // set autenticando(bool valor) {
  //   this._autenticando = valor;
  //   notifyListeners();
  // }

  // Storage


  // *********************************************************
  // 1.- Login
  // *********************************************************
  Future<Resource<AuthResponse>> login(String username, String password) async {
    try {
      // this.autenticando = true;

      // 1.- URL Base
      Uri url = Uri.parse(API_LOGIN);
      // Uri url = Uri.parse('$baseUrlPrueba/sereno/login_Sereno');

      // 2.- Headers
      Map<String, String> headers = {'Content-Type': 'application/json'};

      // 3.- Body
      String body = json.encode({'username': username, 'password': password});

      // 4.- Response
      final resp = await http.post(url, headers: headers, body: body);
      final data = json.decode(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        AuthResponse authResponse = AuthResponse.fromJson(data);

        return Success(authResponse);
      } else {
        return Error(data['message']);
      }
    } catch (error) {
      throw Exception('Error al iniciar session: $error');
    }
  }

  // *********************************************************
  // 2.- Register
  // *********************************************************
  // Future<Resource<AuthResponse>> register(UserModel newSereno) async {
  //   try {
  //     // 1.- URL Base
  //     Uri url = Uri.parse('$baseUrlPrueba/sereno/registro_sereno');

  //     // 2.- Headers
  //     Map<String, String> headers = {'Content-Type': 'application/json'};

  //     // 3.- Body
  //     String body = json.encode(newSereno.toJson());
  //     print('NUEVO URL: $url');

  //     // 4.- Response
  //     final response = await http.post(url, headers: headers, body: body);
  //     final data = json.decode(response.body);

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       AuthResponse authResponse = AuthResponse.fromJson(data);

  //       // print('SUCCESS: ${authResponse.}');

  //       return Success(authResponse);
  //     } else {
  //       print('CUARTO PASO: $data');

  //       return Error(listToString(data['error']));
  //       // return Error(data['message']);
  //       // return Error(data['error']);
  //     }
  //   } catch (error) {
  //     // print('ERROR: $error');
  //     return Error(error.toString());
  //   }
  // }
}
