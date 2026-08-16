// ignore_for_file: non_constant_identifier_names, unnecessary_this
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/helpers/http_Service_helper.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';

class ClasificadoresService {
  String get API_BASE => '${url_backend.Environment.mainUrl}/clasificadores';

  String get API_GET_ARBOL_CLASIFICADOR => '$API_BASE/arbol';
  String get API_GET_CLASIFICADOR_BY_CODIGO => '$API_BASE/codigo/';
  String get API_GET_CLASIFICADORES_PAGINADO => '$API_BASE/paginado';

  // *********************************************************
  // 1.- Obtener el arbol de clasificadores
  // *********************************************************
  Future<Resource<ApiResponse<ClasificadorArbolData>>> getClasificadorArbol({
    required String token,
  }) async {
    try {
      // 1. URL
      final uri = Uri.parse(API_GET_ARBOL_CLASIFICADOR);

      // 2. Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<ClasificadorArbolData>.fromJson(
          body,
          (rawData) => ClasificadorArbolData.fromJson(
            Map<String, dynamic>.from(rawData),
          ),
        );

        return Success<ApiResponse<ClasificadorArbolData>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<ApiResponse<ClasificadorArbolData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<ClasificadorArbolData>>(
        message: 'Ocurrió un error al obtener el árbol del clasificador.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2.- Obtener clasificador por código
  // *********************************************************
  Future<Resource<ApiResponse<ClasificadorCodigoData>>>
  getClasificadorByCodigo({
    required String token,
    required String codigo,
  }) async {
    try {
      // 1.- URL
      final encodedCodigo = Uri.encodeComponent(codigo.trim());

      final uri = Uri.parse('$API_GET_CLASIFICADOR_BY_CODIGO$encodedCodigo');

      // 2.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<ClasificadorCodigoData>.fromJson(
          body,
          (rawData) => ClasificadorCodigoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ClasificadorCodigoData>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<ApiResponse<ClasificadorCodigoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<ClasificadorCodigoData>>(
        message: 'Ocurrió un error al obtener el clasificador por código.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3.- Obtener clasificadores paginados
  // *********************************************************
  Future<Resource<ApiResponse<ClasificadorPaginated>>>
  getClasificadoresPaginado({
    required String token,
    required ClasificadorQueryParams params,
  }) async {
    try {
      // 1.- URL con query parameters
      final baseUri = Uri.parse(API_GET_CLASIFICADORES_PAGINADO);

      final uri = baseUri.replace(queryParameters: params.toQueryParameters());

      // 2.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<ClasificadorPaginated>.fromJson(
          body,
          (rawData) => ClasificadorPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ClasificadorPaginated>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<
        ApiResponse<ClasificadorPaginated>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<ClasificadorPaginated>>(
        message: 'Ocurrió un error al obtener los clasificadores paginados.',
        error: error.toString(),
      );
    }
  }
}
