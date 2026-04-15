// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

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

  String get API_PATRULLAJE_ACTIVO => '$API_BASE/patrullaje/activo';
  String get API_START_PATRULLAJE => '$API_BASE/patrullaje/';
  String get API_END_PATRULLAJE => '$API_BASE/patrullaje/end';
  String get API_LOCATION => '$API_BASE/patrullaje/location';

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
  // 1. GET PATRULLAJE ACTIVO
  // =====================================================
  Future<PatrullajeModel?> getPatrullajeActivo() async {
    try {
      // 1.- Header
      final headers = await _getHeaders();

      // 2.- URL Base
      Uri url = Uri.parse(API_PATRULLAJE_ACTIVO);

      // 3.- Request
      final resp = await http.get(url, headers: headers);
      final data = json.decode(resp.body);

      // 4.- Response
      if (resp.statusCode == 200 && data != null) {
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

  // =====================================================
  // 2. INICIAR PATRULLAJE
  // =====================================================
  Future<bool> startPatrullaje(int patrullajeId) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_START_PATRULLAJE + '$patrullajeId/start');

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode({"patrullaje_id": patrullajeId}),
      );

      print("STATUS: ${resp.statusCode}");
      print("BODY: ${resp.body}");

      final data = json.decode(resp.body);

      if (resp.statusCode == 200) {
        return true;
      }

      throw Exception(data['message']);
    } catch (error) {
      throw Exception('Error al iniciar patrullaje: $error');
    }
  }

  // =====================================================
  // 3. FINALIZAR PATRULLAJE
  // =====================================================
  Future<bool> endPatrullaje(int patrullajeId) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_END_PATRULLAJE);

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode({"patrullaje_id": patrullajeId}),
      );

      final data = json.decode(resp.body);

      if (resp.statusCode == 200) {
        return true;
      }

      throw Exception(data['message']);
    } catch (error) {
      throw Exception('Error al finalizar patrullaje: $error');
    }
  }

  // =====================================================
  // 4. ENVIAR UBICACIÓN (TRACKING)
  // =====================================================
  Future<bool> sendLocation(LocationEntity location) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_LOCATION);

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode(locationToJson(location)),
      );

      final data = json.decode(resp.body);

      if (resp.statusCode == 200) {
        return true;
      }

      throw Exception(data['message']);
    } catch (error) {
      throw Exception('Error al enviar ubicación: $error');
    }
  }
}
