// ignore_for_file: non_constant_identifier_names

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

class IncidenciaService {
  // API
  String get API_BASE => '${url_backend.Environment.mainUrl}/incidencias';

  String get API_CREATE_INCIDENCIA => '$API_BASE/crear';
  String get API_GET_MIS_INCIDENCIAS_PAGINADO => '$API_BASE/mis-incidencias';
  String get API_INCIDENCIAS_CERCANAS => '$API_BASE/cercanas';

  String API_DETALLE_INCIDENCIA(int id) => '$API_BASE/detalle/$id';
  String API_ARCHIVOS_INCIDENCIA(int id) => '$API_BASE/$id/archivos';
  String API_AGREGAR_ARCHIVOS(int id) => '$API_BASE/$id/archivos';

  String API_ELIMINAR_ARCHIVO({
    required int incidenciaId,
    required int archivoId,
  }) => '$API_BASE/$incidenciaId/archivos/$archivoId';

  String API_INCIDENCIAS_PATRULLAJE(int patrullajeId) =>
      '$API_BASE/patrullaje/$patrullajeId';

  String API_INCIDENCIAS_ZONA(int zonaId) => '$API_BASE/zona/$zonaId';

  // *********************************************************
  // 1. REGISTRAR INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<RegisterIncidenciaData>>> registerIncidencia({
    required RegisterIncidenciaRequest requestData,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR MULTIPART REQUEST
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API_CREATE_INCIDENCIA),
      );

      // - Obtener el header multipart
      request.headers.addAll(
        HttpServiceHelper.getMultipartHeaders(token: token),
      );

      // - Campos de texto del formulario.
      request.fields.addAll(requestData.toFields());

      // 2. ADJUNTAR ARCHIVOS
      for (final file in requestData.archivos) {
        // Validar existencia.
        if (!await file.exists()) {
          return ErrorData<ApiResponse<RegisterIncidenciaData>>(
            message: 'No se encontró uno de los archivos seleccionados.',
            error: file.path,
            statusCode: 400,
          );
        }

        // Validar extensión y tipo soportado.
        final isAllowedFile = HttpServiceHelper.isAllowedMediaFile(file.path);

        if (!isAllowedFile) {
          final extension = HttpServiceHelper.getExtension(file.path);

          return ErrorData<ApiResponse<RegisterIncidenciaData>>(
            message:
                'El archivo ${path.basename(file.path)} '
                'no tiene un formato permitido.',
            error: extension.isEmpty
                ? 'El archivo no tiene extensión.'
                : 'Extensión no permitida: .$extension',
            statusCode: 400,
          );
        }

        // Obtener el MIME correspondiente.
        final contentType = HttpServiceHelper.getMediaType(file.path);

        if (contentType == null) {
          return ErrorData<ApiResponse<RegisterIncidenciaData>>(
            message: 'No se pudo determinar el tipo del archivo.',
            error: file.path,
            statusCode: 400,
          );
        }

        // Construir archivo multipart.
        final multipartFile = await http.MultipartFile.fromPath(
          'archivos',
          file.path,
          filename: path.basename(file.path),
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      // 3. ENVIAR PETICIÓN
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<RegisterIncidenciaData>.fromJson(
          body,
          (rawData) => RegisterIncidenciaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<RegisterIncidenciaData>>(apiResponse);
      }

      // 5. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<RegisterIncidenciaData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<RegisterIncidenciaData>>(
        message: 'Ocurrió un error al registrar la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2. OBTENER MIS INCIDENCIAS
  // *********************************************************
  Future<Resource<ApiResponse<MisIncidenciasPaginated>>>
  getMisIncidenciasPaginadas({
    required String token,
    required MisIncidenciasQueryParams params,
  }) async {
    try {
      // 1.- Construir URL y query parameters
      final uri = Uri.parse(
        API_GET_MIS_INCIDENCIAS_PAGINADO,
      ).replace(queryParameters: params.toQueryParameters());

      // 2.- Realizar petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      // 3.- Decodificar respuesta
      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Respuesta correcta
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<MisIncidenciasPaginated>.fromJson(
          body,
          (rawData) => MisIncidenciasPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<MisIncidenciasPaginated>>(apiResponse);
      }

      // 5.- Respuesta de error del backend
      return HttpServiceHelper.buildError<ApiResponse<MisIncidenciasPaginated>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<MisIncidenciasPaginated>>(
        message: 'Ocurrió un error al obtener tus incidencias.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3. OBTENER INCIDENCIA POR ID
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciaDetalleData>>> getIncidenciaById({
    required int incidenciaId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_DETALLE_INCIDENCIA(incidenciaId));

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<IncidenciaDetalleData>.fromJson(
          body,
          (rawData) => IncidenciaDetalleData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<IncidenciaDetalleData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<IncidenciaDetalleData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciaDetalleData>>(
        message: 'Ocurrió un error al obtener la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4. OBTENER ARCHIVOS DE UNA INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciaArchivosData>>>
  getArchivosByIncidencia({
    required int incidenciaId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(API_ARCHIVOS_INCIDENCIA(incidenciaId));

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<IncidenciaArchivosData>.fromJson(
          body,
          (rawData) => IncidenciaArchivosData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<IncidenciaArchivosData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<IncidenciaArchivosData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciaArchivosData>>(
        message: 'Ocurrió un error al obtener los archivos de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5. AGREGAR ARCHIVOS A INCIDENCIA
  // *********************************************************
  Future<Resource<ApiResponse<AgregarArchivosIncidenciaData>>>
  agregarArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR MULTIPART REQUEST
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(API_AGREGAR_ARCHIVOS(incidenciaId)),
      );

      request.headers.addAll(
        HttpServiceHelper.getMultipartHeaders(token: token),
      );

      // 2. VALIDAR Y ADJUNTAR ARCHIVOS
      for (final archivo in archivos) {
        final existe = await archivo.exists();

        if (!existe) {
          return ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
            message: 'No se encontró uno de los archivos seleccionados.',
            error: archivo.path,
            statusCode: 400,
          );
        }

        final permitido = HttpServiceHelper.isAllowedMediaFile(archivo.path);

        if (!permitido) {
          final extension = HttpServiceHelper.getExtension(archivo.path);

          return ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
            message:
                'El archivo ${path.basename(archivo.path)} '
                'no tiene un formato permitido.',
            error: extension.isEmpty
                ? 'El archivo no tiene extensión.'
                : 'Extensión no permitida: .$extension',
            statusCode: 400,
          );
        }

        final contentType = HttpServiceHelper.getMediaType(archivo.path);

        if (contentType == null) {
          return ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
            message: 'No se pudo determinar el tipo del archivo.',
            error: archivo.path,
            statusCode: 400,
          );
        }

        final multipartFile = await http.MultipartFile.fromPath(
          'archivos',
          archivo.path,
          filename: path.basename(archivo.path),
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      // 3. ENVIAR PETICIÓN
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(streamedResponse);

      final body = HttpServiceHelper.decodeResponse(response);

      // 4. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<AgregarArchivosIncidenciaData>.fromJson(
          body,
          (rawData) => AgregarArchivosIncidenciaData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<AgregarArchivosIncidenciaData>>(apiResponse);
      }

      // 5. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<AgregarArchivosIncidenciaData>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<AgregarArchivosIncidenciaData>>(
        message: 'Ocurrió un error al agregar los archivos.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 6. ELIMINAR ARCHIVO DE INCIDENCIA
  // *********************************************************
  Future<Resource<void>> eliminarArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        API_ELIMINAR_ARCHIVO(incidenciaId: incidenciaId, archivoId: archivoId),
      );

      // 2. PETICIÓN HTTP
      final response = await http
          .delete(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        return Success<bool>(true);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<bool>(body, response.statusCode);
    } on SocketException catch (error) {
      return ErrorData<bool>(
        message: 'No se pudo conectar con el servidor.',
        error: error.toString(),
      );
    } catch (error) {
      return ErrorData<bool>(
        message: 'Ocurrió un error al eliminar el archivo de la incidencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 7. OBTENER INCIDENCIAS CERCANAS
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciasCercanasData>>>
  getIncidenciasCercanas({
    required IncidenciasCercanasQueryParams params,
    required String token,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        API_INCIDENCIAS_CERCANAS,
      ).replace(queryParameters: params.toQueryParameters());

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<IncidenciasCercanasData>.fromJson(
          body,
          (rawData) => IncidenciasCercanasData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<IncidenciasCercanasData>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<ApiResponse<IncidenciasCercanasData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciasCercanasData>>(
        message: 'Ocurrió un error al obtener las incidencias cercanas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 8. OBTENER INCIDENCIAS POR PATRULLAJE
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciasPatrullajePaginated>>>
  getIncidenciasByPatrullaje({
    required String token,
    required int patrullajeId,
    required IncidenciasPatrullajeQueryParams params,
  }) async {
    try {
      // 1. CONSTRUIR URL

      final uri = Uri.parse(
        API_INCIDENCIAS_PATRULLAJE(patrullajeId),
      ).replace(queryParameters: params.toQueryParameters());

      // 2. PETICIÓN HTTP

      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse =
            ApiResponse<IncidenciasPatrullajePaginated>.fromJson(
              body,
              (rawData) => IncidenciasPatrullajePaginated.fromJson(
                Map<String, dynamic>.from(rawData as Map),
              ),
            );

        return Success<ApiResponse<IncidenciasPatrullajePaginated>>(
          apiResponse,
        );
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<IncidenciasPatrullajePaginated>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciasPatrullajePaginated>>(
        message: 'No se pudieron obtener las incidencias del patrullaje.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 9. OBTENER INCIDENCIAS POR ZONA
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciasZonaPaginated>>> getIncidenciasByZona({
    required String token,
    required int zonaId,
    required IncidenciasZonaQueryParams params,
  }) async {
    try {
      // 1. CONSTRUIR URL
      final uri = Uri.parse(
        API_INCIDENCIAS_ZONA(zonaId),
      ).replace(queryParameters: params.toQueryParameters());

      // 2. PETICIÓN HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3. RESPUESTA EXITOSA
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<IncidenciasZonaPaginated>.fromJson(
          body,
          (rawData) => IncidenciasZonaPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<IncidenciasZonaPaginated>>(apiResponse);
      }

      // 4. RESPUESTA DE ERROR
      return HttpServiceHelper.buildError<
        ApiResponse<IncidenciasZonaPaginated>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciasZonaPaginated>>(
        message: 'No se pudieron obtener las incidencias de la zona.',
        error: error.toString(),
      );
    }
  }
}
