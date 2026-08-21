// Repo
import 'dart:io';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Repository y Service
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

class HistorialPatrullajeRepositoryImpl
    implements HistorialPatrullajeRepository {
  final HistorialPatrullajeService historialService;
  final AuthRepository authRepository;

  HistorialPatrullajeRepositoryImpl(this.historialService, this.authRepository);

  // *********************************************************
  // 1. CREAR HISTORIAL
  // *********************************************************
  @override
  Future<Resource<ApiResponse<HistorialData>>> createHistorial({
    required CreateHistorialRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await historialService.createHistorial(
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 2. OBTENER HISTORIAL POR PATRULLAJE
  // *********************************************************
  @override
  Future<Resource<ApiResponse<List<HistorialPatrullajeData>>>>
  getHistorialByPatrullaje({required int patrullajeId}) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await historialService.getHistorialByPatrullaje(
      patrullajeId: patrullajeId,
      token: token,
    );
  }

  // *********************************************************
  // 3. OBTENER HISTORIAL POR ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<HistorialDetalleData>>> getHistorialById({
    required int historialId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await historialService.getHistorialById(
      historialId: historialId,
      token: token,
    );
  }

  // *********************************************************
  // 4. CREAR OBSERVACIÓN CON ARCHIVOS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<HistorialData>>> createObservacionConArchivos({
    required CreateHistorialRequest request,
    required List<File> archivos,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await historialService.createObservacionConArchivos(
      request: request,
      archivos: archivos,
      token: token,
    );
  }

  // *********************************************************
  // 5. OBTENER CONTEXTO OPERATIVO DE UNA ZONA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ContextoZonaData>>> getContextoZona({
    required int zonaId,
    required ContextoZonaQueryParams params,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await historialService.getContextoZona(
      params: params,
      zonaId: zonaId,
      token: token,
    );
  }

  // *********************************************************
  // 6. OBTENER INFORMACIÓN PARA EL SIGUIENTE TURNO
  // *********************************************************
  @override
  Future<Resource<ApiResponse<SiguienteTurnoData>>> getParaSiguienteTurno({
    required SiguienteTurnoQueryParams params,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await historialService.getParaSiguienteTurno(
      params: params,
      token: token,
    );
  }

  // *********************************************************
  // 7. ACTUALIZAR HISTORIAL
  // *********************************************************
  @override
  Future<Resource<ApiResponse<HistorialData>>> updateHistorial({
    required int historialId,
    required CreateHistorialRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await historialService.updateHistorial(
      historialId: historialId,
      request: request,
      token: token,
    );
  }

  // *********************************************************
  // 8. ARCHIVAR HISTORIAL
  // *********************************************************
  @override
  Future<Resource<ApiResponse<HistorialData>>> archiveHistorial({
    required int historialId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await historialService.archiveHistorial(
      historialId: historialId,

      token: token,
    );
  }
}
