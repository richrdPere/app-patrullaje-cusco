// ignore_for_file: non_constant_identifier_names, unnecessary_this

// Environment
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Mapper
import 'package:sis_patrullaje_cusco/src/data/mapper/location_mapper.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class PatrullajeService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/moviles';

  String get API_PATRULLAJE_ACTIVO => '$API_BASE/patrullaje/activo';
  String get API_START_PATRULLAJE => '$API_BASE/patrullaje';
  String get API_END_PATRULLAJE => '$API_BASE/patrullaje';
  String get API_LOCATION => '$API_BASE/patrullaje/location';

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

  // =====================================================
  // 1. GET PATRULLAJE ACTIVO
  // =====================================================
  Future<Resource<PatrullajeData?>> getPatrullajeActivo({
    required String token,
  }) async {
    try {
      final url = Uri.parse(API_PATRULLAJE_ACTIVO);
      final headers = await _getHeaders(token);
      final resp = await http.get(url, headers: headers);
      final body = _decodeResponse(resp);

      if (resp.statusCode == 200) {
        final data = body['data'];

        debugPrint("PATRULLAJE: $data");
        if (data == null) {
          return Success<PatrullajeData?>(null);
        }

        if (data is! Map<String, dynamic>) {
          return ErrorData<PatrullajeData?>(
            message: 'Formato de patrullaje inválido.',
            error: 'El campo data no contiene un objeto JSON válido.',
            statusCode: resp.statusCode,
          );
        }

        return Success<PatrullajeData>(PatrullajeData.fromJson(data));
      }

      return _buildError<PatrullajeData>(body, resp.statusCode);
    } catch (error) {
      return ErrorData<PatrullajeData>(
        message: 'Error al obtener patrullaje activo.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 2. INICIAR PATRULLAJE
  // =====================================================
  Future<Resource<bool>> startPatrullaje({
    required int patrullajeId,
    required String token,
  }) async {
    try {
      final headers = await _getHeaders(token);

      final url = Uri.parse('$API_START_PATRULLAJE/$patrullajeId/start');

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode({'patrullaje_id': patrullajeId}),
      );

      final body = _decodeResponse(resp);

      if (resp.statusCode == 200) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, resp.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al iniciar patrullaje.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 3. FINALIZAR PATRULLAJE
  // =====================================================
  Future<Resource<bool>> endPatrullaje({
    required int patrullajeId,
    required String token,
  }) async {
    try {
      final headers = await _getHeaders(token);

      final url = Uri.parse('$API_END_PATRULLAJE/$patrullajeId/end');

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode({'patrullaje_id': patrullajeId}),
      );

      final body = _decodeResponse(resp);

      if (resp.statusCode == 200) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, resp.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al finalizar patrullaje.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 4. ENVIAR UBICACIÓN
  // =====================================================
  Future<Resource<bool>> sendLocation({
    required LocationEntity location,
    required String token,
  }) async {
    try {
      final headers = await _getHeaders(token);
      final url = Uri.parse(API_LOCATION);

      final resp = await http.post(
        url,
        headers: headers,
        body: json.encode(LocationMapper.toApiJson(location)),
      );

      final body = _decodeResponse(resp);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, resp.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al enviar ubicación.',
        error: error.toString(),
      );
    }
  }
}
