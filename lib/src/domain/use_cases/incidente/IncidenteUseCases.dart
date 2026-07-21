import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/AddArchivosIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/CreateIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetArchivosIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciaByIdUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasByPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasByZonaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasCercanasUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetMisIncidenciasUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/RemoveEvidenciaIncidenteUseCase.dart';

class IncidenteUseCases {
  final AddArchivosIncidenciaUseCase addArchivosIncidencia;
  final CreateIncidenteUseCase createIncidente;
  final GetArchivoIncidenciaUseCase getArchivosIncidente;
  final GetIncidenciaByIdUseCase getIncidenciaById;
  final GetIncidenciasByPatrullajeUseCase getIncidenciasByPatrullaje;
  final GetIncidenciasByZonaUseCase getIncidenciasByZona;
  final GetIncidenciasCercanasUseCase getIncidenciasCercanas;
  final GetMisIncidenciasUseCase getMisIncidencias;
  final RemoveArchivoIncidenciaUseCase removeArchivoIncidente;

  IncidenteUseCases({
    required this.addArchivosIncidencia,
    required this.createIncidente,
    required this.getArchivosIncidente,
    required this.getIncidenciaById,
    required this.getIncidenciasCercanas,
    required this.getMisIncidencias,
    required this.removeArchivoIncidente,
    required this.getIncidenciasByPatrullaje,
    required this.getIncidenciasByZona,
  });
}
