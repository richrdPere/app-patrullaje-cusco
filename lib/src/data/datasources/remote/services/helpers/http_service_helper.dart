import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class HttpServiceHelper {
  const HttpServiceHelper._();

  // ***********************************************************
  // 1. GET HEARDES
  // ***********************************************************
  static Map<String, String> getHeaders({
    String? token,
    Map<String, String>? extraHeaders,
  }) {
    final normalizedToken = token?.trim();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      if (normalizedToken != null && normalizedToken.isNotEmpty)
        'Authorization': 'Bearer $normalizedToken',

      ...?extraHeaders,
    };
  }

  // ***********************************************************
  // 2. DECODE RESPONSE
  // ***********************************************************
  static Map<String, dynamic> decodeResponse(http.Response response) {
    try {
      final rawBody = response.body.trim();

      if (rawBody.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor devolvió una respuesta vacía.',
        };
      }

      final decoded = jsonDecode(rawBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {
        'success': false,
        'message': 'La respuesta del servidor no tiene un formato válido.',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'No se pudo interpretar la respuesta del servidor.',
        'error': error.toString(),
      };
    }
  }

  // ***********************************************************
  // 3. BUILD ERROR
  // ***********************************************************
  static ErrorData<T> buildError<T>(Map<String, dynamic> body, int statusCode) {
    final message = body['message']?.toString().trim();
    final error = body['error']?.toString().trim();

    return ErrorData<T>(
      message: message != null && message.isNotEmpty
          ? message
          : getDefaultErrorMessage(statusCode),
      error: error != null && error.isNotEmpty ? error : null,
      statusCode: statusCode,
    );
  }

  // ***********************************************************
  // 4. IS SUCCESS
  // ***********************************************************
  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // ***********************************************************
  // 5. GET DEFAULT ERRORES
  // ***********************************************************
  static String getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Los datos enviados no son válidos.';

      case 401:
        return 'La sesión ha expirado o no está autorizada.';

      case 403:
        return 'No tienes permisos para realizar esta acción.';

      case 404:
        return 'No se encontró el recurso solicitado.';

      case 409:
        return 'Ya existe un registro con los datos enviados.';

      case 422:
        return 'No se pudieron procesar los datos enviados.';

      case 500:
        return 'Ocurrió un error interno en el servidor.';

      case 502:
        return 'El servidor no pudo comunicarse con otro servicio.';

      case 503:
        return 'El servicio no se encuentra disponible temporalmente.';

      default:
        return 'Ocurrió un error al procesar la solicitud.';
    }
  }
}
