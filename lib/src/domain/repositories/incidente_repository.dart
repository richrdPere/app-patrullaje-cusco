import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class IncidenteRepository {
  /// 1. REGISTRAR INCIDENCIA
  Future<Resource<ApiResponse<RegisterIncidenciaData>>> newIncidencia({
    required RegisterIncidenciaRequest incidente,
  });

  /// 2. OBTENER MIS INCIDENCIAS
  Future<Resource<ApiResponse<MisIncidenciasPaginated>>> getMisIncidencias({
    required MisIncidenciasQueryParams params,
  });

  /// 3. OBTENER INCIDENCIA POR ID
  Future<Resource<ApiResponse<IncidenciaDetalleData>>> getIncidenciaById({
    required int incidenciaId,
  });

  /// 4. INCIDENCIAS CERCANAS
  Future<Resource<ApiResponse<IncidenciasCercanasData>>>
  getIncidenciasCercanas({required IncidenciasCercanasQueryParams params});

  /// 5. OBTENER INCIDENCIAS POR PATRULLAJE
  Future<Resource<ApiResponse<IncidenciasPatrullajePaginated>>>
  getIncidenciasByPatrullaje({
    required int patrullajeId,
    required IncidenciasPatrullajeQueryParams params,
  });

  /// 6. OBTENER INCIDENCIAS POR ZONA
  Future<Resource<ApiResponse<IncidenciasZonaPaginated>>> getIncidenciasByZona({
    required int zonaId,
    required IncidenciasZonaQueryParams params,
  });

  // ************************************************
  // EVIDENCIAS / ARCHIVOS
  // ************************************************

  /// 7. OBTENER ARCHIVOS DE INCIDENCIA
  Future<Resource<ApiResponse<IncidenciaArchivosData>>> getArchivosByIncidencia({
    required int incidenciaId,
  });

  /// 8. AGREGAR ARCHIVOS A INCIDENCIA
  Future<Resource<ApiResponse<AgregarArchivosIncidenciaData>>>
  addArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
  });

  /// 9. ELIMINAR ARCHIVO DE INCIDENCIA
  Future<Resource<void>> removeArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
  });
}
