// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Helpers
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/helpers/http_Service_helper.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class OcurrenciaService {
  String get API_BASE => '${url_backend.Environment.mainUrl}/ocurrencias';

  String get API_POST_OCURRENCIA => '$API_BASE/create';
  String get API_GET_OCURRENCIAS_PAGINADO => '$API_BASE/paginado';
  String get API_GET_OCURRENCIAS_DETALLE => '$API_BASE/detalle/';
  String get API_GENERATE_OCURRENCIA_PDF => API_BASE;
  String get API_GET_INCIDENCIAS_SELECTOR_OCURRENCIA =>
      '$API_BASE/incidencias-selector';

  // *********************************************************
  // 1.- Crear ocurrencia
  // *********************************************************
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> createOcurrencia({
    required String token,
    required CreateOcurrenciaRequest request,
  }) async {
    try {
      // 1.- URL
      final uri = Uri.parse(API_POST_OCURRENCIA);

      // 2.- Petición HTTP
      final response = await http
          .post(
            uri,
            headers: HttpServiceHelper.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<OcurrenciaDetalleData>.fromJson(
          body,
          (rawData) => OcurrenciaDetalleData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<OcurrenciaDetalleData>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<ApiResponse<OcurrenciaDetalleData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<OcurrenciaDetalleData>>(
        message: 'Ocurrió un error al crear la ocurrencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 2.- Obtener ocurrencias paginadas
  // *********************************************************
  Future<Resource<ApiResponse<OcurrenciaPaginated>>> getOcurrenciasPaginado({
    required String token,
    required OcurrenciaQueryParams params,
  }) async {
    try {
      // 1.- URL + query params
      final uri = Uri.parse(
        API_GET_OCURRENCIAS_PAGINADO,
      ).replace(queryParameters: params.toQueryParameters());

      // 2.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<OcurrenciaPaginated>.fromJson(
          body,
          (rawData) => OcurrenciaPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<OcurrenciaPaginated>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<ApiResponse<OcurrenciaPaginated>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<OcurrenciaPaginated>>(
        message: 'Ocurrió un error al obtener las ocurrencias paginadas.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 3.- Obtener ocurrencia por ID
  // *********************************************************
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> getOcurrenciaById({
    required String token,
    required int ocurrenciaId,
  }) async {
    try {
      // 1.- Validar ID
      if (ocurrenciaId <= 0) {
        return ErrorData<ApiResponse<OcurrenciaDetalleData>>(
          message: 'El identificador de la ocurrencia no es válido.',
        );
      }

      // 2.- URL
      final uri = Uri.parse('$API_GET_OCURRENCIAS_DETALLE$ocurrenciaId');

      // 3.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 4.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<OcurrenciaDetalleData>.fromJson(
          body,
          (rawData) => OcurrenciaDetalleData.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<OcurrenciaDetalleData>>(apiResponse);
      }

      // 5.- Return Error
      return HttpServiceHelper.buildError<ApiResponse<OcurrenciaDetalleData>>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<ApiResponse<OcurrenciaDetalleData>>(
        message: 'Ocurrió un error al obtener el detalle de la ocurrencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 4.- Obtener PDF de la ocurrencia
  // *********************************************************
  Future<Resource<OcurrenciaPdfData>> getOcurrenciaPdf({
    required String token,
    required int ocurrenciaId,
  }) async {
    try {
      // 1.- Validar ID
      if (ocurrenciaId <= 0) {
        return ErrorData<OcurrenciaPdfData>(
          message: 'El identificador de la ocurrencia no es válido.',
        );
      }

      // 2.- URL
      final uri = Uri.parse(
        '$API_GENERATE_OCURRENCIA_PDF/$ocurrenciaId/formato',
      ).replace(queryParameters: const {'formato': 'pdf'});

      // 3.- Petición HTTP
      final response = await http
          .get(
            uri,
            headers: HttpServiceHelper.getHeaders(
              token: token,
              extraHeaders: const {'Accept': 'application/pdf'},
            ),
          )
          .timeout(const Duration(seconds: 60));

      // 4.- Respuesta exitosa
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final Uint8List pdfBytes = response.bodyBytes;

        if (pdfBytes.isEmpty) {
          return ErrorData<OcurrenciaPdfData>(
            message: 'El servidor devolvió un archivo PDF vacío.',
            statusCode: response.statusCode,
          );
        }

        final contentType =
            response.headers['content-type']
                ?.split(';')
                .first
                .trim()
                .toLowerCase() ??
            'application/pdf';

        if (contentType != 'application/pdf') {
          return ErrorData<OcurrenciaPdfData>(
            message: 'La respuesta recibida no corresponde a un archivo PDF.',
            error: 'Content-Type recibido: $contentType',
            statusCode: response.statusCode,
          );
        }

        final fileName = _getPdfFileName(
          contentDisposition: response.headers['content-disposition'],
          ocurrenciaId: ocurrenciaId,
        );

        final pdfData = OcurrenciaPdfData(
          bytes: pdfBytes,
          fileName: fileName,
          mimeType: contentType,
          size: pdfBytes.length,
        );

        return Success<OcurrenciaPdfData>(pdfData);
      }

      // 5.- Respuesta de error JSON
      final body = HttpServiceHelper.decodeResponse(response);

      return HttpServiceHelper.buildError<OcurrenciaPdfData>(
        body,
        response.statusCode,
      );
    } catch (error) {
      return ErrorData<OcurrenciaPdfData>(
        message: 'Ocurrió un error al generar el PDF de la ocurrencia.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // 5.- Obtener incidencias disponibles para una ocurrencia
  // *********************************************************
  Future<Resource<ApiResponse<IncidenciasSelectorPaginated>>>
  getIncidenciasSelector({
    required String token,
    required IncidenciasSelectorQueryParams params,
  }) async {
    try {
      // 1.- URL + query params
      final uri = Uri.parse(
        API_GET_INCIDENCIAS_SELECTOR_OCURRENCIA,
      ).replace(queryParameters: params.toQueryParameters());

      // 2.- Petición HTTP
      final response = await http
          .get(uri, headers: HttpServiceHelper.getHeaders(token: token))
          .timeout(const Duration(seconds: 30));

      final body = HttpServiceHelper.decodeResponse(response);

      // 3.- Return JSON
      if (HttpServiceHelper.isSuccess(response.statusCode)) {
        final apiResponse = ApiResponse<IncidenciasSelectorPaginated>.fromJson(
          body,
          (rawData) => IncidenciasSelectorPaginated.fromJson(
            Map<String, dynamic>.from(rawData as Map),
          ),
        );

        return Success<ApiResponse<IncidenciasSelectorPaginated>>(apiResponse);
      }

      // 4.- Return Error
      return HttpServiceHelper.buildError<
        ApiResponse<IncidenciasSelectorPaginated>
      >(body, response.statusCode);
    } catch (error) {
      return ErrorData<ApiResponse<IncidenciasSelectorPaginated>>(
        message: 'Ocurrió un error al obtener las incidencias disponibles.',
        error: error.toString(),
      );
    }
  }

  // *********************************************************
  // HELPER - Obtener nombre del PDF
  // *********************************************************
  String _getPdfFileName({
    required String? contentDisposition,
    required int ocurrenciaId,
  }) {
    if (contentDisposition == null || contentDisposition.trim().isEmpty) {
      return 'ocurrencia_$ocurrenciaId.pdf';
    }

    // Ejemplo:
    // attachment; filename="OCU-2026-000017.pdf"
    final utf8Match = RegExp(
      r'''filename\*=UTF-8''([^;]+)''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    if (utf8Match != null) {
      final encodedName = utf8Match.group(1);

      if (encodedName != null && encodedName.isNotEmpty) {
        return Uri.decodeComponent(encodedName);
      }
    }

    final normalMatch = RegExp(
      r'''filename="?([^";]+)"?''',
      caseSensitive: false,
    ).firstMatch(contentDisposition);

    final fileName = normalMatch?.group(1)?.trim();

    if (fileName != null && fileName.isNotEmpty) {
      return fileName.toLowerCase().endsWith('.pdf')
          ? fileName
          : '$fileName.pdf';
    }

    return 'ocurrencia_$ocurrenciaId.pdf';
  }
}
