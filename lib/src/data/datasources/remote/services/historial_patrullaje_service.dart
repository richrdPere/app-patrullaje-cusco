// ignore_for_file: non_constant_identifier_names, unnecessary_this
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/helpers/http_service_helper.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class HistorialPatrullajeService {
  // APIS
  String get API_BASE => '${url_backend.Environment.mainUrl}/historial';

  String get API_CREATE_HISTORIAL => '$API_BASE/crear';
  String get API_CREATE_OBSERVACION_HISTORIAL => '$API_BASE/create-observacion';
  String get API_HISTORIAL_SIGUIENTE_TURNO => '$API_BASE/siguiente-turno';

  String API_GET_HISTORIAL_PATRULLAJE(int patrullajeId) =>
      '$API_BASE/patrullaje/$patrullajeId';

  String API_GET_DETALLE_HISTORIAL(int historialId) =>
      '$API_BASE/detalle/$historialId';

  String API_CONTEXTO_ZONA(int zonaId) => '$API_BASE/contexto-zona/$zonaId';

  String API_UPDATE_HISTORIAL(int historialId) =>
      '$API_BASE/editar/$historialId';

  String API_ARCHIVAR_HISTORIAL(int historialId) =>
      '$API_BASE/archivar/$historialId';

  // *********************************************************
  // 1. CREAR HISTORIAL
  // *********************************************************
  Future<Resource<ApiResponse<HistorialData>>> createHistorial({
    required CreateHistorialRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_CREATE_HISTORIAL);

      // 2. PETICIÓN HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<HistorialData>.fromJson(
          body,
          (rawData) =>
              HistorialData.fromJson(Map<String, dynamic>.from(rawData as Map)),
        );

        return Success<ApiResponse<HistorialData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<HistorialData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<HistorialData>>(
        message: 'Ocurrió un error al registrar el historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER HISTORIAL POR PATRULLAJE
  // *********************************************************
  Future<Resource<ApiResponse<List<HistorialPatrullajeData>>>>
  getHistorialByPatrullaje({
    required int patrullajeId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_HISTORIAL_PATRULLAJE(patrullajeId));

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<List<HistorialPatrullajeData>>.fromJson(
          body,
          (rawData) {
            if (rawData is! List) {
              return <HistorialPatrullajeData>[];
            }

            return rawData
                .whereType<Map>()
                .map(
                  (item) => HistorialPatrullajeData.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList();
          },
        );

        return Success<ApiResponse<List<HistorialPatrullajeData>>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<List<HistorialPatrullajeData>>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<List<HistorialPatrullajeData>>>(
        message: 'Ocurrió un error al obtener el historial del patrullaje.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER HISTORIAL POR ID
  // *********************************************************
  Future<Resource<ApiResponse<HistorialDetalleData>>> getHistorialById({
    required int historialId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_GET_DETALLE_HISTORIAL(historialId));

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<HistorialDetalleData>.fromJson(
          body,
          (rawData) => HistorialDetalleData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<HistorialDetalleData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<HistorialDetalleData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<HistorialDetalleData>>(
        message: 'Ocurrió un error al obtener el historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. CREAR OBSERVACIÓN CON ARCHIVOS
  // *********************************************************
  Future<Resource<ApiResponse<HistorialData>>> createObservacionConArchivos({
    required CreateHistorialRequest request,
    required List<File> archivos,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_CREATE_OBSERVACION_HISTORIAL);

      // 2. CREAR PETICIÓN MULTIPART
      final multipartRequest = http.MultipartRequest('POST', uri);

      multipartRequest.headers.addAll(
        HttpServiceHelper.getMultipartHeaders(token: token),
      );

      // 3. AGREGAR CAMPOS
      multipartRequest.fields.addAll({
        'patrullaje_id': request.patrullajeId.toString(),

        if (request.incidenciaId != null)
          'incidencia_id': request.incidenciaId.toString(),

        'tipo': request.tipo.value,

        'titulo': request.titulo.trim(),

        'descripcion': request.descripcion.trim(),

        'prioridad': request.prioridad.value,

        if (request.latitud != null) 'latitud': request.latitud.toString(),

        if (request.longitud != null) 'longitud': request.longitud.toString(),

        'visible_para_siguiente_turno': request.visibleParaSiguienteTurno
            .toString(),
      });

      // 4. VALIDAR Y AGREGAR ARCHIVOS
      for (final archivo in archivos) {
        final existe = await archivo.exists();

        if (!existe) {
          return ErrorData<ApiResponse<HistorialData>>(
            message: 'Uno de los archivos seleccionados no existe.',
            error: archivo.path,
            statusCode: 400,
          );
        }

        if (!HttpServiceHelper.isAllowedMediaFile(archivo.path)) {
          return ErrorData<ApiResponse<HistorialData>>(
            message:
                'El archivo ${path.basename(archivo.path)} no tiene un formato permitido.',
            statusCode: 400,
          );
        }

        final mediaType = HttpServiceHelper.getMediaType(archivo.path);

        final multipartFile = await http.MultipartFile.fromPath(
          'archivos',
          archivo.path,
          filename: path.basename(archivo.path),
          contentType: mediaType,
        );

        multipartRequest.files.add(multipartFile);
      }

      // 5. ENVIAR PETICIÓN
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      final body = HttpServiceHelper.decodeResponse(response);

      // 6. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<HistorialData>.fromJson(
          body,
          (rawData) =>
              HistorialData.fromJson(Map<String, dynamic>.from(rawData as Map)),
        );

        return Success<ApiResponse<HistorialData>>(apiResponse);
      }

      // 7. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<HistorialData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<HistorialData>>(
        message: 'Ocurrió un error al registrar la observación.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. OBTENER CONTEXTO OPERATIVO DE UNA ZONA
  // *********************************************************
  Future<Resource<ApiResponse<ContextoZonaData>>> getContextoZona({
    required int zonaId,
    required ContextoZonaQueryParams params,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final baseUri = Uri.parse(API_CONTEXTO_ZONA(zonaId));

      final uri = baseUri.replace(queryParameters: params.toQueryParameters());

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<ContextoZonaData>.fromJson(
          body,
          (rawData) => ContextoZonaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<ContextoZonaData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<ContextoZonaData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<ContextoZonaData>>(
        message:
            'Ocurrió un error al obtener el contexto operativo de la zona.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. OBTENER INFORMACIÓN PARA EL SIGUIENTE TURNO
  // *********************************************************
  Future<Resource<ApiResponse<SiguienteTurnoData>>> getParaSiguienteTurno({
    required SiguienteTurnoQueryParams params,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final baseUri = Uri.parse(API_HISTORIAL_SIGUIENTE_TURNO);

      final uri = baseUri.replace(queryParameters: params.toQueryParameters());

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<SiguienteTurnoData>.fromJson(
          body,
          (rawData) => SiguienteTurnoData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<SiguienteTurnoData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<SiguienteTurnoData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<SiguienteTurnoData>>(
        message:
            'Ocurrió un error al obtener la información del turno anterior.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. ACTUALIZAR HISTORIAL
  // *********************************************************
  Future<Resource<ApiResponse<HistorialData>>> updateHistorial({
    required int historialId,
    required CreateHistorialRequest request,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_UPDATE_HISTORIAL(historialId));

      // 2. PETICIÓN HTTP
      final response = await http
          .put(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<HistorialData>.fromJson(
          body,
          (rawData) =>
              HistorialData.fromJson(Map<String, dynamic>.from(rawData as Map)),
        );

        return Success<ApiResponse<HistorialData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<HistorialData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<HistorialData>>(
        message: 'Ocurrió un error al actualizar el historial.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 8. ARCHIVAR HISTORIAL
  // *********************************************************
  Future<Resource<ApiResponse<HistorialData>>> archiveHistorial({
    required int historialId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_ARCHIVAR_HISTORIAL(historialId));

      // 2. PETICIÓN HTTP
      final response = await http
          .patch(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<HistorialData>.fromJson(
          body,
          (rawData) =>
              HistorialData.fromJson(Map<String, dynamic>.from(rawData as Map)),
        );

        return Success<ApiResponse<HistorialData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<HistorialData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<HistorialData>>(
        message: 'Ocurrió un error al archivar el historial.',
        error: error.toString(),
      );
    }
  }
}
