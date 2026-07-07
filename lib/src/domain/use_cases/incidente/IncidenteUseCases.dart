import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/AddEvidenciasIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/CreateIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetDashboardIncidentesUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetEvidenciasIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetMapaIncidentesUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetNearbyIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/RemoveEvidenciaIncidenteUseCase.dart';

class IncidenteUseCases {
  CreateIncidenteUseCase createIncidente;
  AddEvidenciasIncidenteUseCase addEvidenciasIncidente;
  RemoveEvidenciaIncidenteUseCase removeEvidenciaIncidente;
  GetDashboardIncidentesUseCase getDashboardIncidentes;
  GetEvidenciasIncidenteUseCase getEvidenciasIncidente;
  GetIncidenciaUseCase getIncidencia;
  GetMapaIncidentesUseCase getMapaIncidentes;
  GetNearbyIncidentesUseCase getNearbyIncidentes;

  IncidenteUseCases({
    required this.createIncidente,
    required this.addEvidenciasIncidente,
    required this.removeEvidenciaIncidente,
    required this.getDashboardIncidentes,
    required this.getEvidenciasIncidente,
    required this.getIncidencia,
    required this.getMapaIncidentes,
    required this.getNearbyIncidentes,
  });
}
