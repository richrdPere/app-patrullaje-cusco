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

class IncidenteService {
  final AuthRepository authRepository;

  IncidenteService(this.authRepository);

  // APIS
  String get API_BASE => url_backend.Environment.mainUrl + '/incidencias';

  String get API_NEW_INCIDENTE => '$API_BASE/crear';
  // String get API_START_PATRULLAJE => '$API_BASE/patrullaje/';
  // String get API_END_PATRULLAJE => '$API_BASE/patrullaje/';
  // String get API_LOCATION => '$API_BASE/patrullaje/location';

  // ============================
  // HEADERS
  // ============================
  Future<Map<String, String>> _getHeaders() async {
    final session = await authRepository.getUserSession();

    if (session == null) {
      throw Exception('No hay sesión activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.token}',
    };
  }

  // =====================================================
  // 1. REGISTRAR INCIDENTE
  // =====================================================
  Future<IncidenteModel?> newIncidente(IncidenteModel params) async {
    try {
      print("📦 INICIANDO ENVÍO DE INCIDENTE");
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_NEW_INCIDENTE);

      var request = http.MultipartRequest("POST", url);

      // HEADERS (IMPORTANTE)
      request.headers.addAll(headers);

      // CAMPOS
      request.fields['usuario_id'] = params.usuarioId.toString();
      request.fields['tipo'] = params.tipo;
      request.fields['descripcion'] = params.descripcion;
      request.fields['latitud'] = params.latitud.toString();
      request.fields['longitud'] = params.longitud.toString();

      if (params.patrullajeId != null) {
        request.fields['patrullaje_id'] = params.patrullajeId.toString();
      }

      print("CAMPOS: ${request.fields}");

      // ARCHIVOS
      if (params.archivos != null && params.archivos!.isNotEmpty) {
        print("Archivos a enviar: ${params.archivos!.length}");

        for (File file in params.archivos!) {
          if (!file.existsSync()) {
            print("Archivo no existe: ${file.path}");
            continue;
          }

          final size = file.lengthSync();
          print("📸 Archivo:");
          print("   📍 Path: ${file.path}");
          print("   📏 Tamaño: ${size / (1024 * 1024)} MB");

          if (size > 10 * 1024 * 1024) {
            throw Exception("Archivo muy pesado: ${file.path}");
          }

          final multipartFile = await http.MultipartFile.fromPath(
            'archivos',
            file.path,
          );

          request.files.add(multipartFile);
        }
      }

      print("📦 TOTAL FILES EN REQUEST: ${request.files.length}");

      // ENVIAR
      final streamedResponse = await request.send();

      print("📡 STATUS CODE: ${streamedResponse.statusCode}");

      final response = await http.Response.fromStream(streamedResponse);

      print("📨 RESPONSE BODY: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return IncidenteModel.fromJson(data['incidencia']);
      } else {
        throw Exception(data['message'] ?? "Error al crear incidencia");
      }
    } catch (error) {
      throw Exception('Error al crear incidencia: $error');
    }
  }
}
