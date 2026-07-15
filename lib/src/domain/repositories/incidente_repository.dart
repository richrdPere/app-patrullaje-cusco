import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/models/incidencia/register_incidencia_req.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class IncidenteRepository {
  // INCIDENCIAS
  Future<Resource<IncidenteModel>> newIncidencia(RegisterIncidenciaRequest incidente);

  Future<Resource<List<IncidenteModel>>> getMisIncidencias({
    int page = 1,
    int limit = 10,
    String incluirArchivos = 'false',
  });

  Future<Resource<IncidenteModel>> getIncidenciaById(int incidenciaId);

  Future<Resource<List<IncidenteModel>>> getIncidenciasCercanas({
    required double latitud,
    required double longitud,
    double radio = 500,
    int limit = 20,
  });

  // EVIDENCIAS / ARCHIVOS
  Future<Resource<List<IncidenciaArchivoModel>>> getArchivosIncidencia(
    int incidenciaId,
  );

  Future<Resource<bool>> addArchivosIncidencia({
    required int incidenciaId,
    required List<File> archivos,
  });

  Future<Resource<bool>> removeArchivoIncidencia({
    required int incidenciaId,
    required int archivoId,
  });
}
