import 'dart:io';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Services
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class IncidenteRepositoryImpl implements IncidenteRepository {
  final IncidenciaService remote;
  final AuthRepository authRepository;

  IncidenteRepositoryImpl(this.remote, this.authRepository);

  // *********************************************************
  // 1. REGISTRAR INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<RegisterIncidenciaData>>> newIncidencia({
    required RegisterIncidenciaRequest incidente,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.registerIncidencia(
      requestData: incidente,
      token: token,
    );
  }

  // *********************************************************
  // 2. OBTENER MIS INCIDENCIAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MisIncidenciasPaginated>>> getMisIncidencias({
    required MisIncidenciasQueryParams params,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<ApiResponse<MisIncidenciasPaginated>>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await remote.getMisIncidenciasPaginadas(
      token: token,
      params: params,
    );
  }

  // *********************************************************
  // 3. OBTENER INCIDENCIA POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciaDetalleData>>> getIncidenciaById({
    required int incidenciaId,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.getIncidenciaById(
      incidenciaId: incidenciaId,
      token: token,
    );
  }

  // *********************************************************
  // 4. OBTENER ARCHIVOS DE UNA INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciaArchivosData>>>
  getArchivosByIncidencia({required int incidenciaId}) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.getArchivosByIncidencia(
      incidenciaId: incidenciaId,
      token: token,
    );
  }

  // *********************************************************
  // 5. AGREGAR ARCHIVOS A INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AgregarArchivosIncidenciaData>>>
  addArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.agregarArchivosIncidencia(
      incidenciaId: incidenciaId,
      archivos: archivos,
      token: token,
    );
  }

  // *********************************************************
  // 6. ELIMINAR ARCHIVO DE INCIDENCIA
  // *********************************************************
  @override
  Future<Resource<void>> removeArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.eliminarArchivoIncidencia(
      incidenciaId: incidenciaId,
      archivoId: archivoId,
      token: token,
    );
  }

  // *********************************************************
  // 7. OBTENER INCIDENCIAS CERCANAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciasCercanasData>>>
  getIncidenciasCercanas({
    required IncidenciasCercanasQueryParams params,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.getIncidenciasCercanas(params: params, token: token);
  }

  // *********************************************************
  // 8. OBTENER INCIDENCIAS POR PATRULLAJE
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciasPatrullajePaginated>>>
  getIncidenciasByPatrullaje({
    required int patrullajeId,
    required IncidenciasPatrullajeQueryParams params,
  }) async {
    final token = await authRepository.getToken();

    if (token == null || token.trim().isEmpty) {
      return ErrorData(
        message: 'No existe una sesión válida.',
        statusCode: 401,
      );
    }

    return remote.getIncidenciasByPatrullaje(
      token: token,
      patrullajeId: patrullajeId,
      params: params,
    );
  }

  // *********************************************************
  // 9. OBTENER INCIDENCIAS POR ZONA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciasZonaPaginated>>> getIncidenciasByZona({
    required int zonaId,
    required IncidenciasZonaQueryParams params,
  }) async {
    final token = await authRepository.getToken();

    if (token == null || token.trim().isEmpty) {
      return ErrorData(
        message: 'No existe una sesión válida.',
        statusCode: 401,
      );
    }

    return remote.getIncidenciasByZona(
      token: token,
      zonaId: zonaId,
      params: params,
    );
  }
}
