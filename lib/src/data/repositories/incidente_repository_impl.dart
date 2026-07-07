import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/incidente_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class IncidenteRepositoryImpl extends IncidenteRepository {
  final IncidenteService incidenteService;

  IncidenteRepositoryImpl(this.incidenteService);

  // 1. REGISTRAR INCIDENTE
  @override
  Future<IncidenteModel> newIncidencia(IncidenteModel params) async {
    final response = await incidenteService.newIncidente(params);

    if (response == null) {
      throw Exception("No se pudo crear la incidencia");
    }

    return response;
  }

  // 2. GET INCIDENCIA
  @override
  Future<IncidenteModel> getIncidencia(int incidenciaId) async {
    return await incidenteService.getIncidencia(incidenciaId);
  }

  // 3. GET INCIDENCIAS CERCANA
  @override
  Future<List<IncidenteModel>> getIncidenciasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 3,
  }) async {
    return await incidenteService.getNearbyIncidents(
      latitud: latitud,
      longitud: longitud,
      radio: radioKm,
    );
  }

  // 4. GET INCIDENCIA ACTIVAS PARA MAPA
  @override
  Future<List<IncidenteModel>> getIncidenciasActivasMapa() async {
    return await incidenteService.getMapaIncidenciasActivas();
  }

  // 5. GET DASHBOARD  RESUMEN
  @override
  Future<Map<String, dynamic>> getDashboard() async {
    return await incidenteService.getDashboardIncidencias();
  }

  // 6. AGREGAR EVIDENCIAS
  @override
  Future<void> addEvidencias(int incidenciaId, List<File> archivos) {
    return incidenteService.agregarEvidencias(incidenciaId, archivos);
  }

  // 7. ELIMINAR EVIDENCIA
  @override
  Future<void> removeEvidencia(int evidenciaId) {
    return incidenteService.eliminarEvidencia(evidenciaId);
  }

  // 8. OBTENER EVIDENCIAS DE UNA INCIDENCIA
  @override
  Future<List<IncidenciaArchivoModel>> getEvidencias(
    int incidenciaId,
  ) async {
    return await incidenteService.getEvidenciasIncidencia(incidenciaId);
  }
}
