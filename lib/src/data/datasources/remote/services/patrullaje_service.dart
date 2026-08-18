// ignore_for_file: non_constant_identifier_names, unnecessary_this

// Environment
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Mapper
import 'package:sis_patrullaje_cusco/src/data/mapper/location_mapper.dart';

// Helpers
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/helpers/http_Service_helper.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

class PatrullajeService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/moviles';

  String get API_PATRULLAJE_ACTIVO => '$API_BASE/patrullaje/activo';
  String get API_START_PATRULLAJE => '$API_BASE/patrullaje';
  String get API_END_PATRULLAJE => '$API_BASE/patrullaje';
  String get API_LOCATION => '$API_BASE/patrullaje/location';
  String get API_GET_MIS_PATRULLAJES_PAGINADO =>
      '$API_BASE/patrullaje/mis-patrullajes';

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

  // *********************************************************
  // 1. GET PATRULLAJE ACTIVO
  // *********************************************************
  Future<Resource<PatrullajeData?>> getPatrullajeActivo({
    required String token,
  }) async {
    try {
      final url = Uri.parse(API_PATRULLAJE_ACTIVO);
      final headers = _getHeaders(token);
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

  // *********************************************************
  // 2. INICIAR PATRULLAJE
  // *********************************************************
  Future<Resource<bool>> startPatrullaje({
    required int patrullajeId,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);

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

  // *********************************************************
  // 3. FINALIZAR PATRULLAJE
  // *********************************************************
  Future<Resource<PatrullajeData>> endPatrullaje({
    required int patrullajeId,
    required String token,
    String? observacionFinal,
  }) async {
    try {
      final headers = _getHeaders(token);

      final url = Uri.parse('$API_END_PATRULLAJE/$patrullajeId/end');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          if (observacionFinal != null && observacionFinal.trim().isNotEmpty)
            'observacion_final': observacionFinal.trim(),
        }),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final dynamic data = body['data'];

        if (data is! Map<String, dynamic>) {
          return ErrorData<PatrullajeData>(
            message: 'No se recibió la información del patrullaje finalizado.',
            error: 'La propiedad data no contiene un objeto válido.',
          );
        }

        final patrullaje = PatrullajeData.fromJson(data);

        return Success<PatrullajeData>(patrullaje);
      }

      return _buildError<PatrullajeData>(body, response.statusCode);
    } catch (error) {
      return ErrorData<PatrullajeData>(
        message: 'Error al finalizar el patrullaje.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. ENVIAR UBICACIÓN
  // *********************************************************
  Future<Resource<bool>> sendLocation({
    required LocationEntity location,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
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

  // *********************************************************
  // 5. OBTENER MIS PATRULLAJES PAGINADOS
  // *********************************************************
  Future<Resource<ApiResponse<PatrullajeSerenoPaginated>>>
  getMisPatrullajesPaginados({
    required String token,
    required PatrullajeSerenoQueryParams params,
  }) async {
    try {
      // 1.- URL + query params
      final uri = Uri.parse(
        API_GET_MIS_PATRULLAJES_PAGINADO,
      ).replace(queryParameters: params.toQueryParameters());

      // 2.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<PatrullajeSerenoPaginated>.fromJson(
          body,
          (rawData) => PatrullajeSerenoPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<PatrullajeSerenoPaginated>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<
        ApiResponse<PatrullajeSerenoPaginated>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<PatrullajeSerenoPaginated>>(
        message: 'Ocurrió un error al obtener tus patrullajes.',
        error: error.toString(),
      );
    }
  }
}
