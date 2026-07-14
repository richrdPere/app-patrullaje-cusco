// ignore_for_file: non_constant_identifier_names, unnecessary_this
import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class HistorialPatrullajeService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/historial';

  String get API_REGISTRAR_HISTORIAL => API_BASE;

  String get API_CREATE_HISTORIAL => '$API_BASE/crear';

  String API_GET_HISTORIAL_PATRULLAJE(int patrullajeId) =>
      '$API_BASE/patrullaje/$patrullajeId';

  String API_GET_DETALLE_HISTORIAL(int historialId) =>
      '$API_BASE/detalle/$historialId';

  String API_UPDATE_HISTORIAL(int historialId) =>
      '$API_BASE/editar/$historialId';

  String API_ARCHIVAR_HISTORIAL(int historialId) =>
      '$API_BASE/archivar/$historialId';

  // Helpers
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
      message:
          body['message']?.toString() ??
          body['msg']?.toString() ??
          'Ocurrió un error.',
      error: body['error']?.toString(),
      statusCode: statusCode,
    );
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // *********************************************************
  // 1. REGISTRAR HISTORIAL
  // *********************************************************
  Future<Resource<HistorialPatrullajeModel>> registerHistorial({
    required HistorialPatrullajeRequest historial,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
      final url = Uri.parse(API_CREATE_HISTORIAL);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(historial.toCreateJson()),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];

        if (data is! Map) {
          return ErrorData<HistorialPatrullajeModel>(
            message:
                'La respuesta del servidor no contiene un historial válido.',
          );
        }

        return Success<HistorialPatrullajeModel>(
          HistorialPatrullajeModel.fromJson(Map<String, dynamic>.from(data)),
        );
      }

      return _buildError<HistorialPatrullajeModel>(body, response.statusCode);
    } catch (error) {
      return ErrorData<HistorialPatrullajeModel>(
        message: 'Error al registrar historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER HISTORIAL POR PATRULLAJE
  // *********************************************************
  Future<Resource<List<HistorialPatrullajeModel>>> getHistorialByPatrullaje({
    required int patrullajeId,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
      final url = Uri.parse(API_GET_HISTORIAL_PATRULLAJE(patrullajeId));

      final response = await http.get(url, headers: headers);

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final List<dynamic> historialJson = body['data'] is List
            ? body['data'] as List<dynamic>
            : [];

        final historial = historialJson
            .map(
              (item) => HistorialPatrullajeModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        return Success<List<HistorialPatrullajeModel>>(historial);
      }

      return _buildError<List<HistorialPatrullajeModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<List<HistorialPatrullajeModel>>(
        message: 'Error al obtener historial por patrullaje.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER DETALLE DEL HISTORIAL
  // *********************************************************
  Future<Resource<HistorialPatrullajeModel>> getHistorialById({
    required int historialId,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
      final url = Uri.parse(API_GET_DETALLE_HISTORIAL(historialId));

      final response = await http.get(url, headers: headers);

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'] ?? body['historial'];

        return Success<HistorialPatrullajeModel>(
          HistorialPatrullajeModel.fromJson(data),
        );
      }

      return _buildError<HistorialPatrullajeModel>(body, response.statusCode);
    } catch (error) {
      return ErrorData<HistorialPatrullajeModel>(
        message: 'Error al obtener detalle del historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. EDITAR HISTORIAL
  // *********************************************************
  Future<Resource<HistorialPatrullajeModel>> updateHistorial({
    required int idHistorial,
    required HistorialPatrullajeRequest historial,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
      final url = Uri.parse(API_UPDATE_HISTORIAL(idHistorial));

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(historial.toUpdateJson()),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];

        if (data is! Map) {
          return ErrorData<HistorialPatrullajeModel>(
            message:
                'La respuesta del servidor no contiene un historial válido.',
          );
        }

        return Success<HistorialPatrullajeModel>(
          HistorialPatrullajeModel.fromJson(Map<String, dynamic>.from(data)),
        );
      }

      return _buildError<HistorialPatrullajeModel>(body, response.statusCode);
    } catch (error) {
      return ErrorData<HistorialPatrullajeModel>(
        message: 'Error al editar historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. ARCHIVAR HISTORIAL
  // *********************************************************
  Future<Resource<bool>> archivedHistorial({
    required int historialId,
    required String token,
  }) async {
    try {
      final headers = _getHeaders(token);
      final url = Uri.parse(API_ARCHIVAR_HISTORIAL(historialId));

      final response = await http.patch(url, headers: headers);

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, response.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al archivar historial.',
        error: error.toString(),
      );
    }
  }
}
