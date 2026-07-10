// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class IncidenciaService {

  // API
  String get API_BASE => '${url_backend.Environment.mainUrl}/incidencias';

  String get API_CREATE_INCIDENCIA => '$API_BASE/crear';
  String get API_MIS_INCIDENCIAS => '$API_BASE/mis-incidencias';
  String get API_INCIDENCIAS_CERCANAS => '$API_BASE/cercanas';

  String API_DETALLE_INCIDENCIA(int id) => '$API_BASE/detalle/$id';
  String API_ARCHIVOS_INCIDENCIA(int id) => '$API_BASE/$id/archivos';
  String API_AGREGAR_ARCHIVOS(int id) => '$API_BASE/$id/archivos';

  String API_ELIMINAR_ARCHIVO({
    required int incidenciaId,
    required int archivoId,
  }) => '$API_BASE/$incidenciaId/archivos/$archivoId';

  // Helpers
  Map<String, String> _getAuthHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, String> _getJsonHeaders(String token) {
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

  // =====================================================
  // 1. REGISTRAR INCIDENCIA
  // =====================================================
  Future<Resource<IncidenteModel>> registerIncidencia({
    required IncidenteModel incidencia,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API_CREATE_INCIDENCIA),
      );

      request.headers.addAll(_getAuthHeaders(token));

      request.fields['tipo'] = incidencia.tipo;
      request.fields['descripcion'] = incidencia.descripcion;
      request.fields['latitud'] = incidencia.latitud.toString();
      request.fields['longitud'] = incidencia.longitud.toString();
      request.fields['origen'] = incidencia.origen;

      if (incidencia.patrullajeId != null) {
        request.fields['patrullaje_id'] = incidencia.patrullajeId.toString();
      }

      if (incidencia.archivos != null && incidencia.archivos!.isNotEmpty) {
        for (final file in incidencia.archivos!) {
          if (!file.existsSync()) continue;

          request.files.add(
            await http.MultipartFile.fromPath('archivos', file.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];

        final incidenciaJson = data is Map<String, dynamic>
            ? data['incidencia'] ?? data
            : body['incidencia'];

        return Success<IncidenteModel>(IncidenteModel.fromJson(incidenciaJson));
      }

      return _buildError<IncidenteModel>(body, response.statusCode);
    } catch (error) {
      return ErrorData<IncidenteModel>(
        message: 'Error al registrar incidencia.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 2. MIS INCIDENCIAS
  // =====================================================
  Future<Resource<List<IncidenteModel>>> getMisIncidencias({
    required String token,
    int page = 1,
    int limit = 10,
    String incluirArchivos = 'false',
  }) async {
    try {
      final uri = Uri.parse(API_MIS_INCIDENCIAS).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'mode': 'app',
          'incluir_archivos': incluirArchivos,
        },
      );

      final response = await http.get(uri, headers: _getJsonHeaders(token));

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];
        final List list = data?['data'] ?? [];

        final incidencias = list
            .map((e) => IncidenteModel.fromJson(e))
            .toList();

        return Success<List<IncidenteModel>>(incidencias);
      }

      return _buildError<List<IncidenteModel>>(body, response.statusCode);
    } catch (error) {
      return ErrorData<List<IncidenteModel>>(
        message: 'Error al obtener mis incidencias.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 3. DETALLE DE INCIDENCIA
  // =====================================================
  Future<Resource<IncidenteModel>> getIncidenciaById({
    required int incidenciaId,
    required String token,
    String mode = 'app',
  }) async {
    try {
      final uri = Uri.parse(
        API_DETALLE_INCIDENCIA(incidenciaId),
      ).replace(queryParameters: {'mode': mode});

      final response = await http.get(uri, headers: _getJsonHeaders(token));

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<IncidenteModel>(IncidenteModel.fromJson(body['data']));
      }

      return _buildError<IncidenteModel>(body, response.statusCode);
    } catch (error) {
      return ErrorData<IncidenteModel>(
        message: 'Error al obtener incidencia.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 4. OBTENER ARCHIVOS DE INCIDENCIA
  // =====================================================
  Future<Resource<List<IncidenciaArchivoModel>>> getArchivosIncidencia({
    required int incidenciaId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(API_ARCHIVOS_INCIDENCIA(incidenciaId)),
        headers: _getJsonHeaders(token),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];
        final List list = data?['data'] ?? [];

        final archivos = list
            .map((e) => IncidenciaArchivoModel.fromJson(e))
            .toList();

        return Success<List<IncidenciaArchivoModel>>(archivos);
      }

      return _buildError<List<IncidenciaArchivoModel>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<List<IncidenciaArchivoModel>>(
        message: 'Error al obtener archivos de incidencia.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 5. AGREGAR ARCHIVOS A INCIDENCIA
  // =====================================================
  Future<Resource<bool>> agregarArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API_AGREGAR_ARCHIVOS(incidenciaId)),
      );

      request.headers.addAll(_getAuthHeaders(token));

      for (final archivo in archivos) {
        if (!archivo.existsSync()) continue;

        request.files.add(
          await http.MultipartFile.fromPath('archivos', archivo.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, response.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al agregar archivos a la incidencia.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 6. ELIMINAR ARCHIVO DE INCIDENCIA
  // =====================================================
  Future<Resource<bool>> eliminarArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(
          API_ELIMINAR_ARCHIVO(
            incidenciaId: incidenciaId,
            archivoId: archivoId,
          ),
        ),
        headers: _getJsonHeaders(token),
      );

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        return Success<bool>(true);
      }

      return _buildError<bool>(body, response.statusCode);
    } catch (error) {
      return ErrorData<bool>(
        message: 'Error al eliminar archivo de incidencia.',
        error: error.toString(),
      );
    }
  }

  // =====================================================
  // 7. INCIDENCIAS CERCANAS
  // =====================================================
  Future<Resource<List<IncidenteModel>>> getIncidenciasCercanas({
    required double latitud,
    required double longitud,
    required String token,
    double radio = 500,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(API_INCIDENCIAS_CERCANAS).replace(
        queryParameters: {
          'latitud': latitud.toString(),
          'longitud': longitud.toString(),
          'radio': radio.toString(),
          'limit': limit.toString(),
          'mode': 'app',
        },
      );

      final response = await http.get(uri, headers: _getJsonHeaders(token));

      final body = _decodeResponse(response);

      if (_isSuccess(response.statusCode)) {
        final data = body['data'];
        final List list = data?['data'] ?? [];

        final incidencias = list
            .map((e) => IncidenteModel.fromJson(e))
            .toList();

        return Success<List<IncidenteModel>>(incidencias);
      }

      return _buildError<List<IncidenteModel>>(body, response.statusCode);
    } catch (error) {
      return ErrorData<List<IncidenteModel>>(
        message: 'Error al obtener incidencias cercanas.',
        error: error.toString(),
      );
    }
  }
}
