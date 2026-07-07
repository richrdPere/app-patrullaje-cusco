import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

abstract class IncidenteRepository {

  // INCIDENCIAS
  Future<IncidenteModel> newIncidencia(IncidenteModel incidente);

  Future<IncidenteModel> getIncidencia(int incidenciaId);

  Future<List<IncidenteModel>> getIncidenciasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 3,
  });

  Future<List<IncidenteModel>> getIncidenciasActivasMapa();


  // DASHBOARD
  Future<Map<String, dynamic>> getDashboard();

  // EVIDENCIAS

  Future<List<IncidenciaArchivoModel>> getEvidencias(int incidenciaId);

  Future<void> addEvidencias(int incidenciaId, List<File> archivos);

  Future<void> removeEvidencia(int evidenciaId);
}
