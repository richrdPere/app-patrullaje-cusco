// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;
import 'package:sis_patrullaje_cusco/src/data/models/incidencia/register_incidencia_req.dart';

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
  // VALIDAR REQUEST
  // =====================================================
  String? _validateRegisterRequest(RegisterIncidenciaRequest request) {
    if (request.patrullajeId <= 0) {
      return 'No existe un patrullaje activo válido.';
    }

    final tipo = request.tipo.trim().toUpperCase();

    const tiposValidos = {
      'ROBO',
      'ACCIDENTE',
      'INCENDIO',
      'VIOLENCIA',
      'SOSPECHOSO',
      'OTRO',
    };

    if (!tiposValidos.contains(tipo)) {
      return 'El tipo de incidencia no es válido.';
    }

    if (request.descripcion.trim().isEmpty) {
      return 'La descripción es obligatoria.';
    }

    if (request.latitud < -90 || request.latitud > 90) {
      return 'La latitud no es válida.';
    }

    if (request.longitud < -180 || request.longitud > 180) {
      return 'La longitud no es válida.';
    }

    if (request.archivos.length > 5) {
      return 'Solo se permiten hasta 5 archivos.';
    }

    for (final file in request.archivos) {
      final extension = _getExtension(file.path);

      const extensionesPermitidas = {
        'jpg',
        'jpeg',
        'png',
        'heic',
        'heif',
        'mp4',
        'mov',
      };

      if (!extensionesPermitidas.contains(extension)) {
        return 'El archivo ${file.path.split(Platform.pathSeparator).last} '
            'no tiene un formato permitido.';
      }
    }

    return null;
  }

  String _getExtension(String filePath) {
    final segments = filePath.split('.');

    if (segments.length < 2) {
      return '';
    }

    return segments.last.trim().toLowerCase();
  }

  // =====================================================
  // 1. REGISTRAR INCIDENCIA
  // =====================================================
  Future<Resource<IncidenteModel>> registerIncidencia({
    required RegisterIncidenciaRequest requestData,
    required String token,
  }) async {
    try {
      // =================================================
      // VALIDACIONES LOCALES
      // =================================================
      final validationError = _validateRegisterRequest(requestData);

      if (validationError != null) {
        return ErrorData<IncidenteModel>(
          message: validationError,
          statusCode: 400,
        );
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API_CREATE_INCIDENCIA),
      );

      request.headers.addAll(_getAuthHeaders(token));
      request.fields.addAll(requestData.toFields());

      // =================================================
      // ADJUNTAR ARCHIVOS
      // =================================================
      for (final file in requestData.archivos) {
        if (!file.existsSync()) {
          return ErrorData<IncidenteModel>(
            message: 'No se encontró uno de los archivos seleccionados.',
            error: file.path,
            statusCode: 400,
          );
        }

        request.files.add(
          await http.MultipartFile.fromPath('archivos', file.path),
        );
      }

      // =================================================
      // ENVIAR PETICIÓN
      // =================================================
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeResponse(response);

      if (!_isSuccess(response.statusCode)) {
        return _buildError<IncidenteModel>(body, response.statusCode);
      }

      // =================================================
      // VALIDAR RESPUESTA
      // =================================================
      final rawData = body['data'];

      if (rawData is! Map) {
        return ErrorData<IncidenteModel>(
          message: 'La respuesta del servidor no contiene datos válidos.',
          statusCode: response.statusCode,
        );
      }

      final data = Map<String, dynamic>.from(rawData);
      final rawIncidencia = data['incidencia'];

      if (rawIncidencia is! Map) {
        return ErrorData<IncidenteModel>(
          message: 'No se recibió la incidencia registrada.',
          statusCode: response.statusCode,
        );
      }

      final incidenciaJson = Map<String, dynamic>.from(rawIncidencia);

      // El backend devuelve los archivos separados.
      incidenciaJson['archivos'] = data['archivos'] is List
          ? data['archivos']
          : <dynamic>[];

      return Success<IncidenteModel>(IncidenteModel.fromJson(incidenciaJson));
    } on SocketException catch (error) {
      return ErrorData<IncidenteModel>(
        message: 'No se pudo conectar con el servidor.',
        error: error.toString(),
      );
    } on FormatException catch (error) {
      return ErrorData<IncidenteModel>(
        message: 'La respuesta recibida no tiene un formato válido.',
        error: error.toString(),
      );
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
