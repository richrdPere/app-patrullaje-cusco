import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class FcmTokenService {
  // ============================================================
  // ENDPOINTS
  // ============================================================

  String get API_BASE => '${url_backend.Environment.mainUrl}/alertas';

  String get API_REGISTER_DISPOSITIVO => '$API_BASE/dispositivo/register';

  String get API_DESACTIVAR_DISPOSITIVO => '$API_BASE/dispositivo/desactivar';

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

  String _getPlataforma() {
    if (kIsWeb) {
      return 'WEB';
    }

    if (Platform.isIOS) {
      return 'IOS';
    }

    return 'ANDROID';
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{};
  }

  // ============================================================
  // 1. REGISTRAR O ACTUALIZAR DISPOSITIVO
  // ============================================================
  Future<Resource<Map<String, dynamic>>> registrarActualizarToken({
    required String token,
    required String fcmToken,
    String? deviceId,
  }) async {
    try {
      if (token.trim().isEmpty) {
        return ErrorData<Map<String, dynamic>>(
          message: 'El token de autenticación es obligatorio.',
        );
      }

      if (fcmToken.trim().isEmpty) {
        return ErrorData<Map<String, dynamic>>(
          message: 'El token FCM es obligatorio.',
        );
      }

      final uri = Uri.parse(API_REGISTER_DISPOSITIVO);

      final response = await http.post(
        uri,
        headers: _getHeaders(token),
        body: jsonEncode({
          /*
           * Deben coincidir exactamente con los campos
           * esperados por registerDispositivoService.
           */
          'token_fcm': fcmToken.trim(),
          'device_id': deviceId?.trim(),
          'plataforma': _getPlataforma(),
        }),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<Map<String, dynamic>>(_extractData(body));
      }

      return _buildError<Map<String, dynamic>>(body, response.statusCode);
    } catch (error) {
      return ErrorData<Map<String, dynamic>>(
        message: 'No se pudo registrar el dispositivo.',
        error: error.toString(),
      );
    }
  }

  // ============================================================
  // 2. DESACTIVAR DISPOSITIVO
  // ============================================================
  Future<Resource<Map<String, dynamic>>> desactivarToken({
    required String token,
    required String fcmToken,
    String? deviceId,
  }) async {
    try {
      if (token.trim().isEmpty) {
        return ErrorData<Map<String, dynamic>>(
          message: 'El token de autenticación es obligatorio.',
        );
      }

      if (fcmToken.trim().isEmpty &&
          (deviceId == null || deviceId.trim().isEmpty)) {
        return ErrorData<Map<String, dynamic>>(
          message:
              'Debe proporcionar el token FCM o el identificador del dispositivo.',
        );
      }

      final uri = Uri.parse(API_DESACTIVAR_DISPOSITIVO);

      final bodyRequest = <String, dynamic>{
        if (fcmToken.trim().isNotEmpty) 'token_fcm': fcmToken.trim(),

        if (deviceId != null && deviceId.trim().isNotEmpty)
          'device_id': deviceId.trim(),
      };

      final response = await http.patch(
        uri,
        headers: _getHeaders(token),
        body: jsonEncode(bodyRequest),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<Map<String, dynamic>>(_extractData(body));
      }

      return _buildError<Map<String, dynamic>>(body, response.statusCode);
    } catch (error) {
      return ErrorData<Map<String, dynamic>>(
        message: 'No se pudo desactivar el dispositivo.',
        error: error.toString(),
      );
    }
  }
}
