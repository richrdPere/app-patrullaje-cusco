// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';

class IncidenteService {
  final AuthRepository authRepository;
  IncidenteService(this.authRepository);

  // APIS
  String get API_BASE => url_backend.Environment.mainUrl + '/incidencias';

  String get API_NEW_INCIDENTE => '$API_BASE/crear';
  String get API_NEARBY_INCIDENTES => '$API_BASE/nearby';
  String get API_MAPA_ACTIVAS => '$API_BASE/mapa-activas';
  String get API_DASHBOARD_RESUMEN => '$API_BASE/dashboard/resumen';
  String apiDetalleIncidencia(int id) => '$API_BASE/$id';
  String apiEvidenciasIncidencia(int id) => '$API_BASE/$id/evidencias';
  String apiAgregarEvidencia(int id) => '$API_BASE/$id/evidencias';
  String apiEliminarEvidencia(int evidenciaId) =>
      '$API_BASE/evidencias/$evidenciaId';

  // ============================
  // HEADERS
  // ============================
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = await authRepository.getUserSession();

    if (session == null) {
      throw Exception('No hay sesión activa');
    }

    return {'Authorization': 'Bearer ${session.data.token}'};
  }

  Future<Map<String, String>> _getJsonHeaders() async {
    final session = await authRepository.getUserSession();

    if (session == null) {
      throw Exception('No hay sesión activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.data.token}',
    };
  }

  // =====================================================
  // 1. REGISTRAR INCIDENTE
  // =====================================================
  Future<IncidenteModel?> newIncidente(IncidenteModel params) async {
    try {
      final headers = await _getAuthHeaders();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse(API_NEW_INCIDENTE),
      );

      request.headers.addAll(headers);

      // CAMPOS
      // request.fields['usuario_id'] = params.usuarioId.toString();
      // request.fields['zona_id'] = params.zonaId.toString();
      request.fields['tipo'] = params.tipo;
      request.fields['descripcion'] = params.descripcion;
      request.fields['latitud'] = params.latitud.toString();
      request.fields['longitud'] = params.longitud.toString();
      request.fields['origen'] = params.origen;

      if (params.patrullajeId != null) {
        request.fields['patrullaje_id'] = params.patrullajeId.toString();
      }

      // EVIDENCIAS
      if (params.archivos != null && params.archivos!.isNotEmpty) {
        for (final file in params.archivos!) {
          if (!file.existsSync()) continue;

          request.files.add(
            await http.MultipartFile.fromPath('archivos', file.path),
          );
        }
      }

      print("===== CREAR INCIDENCIA =====");
      print("URL: $API_NEW_INCIDENTE");
      print("FIELDS: ${request.fields}");
      print("FILES: ${request.files.length}");

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return IncidenteModel.fromJson(data['incidencia']);
      }

      throw Exception(data['message'] ?? 'Error al registrar incidencia');
    } catch (e) {
      throw Exception('Error al registrar incidencia: $e');
    }
  }

  // =====================================================
  // 2. GET INCIDENCIA
  // =====================================================
  Future<IncidenteModel> getIncidencia(int incidenciaId) async {
    final headers = await _getJsonHeaders();

    final response = await http.get(
      Uri.parse(apiDetalleIncidencia(incidenciaId)),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return IncidenteModel.fromJson(data['incidencia']);
    }

    throw Exception(data['message']);
  }

  // =====================================================
  // 3. GET EVIDENCIAS DE UNA INCIDENCIA
  // =====================================================
  Future<List<IncidenciaArchivoModel>> getEvidenciasIncidencia(
    int incidenciaId,
  ) async {
    final headers = await _getJsonHeaders();

    final response = await http.get(
      Uri.parse(apiEvidenciasIncidencia(incidenciaId)),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['evidencias'];
    }

    throw Exception(data['message']);
  }

  // =====================================================
  // 4. AGREGAR EVIDENCIA A UNA INCIDENCIA
  // =====================================================
  Future<void> agregarEvidencias(int incidenciaId, List<File> archivos) async {
    final headers = await _getAuthHeaders();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(apiAgregarEvidencia(incidenciaId)),
    );

    request.headers.addAll(headers);

    for (final archivo in archivos) {
      request.files.add(
        await http.MultipartFile.fromPath('archivos', archivo.path),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();

      throw Exception(body);
    }
  }

  // =====================================================
  // 5. ELIMINAR EVIDENCIA DE UNA INCIDENCIA
  // =====================================================
  Future<void> eliminarEvidencia(int evidenciaId) async {
    final headers = await _getJsonHeaders();

    final response = await http.delete(
      Uri.parse(apiEliminarEvidencia(evidenciaId)),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);

      throw Exception(data['message']);
    }
  }

  // =====================================================
  // 6. MAPA DE INCIDENCIAS ACTIVAS
  // =====================================================
  Future<List<IncidenteModel>> getMapaIncidenciasActivas() async {
    final headers = await _getJsonHeaders();

    final response = await http.get(
      Uri.parse(API_MAPA_ACTIVAS),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['incidencias'];
    }

    throw Exception(data['message']);
  }

  // =====================================================
  // 7. DASHBOARD DE INCIDENCIA
  // =====================================================
  Future<Map<String, dynamic>> getDashboardIncidencias() async {
    final headers = await _getJsonHeaders();

    final response = await http.get(
      Uri.parse(API_DASHBOARD_RESUMEN),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message']);
  }

  // =====================================================
  // 8. INCIDENCIAS CERCANAS
  // =====================================================
  Future<List<IncidenteModel>> getNearbyIncidents({
    required double latitud,
    required double longitud,
    double radio = 3,
  }) async {
    final headers = await _getJsonHeaders();

    final uri = Uri.parse(API_NEARBY_INCIDENTES).replace(
      queryParameters: {
        'latitud': latitud.toString(),
        'longitud': longitud.toString(),
        'radio': radio.toString(),
      },
    );

    final response = await http.get(uri, headers: headers);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data['incidencias'] as List)
          .map((e) => IncidenteModel.fromJson(e))
          .toList();
    }

    throw Exception(data['message']);
  }
}
