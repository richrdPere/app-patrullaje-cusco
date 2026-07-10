import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/incidente_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class IncidenteRepositoryImpl implements IncidenteRepository {
  final IncidenciaService remote;
  final AuthRepository authRepository;

  IncidenteRepositoryImpl(this.remote, this.authRepository);

  // 1. REGISTER INCIDENCIA
  @override
  Future<Resource<IncidenteModel>> newIncidencia(
    IncidenteModel incidente,
  ) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<IncidenteModel>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.registerIncidencia(incidencia: incidente, token: token);
  }

  // 2. OBTENER MIS INCIDENCIAS
  @override
  Future<Resource<List<IncidenteModel>>> getMisIncidencias({
    int page = 1,
    int limit = 10,
    String incluirArchivos = 'false',
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<List<IncidenteModel>>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.getMisIncidencias(
      token: token,
      page: page,
      limit: limit,
      incluirArchivos: incluirArchivos,
    );
  }

  // 3. OBTENER INCIDENCIA POR ID
  @override
  Future<Resource<IncidenteModel>> getIncidenciaById(int incidenciaId) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<IncidenteModel>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.getIncidenciaById(
      incidenciaId: incidenciaId,
      token: token,
    );
  }

  // 4. OBTENER INCIDENCIA CERCANAS
  @override
  Future<Resource<List<IncidenteModel>>> getIncidenciasCercanas({
    required double latitud,
    required double longitud,
    double radio = 500,
    int limit = 20,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<List<IncidenteModel>>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.getIncidenciasCercanas(
      latitud: latitud,
      longitud: longitud,
      radio: radio,
      limit: limit,
      token: token,
    );
  }

  // 5. OBTENER ARCHIVOS DE INCIDENCIA
  @override
  Future<Resource<List<IncidenciaArchivoModel>>> getArchivosIncidencia(
    int incidenciaId,
  ) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<List<IncidenciaArchivoModel>>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.getArchivosIncidencia(
      incidenciaId: incidenciaId,
      token: token,
    );
  }

  // 6. AGREGAR ARCHIVOS A INCIDENCIA
  @override
  Future<Resource<bool>> addArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<bool>(message: "No existe una sesión iniciada.");
    }

    return await remote.agregarArchivosIncidencia(
      incidenciaId: incidenciaId,
      archivos: archivos,
      token: token,
    );
  }

  // 7. REMOVER ARCHIVOS DE INCIDENCIA
  @override
  Future<Resource<bool>> removeArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<bool>(message: "No existe una sesión iniciada.");
    }

    return await remote.eliminarArchivoIncidencia(
      incidenciaId: incidenciaId,
      archivoId: archivoId,
      token: token,
    );
  }
}
