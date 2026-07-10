import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/AddArchivosIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/CreateIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetArchivosIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciaByIdUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetMisIncidenciasUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasCercanasUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/RemoveEvidenciaIncidenteUseCase.dart';

class IncidenteUseCases {
  AddArchivosIncidenciaUseCase addArchivosIncidencia;
  CreateIncidenteUseCase createIncidente;
  GetArchivoIncidenciaUseCase getEvidenciasIncidente;
  GetIncidenciaByIdUseCase getIncidenciaById;
  GetIncidenciasCercanasUseCase getIncidenciasCercanas;
  GetMisIncidenciasUseCase getMisIncidencias;
  RemoveArchivoIncidenciaUseCase removeEvidenciaIncidente;

  IncidenteUseCases({
    required this.addArchivosIncidencia,
    required this.createIncidente,
    required this.getEvidenciasIncidente,
    required this.getIncidenciaById,
    required this.getIncidenciasCercanas,
    required this.getMisIncidencias,
    required this.removeEvidenciaIncidente,
  });
}
