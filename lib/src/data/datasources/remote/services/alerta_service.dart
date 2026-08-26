// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Resource
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class AlertaService {
  // ============================================================
  // ENDPOINTS
  // ============================================================
  String get API_BASE => '${url_backend.Environment.mainUrl}/alertas';

  String get API_GET_MIS_ALERTAS_PAGINADO => '$API_BASE/mis-alertas';
  String get API_GET_MIS_ALERTAS_RESUMEN => '$API_BASE/mis-alertas/resumen';
  String get API_ACTIVAR_ALERTA => '$API_BASE/activar';
  String get API_GET_ALERTA_ACTIVA => '$API_BASE/activa';

  String API_MARCAR_ALERTA_RECIBIDA(int alertaId) =>
      '$API_BASE/$alertaId/recibida';
  String API_MARCAR_LEIDA(int alertaId) => '$API_BASE/$alertaId/leida';
  String API_RESPONDER_ALERTA(int alertaId) => '$API_BASE/$alertaId/responder';
  String API_MARCAR_ATENDIDA(int alertaId) => '$API_BASE/$alertaId/atendida';
  String API_CANCELAR_ALERTA(int alertaId) =>
      '$API_BASE/sereno/$alertaId/cancelar';
  String API_GET_ALERTA_DETALLE(int alertaId) {
    return '$API_BASE/detalle/$alertaId';
  }

  // *********************************************************
  // 1. OBTENER MIS ALERTAS
  // *********************************************************
  Future<Resource<ApiResponse<MisAlertasPaginated>>> getMisAlertas({
    required String token,
    required MisAlertasQueryParams params,
  }) async {
    try {
      // 1.- Construir URL y query parameters
      final uri = Uri.parse(
        API_GET_MIS_ALERTAS_PAGINADO,
      ).replace(queryParameters: params.toQueryParameters());

      // 2.- Realizar petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<MisAlertasPaginated>.fromJson(
          body,
          (rawData) => MisAlertasPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<MisAlertasPaginated>>(apiResponse);
      }

      // 4.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<MisAlertasPaginated>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<MisAlertasPaginated>>(
        message: 'Ocurrió un error al obtener tus alertas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER RESUMEN DE MIS ALERTAS
  // *********************************************************
  Future<Resource<ApiResponse<MisAlertasResumenData>>> getMisAlertasResumen({
    required String token,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_GET_MIS_ALERTAS_RESUMEN);

      // 2.- Realizar petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<MisAlertasResumenData>.fromJson(
          body,
          (rawData) => MisAlertasResumenData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<MisAlertasResumenData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<MisAlertasResumenData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<MisAlertasResumenData>>(
        message: 'Ocurrió un error al obtener el resumen de tus alertas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. MARCAR ALERTA COMO RECIBIDA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarAlertaRecibida({
    required String token,
    required int alertaId,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_MARCAR_ALERTA_RECIBIDA(alertaId));

      // 2.- Realizar petición HTTP
      final response = await http
          .patch(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaUsuarioEstadoData>.fromJson(
          body,
          (rawData) => AlertaUsuarioEstadoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaUsuarioEstadoData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaUsuarioEstadoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
        message: 'Ocurrió un error al marcar la alerta como recibida.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. MARCAR ALERTA COMO LEÍDA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarAlertaLeida({
    required String token,
    required int alertaId,
  }) async {
    try {
      // 1.- Validar identificador
      if (alertaId <= 0) {
        return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
          message: 'El identificador de la alerta no es válido.',
        );
      }

      // 2.- Construir URL
      final uri = Uri.parse(API_MARCAR_LEIDA(alertaId));

      // 3.- Realizar petición HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      // 4.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 5.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaUsuarioEstadoData>.fromJson(
          body,
          (rawData) => AlertaUsuarioEstadoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaUsuarioEstadoData>>(apiResponse);
      }

      // 6.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaUsuarioEstadoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
        message: 'No se pudo marcar la alerta como leída.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. RESPONDER ALERTA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> responderAlerta({
    required String token,
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) async {
    try {
      // 1.- Validar identificador
      if (alertaId <= 0) {
        return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
          message: 'El identificador de la alerta no es válido.',
        );
      }

      // 2.- Normalizar respuesta
      final respuestaNormalizada = respuesta.trim().toUpperCase();

      // 3.- Validar respuesta
      if (respuestaNormalizada != 'ACEPTADA' &&
          respuestaNormalizada != 'RECHAZADA') {
        return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
          message: 'La respuesta debe ser ACEPTADA o RECHAZADA.',
        );
      }

      // 4.- Normalizar observación
      final observacionNormalizada = observacion?.trim();

      // 5.- Construir payload
      final payload = <String, dynamic>{
        'respuesta': respuestaNormalizada,

        if (observacionNormalizada != null && observacionNormalizada.isNotEmpty)
          'observacion': observacionNormalizada,
      };

      // 6.- Construir URL
      final uri = Uri.parse(API_RESPONDER_ALERTA(alertaId));

      // 7.- Realizar petición HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      // 8.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 9.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaUsuarioEstadoData>.fromJson(
          body,
          (rawData) => AlertaUsuarioEstadoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaUsuarioEstadoData>>(apiResponse);
      }

      // 10.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaUsuarioEstadoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
        message: 'No se pudo responder la alerta.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. MARCAR ALERTA COMO ATENDIDA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarAlertaAtendida({
    required String token,
    required int alertaId,
    String? observacion,
  }) async {
    try {
      // 1.- Normalizar observación
      final observacionNormalizada = observacion?.trim();

      // 2.- Construir payload
      final payload = <String, dynamic>{
        if (observacionNormalizada != null && observacionNormalizada.isNotEmpty)
          'observacion': observacionNormalizada,
      };

      // 3.- Construir URL
      final uri = Uri.parse(API_MARCAR_ATENDIDA(alertaId));

      // 4.- Realizar petición HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      // 5.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 6.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaUsuarioEstadoData>.fromJson(
          body,
          (rawData) => AlertaUsuarioEstadoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaUsuarioEstadoData>>(apiResponse);
      }

      // 7.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaUsuarioEstadoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaUsuarioEstadoData>>(
        message: 'No se pudo marcar la alerta como atendida.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. ACTIVAR BOTÓN DE ALERTA
  // *********************************************************
  Future<Resource<ApiResponse<ActivarAlertaData>>> activarAlerta({
    required String token,
    required ActivarAlertaRequest request,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_ACTIVAR_ALERTA);

      // 2.- Realizar petición HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<ActivarAlertaData>.fromJson(
          body,
          (rawData) => ActivarAlertaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ActivarAlertaData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<ActivarAlertaData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<ActivarAlertaData>>(
        message: 'No se pudo activar la alerta.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 8. OBTENER ALERTA ACTIVA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaActivaData>>> getAlertaActiva({
    required String token,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_GET_ALERTA_ACTIVA);

      // 2.- Realizar petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaActivaData>.fromJson(
          body,
          (rawData) => AlertaActivaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaActivaData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaActivaData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaActivaData>>(
        message: 'No se pudo obtener la alerta activa.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 9. CANCELAR ALERTA ACTIVA
  // *********************************************************
  Future<Resource<ApiResponse<CancelarAlertaData>>> cancelarAlerta({
    required String token,
    required int alertaId,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_CANCELAR_ALERTA(alertaId));

      // 2.- Realizar petición HTTP
      final response = await http
          .patch(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<CancelarAlertaData>.fromJson(
          body,
          (rawData) => CancelarAlertaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<CancelarAlertaData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<CancelarAlertaData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<CancelarAlertaData>>(
        message: 'No se pudo cancelar la alerta.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 10. OBTENER DETALLE DE ALERTA
  // *********************************************************
  Future<Resource<ApiResponse<AlertaDetalleData>>> getAlertaDetalle({
    required String token,
    required int alertaId,
  }) async {
    try {
      // 1.- Construir URL
      final uri = Uri.parse(API_GET_ALERTA_DETALLE(alertaId));

      // 2.- Realizar petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AlertaDetalleData>.fromJson(
          body,
          (rawData) => AlertaDetalleData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AlertaDetalleData>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<AlertaDetalleData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<AlertaDetalleData>>(
        message: 'No se pudo obtener el detalle de la alerta.',
        error: error.toString(),
      );
    }
  }
}
