import 'dart:convert';

import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AlertaService {

  // ============================================================
  // ENDPOINTS
  // ============================================================
  String get API_BASE => '${url_backend.Environment.mainUrl}/alertas';

  String get API_MIS_ALERTAS => '$API_BASE/mis-alertas';

  String get API_MIS_ALERTAS_RESUMEN => '$API_BASE/mis-alertas/resumen';

  String API_MARCAR_RECIBIDA(int alertaId) => '$API_BASE/$alertaId/recibida';

  String API_MARCAR_LEIDA(int alertaId) => '$API_BASE/$alertaId/leida';

  String API_RESPONDER_ALERTA(int alertaId) => '$API_BASE/$alertaId/responder';

  String API_MARCAR_ATENDIDA(int alertaId) => '$API_BASE/$alertaId/atendida';

  // ============================================================
  // HEADERS
  // ============================================================

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        'success': false,
        'message': 'La respuesta del servidor no tiene un formato válido.',
        'data': decoded,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Respuesta inválida del servidor.',
        'error': response.body,
      };
    }
  }

  ErrorData<T> _buildError<T>(Map<String, dynamic> body, int statusCode) {
    return ErrorData<T>(
      message:
          body['message']?.toString() ??
          body['msg']?.toString() ??
          'Ocurrió un error al procesar la solicitud.',
      error: body['error']?.toString(),
      statusCode: statusCode,
    );
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractDestinatarioData(Map<String, dynamic> body) {
    final data = _extractDataMap(body);

    if (data.isEmpty) {
      return data;
    }

    final destinatario = data['destinatario'];

    if (destinatario is Map<String, dynamic>) {
      return destinatario;
    }

    if (destinatario is Map) {
      return Map<String, dynamic>.from(destinatario);
    }

    return data;
  }


  // ============================================================
  // 1. OBTENER MIS ALERTAS
  // ============================================================
  Future<Resource<AlertaPaginated>> getMisAlertas({
    required String token,
    int page = 1,
    int limit = 10,
    String? estado,
    String? tipo,
    String? prioridad,
    bool? requiereConfirmacion,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (estado != null && estado.trim().isNotEmpty)
          'estado': estado.trim().toUpperCase(),
        if (tipo != null && tipo.trim().isNotEmpty)
          'tipo': tipo.trim().toUpperCase(),
        if (prioridad != null && prioridad.trim().isNotEmpty)
          'prioridad': prioridad.trim().toUpperCase(),
        if (requiereConfirmacion != null)
          'requiere_confirmacion': requiereConfirmacion.toString(),
      };

      final uri = Uri.parse(
        API_MIS_ALERTAS,
      ).replace(queryParameters: queryParameters);

      final response = await http.get(uri, headers: _getHeaders(token));

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaPaginated>(body, response.statusCode);
      }

      /*
       * AlertaPaginated ya soporta:
       *
       * data: [...]
       * data: { data: [...], pagination: {...} }
       * data: { alertas: [...], ... }
       */
      return Success<AlertaPaginated>(AlertaPaginated.fromJson(body));
    } catch (error) {
      return ErrorData<AlertaPaginated>(
        message: 'No se pudieron obtener las alertas.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 2. OBTENER RESUMEN
  // ============================================================
  Future<Resource<AlertaResumenModel>> getMisAlertasResumen({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(API_MIS_ALERTAS_RESUMEN),
        headers: _getHeaders(token),
      );

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaResumenModel>(body, response.statusCode);
      }

      return Success<AlertaResumenModel>(AlertaResumenModel.fromJson(body));
    } catch (error) {
      return ErrorData<AlertaResumenModel>(
        message: 'No se pudo obtener el resumen de alertas.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 3. MARCAR COMO RECIBIDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarRecibida({
    required String token,
    required int alertaId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(API_MARCAR_RECIBIDA(alertaId)),
        headers: _getHeaders(token),
        body: jsonEncode({}),
      );

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaDestinatarioModel>(body, response.statusCode);
      }

      final data = _extractDestinatarioData(body);

      if (data.isEmpty) {
        return ErrorData<AlertaDestinatarioModel>(
          message: 'El servidor no devolvió el destinatario actualizado.',
          statusCode: response.statusCode,
        );
      }

      return Success<AlertaDestinatarioModel>(
        AlertaDestinatarioModel.fromJson(data),
      );
    } catch (error) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No se pudo marcar la alerta como recibida.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 4. MARCAR COMO LEÍDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarLeida({
    required String token,
    required int alertaId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(API_MARCAR_LEIDA(alertaId)),
        headers: _getHeaders(token),
        body: jsonEncode({}),
      );

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaDestinatarioModel>(body, response.statusCode);
      }

      final data = _extractDestinatarioData(body);

      if (data.isEmpty) {
        return ErrorData<AlertaDestinatarioModel>(
          message: 'El servidor no devolvió el destinatario actualizado.',
          statusCode: response.statusCode,
        );
      }

      return Success<AlertaDestinatarioModel>(
        AlertaDestinatarioModel.fromJson(data),
      );
    } catch (error) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No se pudo marcar la alerta como leída.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 5. RESPONDER ALERTA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> responderAlerta({
    required String token,
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) async {
    try {
      final respuestaNormalizada = respuesta.trim().toUpperCase();

      if (respuestaNormalizada != 'ACEPTADA' &&
          respuestaNormalizada != 'RECHAZADA') {
        return ErrorData<AlertaDestinatarioModel>(
          message: 'La respuesta debe ser ACEPTADA o RECHAZADA.',
        );
      }

      final payload = <String, dynamic>{
        /*
         * Ajusta a "respuesta" o "estado" según lo que lea
         * responderAlertaService en tu backend.
         */
        'respuesta': respuestaNormalizada,
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      };

      final response = await http.patch(
        Uri.parse(API_RESPONDER_ALERTA(alertaId)),
        headers: _getHeaders(token),
        body: jsonEncode(payload),
      );

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaDestinatarioModel>(body, response.statusCode);
      }

      final data = _extractDestinatarioData(body);

      if (data.isEmpty) {
        return ErrorData<AlertaDestinatarioModel>(
          message: 'El servidor no devolvió la respuesta actualizada.',
          statusCode: response.statusCode,
        );
      }

      return Success<AlertaDestinatarioModel>(
        AlertaDestinatarioModel.fromJson(data),
      );
    } catch (error) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No se pudo responder la alerta.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 6. MARCAR COMO ATENDIDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarAtendida({
    required String token,
    required int alertaId,
    String? observacion,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (observacion != null && observacion.trim().isNotEmpty)
          'observacion': observacion.trim(),
      };

      final response = await http.patch(
        Uri.parse(API_MARCAR_ATENDIDA(alertaId)),
        headers: _getHeaders(token),
        body: jsonEncode(payload),
      );

      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<AlertaDestinatarioModel>(body, response.statusCode);
      }

      final data = _extractDestinatarioData(body);

      if (data.isEmpty) {
        return ErrorData<AlertaDestinatarioModel>(
          message: 'El servidor no devolvió el destinatario actualizado.',
          statusCode: response.statusCode,
        );
      }

      return Success<AlertaDestinatarioModel>(
        AlertaDestinatarioModel.fromJson(data),
      );
    } catch (error) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No se pudo marcar la alerta como atendida.',
        error: error.toString(),
      );
    }
  }
}
