import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class HistorialPatrullajeRepository {
  /// 1. CREAR HISTORIAL
  Future<Resource<ApiResponse<HistorialData>>> createHistorial({
    required CreateHistorialRequest request,
  });

  /// 2. OBTENER HISTORIAL POR PATRULLAJE
  Future<Resource<ApiResponse<List<HistorialPatrullajeData>>>>
  getHistorialByPatrullaje({required int patrullajeId});

  /// 3. OBTENER HISTORIAL POR ID
  Future<Resource<ApiResponse<HistorialDetalleData>>> getHistorialById({
    required int historialId,
  });

  /// 4. CREAR OBSERVACIÓN CON ARCHIVOS
  Future<Resource<ApiResponse<HistorialData>>> createObservacionConArchivos({
    required CreateHistorialRequest request,
    required List<File> archivos,
  });

  /// 5. OBTENER CONTEXTO OPERATIVO DE UNA ZONA
  Future<Resource<ApiResponse<ContextoZonaData>>> getContextoZona({
    required int zonaId,
    required ContextoZonaQueryParams params,
  });

  /// 6. OBTENER INFORMACIÓN PARA EL SIGUIENTE TURNO
  Future<Resource<ApiResponse<SiguienteTurnoData>>> getParaSiguienteTurno({
    required SiguienteTurnoQueryParams params,
  });

  /// 7. ACTUALIZAR HISTORIAL
  Future<Resource<ApiResponse<HistorialData>>> updateHistorial({
    required int historialId,
    required CreateHistorialRequest request,
  });

  /// 8. ARCHIVAR HISTORIAL
  Future<Resource<ApiResponse<HistorialData>>> archiveHistorial({
    required int historialId,
  });
}
