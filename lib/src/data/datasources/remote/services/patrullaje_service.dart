// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Repository
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

class PatrullajeService {
  final AuthRepository authRepository;

  PatrullajeService(this.authRepository);

  // APIS
  String get API_BASE => url_backend.Environment.mainUrl + '/moviles';
  String get API_PATRULLAJE_aCTIVO => '$API_BASE/patrullaje/activo';

  Future<PatrullajeModel?> getPatrullajeActivo() async {
    try {
      // 1. Obtener usuario logueado
      final session = await authRepository.getUserSession();

      if (session == null) {
        throw Exception('No hay sesión activa');
      }

      final token = session.token;

      // 2.- URL Base
      Uri url = Uri.parse(API_PATRULLAJE_aCTIVO);

      // 3.- Headers con token
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 4.- Request
      final resp = await http.get(url, headers: headers);
      final data = json.decode(resp.body);

      // return PatrullajeModel.fromJson(resp.data);

      if (resp.statusCode == 200) {
        PatrullajeModel patrullajeResp = PatrullajeModel.fromJson(data);
        return patrullajeResp;
        //  return Success(patrullajeResp);
      } else {
        return data['message'];
        //  return Error(data['message']);
      }
    } catch (error) {
      throw Exception('Error al iniciar session: $error');
    }
  }
}
