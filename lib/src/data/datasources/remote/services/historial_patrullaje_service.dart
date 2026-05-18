// ignore_for_file: non_constant_identifier_names, unnecessary_this
import 'dart:convert';
import 'package:http/http.dart' as http;

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models
import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';

class HistorialPatrullajeService {
  final AuthRepository authRepository;
  HistorialPatrullajeService(this.authRepository);

  // =====================================================
  // APIS
  // =====================================================
  String get API_BASE => '${url_backend.Environment.mainUrl}/historial';

  String get API_REGISTRAR_HISTORIAL => API_BASE;

  String API_HISTORIAL_PATRULLAJE(int patrullajeId) =>
      '$API_BASE/patrullaje/$patrullajeId';

  String API_CONTEXTO_ZONA(int zonaId) => '$API_BASE/zona/$zonaId';

  String API_RESUMEN_ZONA(int zonaId) => '$API_BASE/zona/$zonaId/resumen';

  String API_ARCHIVAR_HISTORIAL(int historialId) =>
      '$API_BASE/archivar/$historialId';

  // =====================================================
  // HEADERS
  // =====================================================
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
  // 1. REGISTRAR HISTORIAL
  // =====================================================
  Future<HistorialPatrullajeModel?> registrarHistorial(
    HistorialPatrullajeModel historial,
  ) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_REGISTRAR_HISTORIAL);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(historial.toJson()),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return HistorialPatrullajeModel.fromJson(data['historial']);
      } else {
        throw Exception(data['msg'] ?? 'Error al registrar historial');
      }
    } catch (error) {
      throw Exception('Error registrarHistorial: $error');
    }
  }

  // =====================================================
  // 2. OBTENER HISTORIAL POR PATRULLAJE
  // =====================================================
  Future<List<HistorialPatrullajeModel>> obtenerHistorialPorPatrullaje(
    int patrullajeId,
  ) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_HISTORIAL_PATRULLAJE(patrullajeId));

      final response = await http.get(url, headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final List historialJson = data['historial'];

        return historialJson
            .map((e) => HistorialPatrullajeModel.fromJson(e))
            .toList();
      } else {
        throw Exception(data['msg'] ?? 'Error al obtener historial');
      }
    } catch (error) {
      throw Exception('Error obtenerHistorialPorPatrullaje: $error');
    }
  }

  // =====================================================
  // 3. OBTENER CONTEXTO OPERATIVO DE ZONA
  // =====================================================
  Future<Map<String, dynamic>> obtenerContextoZona(int zonaId) async {
    try {
      final headers = await _getHeaders();
      Uri url = Uri.parse(API_CONTEXTO_ZONA(zonaId));
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['msg'] ?? 'Error al obtener contexto operativo');
      }
    } catch (error) {
      throw Exception('Error obtenerContextoZona: $error');
    }
  }

  // =====================================================
  // 4. OBTENER RESUMEN OPERATIVO
  // =====================================================
  Future<Map<String, dynamic>> obtenerResumenZona(int zonaId) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_RESUMEN_ZONA(zonaId));

      final response = await http.get(url, headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['resumen'];
      } else {
        throw Exception(data['msg'] ?? 'Error al obtener resumen');
      }
    } catch (error) {
      throw Exception('Error obtenerResumenZona: $error');
    }
  }

  // =====================================================
  // 5. ARCHIVAR HISTORIAL
  // =====================================================
  Future<void> archivarHistorial(int historialId) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_ARCHIVAR_HISTORIAL(historialId));

      final response = await http.put(url, headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['msg'] ?? 'Error al archivar historial');
      }
    } catch (error) {
      throw Exception('Error archivarHistorial: $error');
    }
  }
}
