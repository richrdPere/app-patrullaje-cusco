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

  String get API_CREATE_HISTORIAL => '$API_BASE/crear';

  String API_GET_HISTORIAL_PATRULLAJE(int patrullajeId) =>
      '$API_BASE/patrullaje/$patrullajeId';

  String API_GET_DETALLE_HISTORIAL(int historialId) =>
      '$API_BASE/detalle/$historialId';

  String API_UPDATE_HISTORIAL(int historialId) =>
      '$API_BASE/editar/$historialId';

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
      'Authorization': 'Bearer ${session.data.token}',
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

      Uri url = Uri.parse(API_CREATE_HISTORIAL);

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

      Uri url = Uri.parse(API_GET_HISTORIAL_PATRULLAJE(patrullajeId));

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
  // 3. OBTENER DETALLE DEL HISTORIAL
  // =====================================================
  Future<HistorialPatrullajeModel> obtenerDetalleHistorial(
    int historialId,
  ) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_GET_DETALLE_HISTORIAL(historialId));

      final response = await http.get(url, headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return HistorialPatrullajeModel.fromJson(data['historial']);
      } else {
        throw Exception(data['msg'] ?? 'Error al obtener detalle');
      }
    } catch (error) {
      throw Exception('Error obtenerDetalleHistorial: $error');
    }
  }

  // =====================================================
  // 4. EDITAR HISTORIAL
  // =====================================================
  Future<HistorialPatrullajeModel> editarHistorial(
    HistorialPatrullajeModel historial,
  ) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_UPDATE_HISTORIAL(historial.id!));

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(historial.toJson()),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return HistorialPatrullajeModel.fromJson(data['historial']);
      } else {
        throw Exception(data['msg'] ?? 'Error al editar historial');
      }
    } catch (error) {
      throw Exception('Error editarHistorial: $error');
    }
  }

  // =====================================================
  // 5. ARCHIVAR HISTORIAL
  // =====================================================
  Future<void> archivarHistorial(int historialId) async {
    try {
      final headers = await _getHeaders();

      Uri url = Uri.parse(API_ARCHIVAR_HISTORIAL(historialId));

      final response = await http.patch(url, headers: headers);

      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['msg'] ?? 'Error al archivar historial');
      }
    } catch (error) {
      throw Exception('Error archivarHistorial: $error');
    }
  }
}
