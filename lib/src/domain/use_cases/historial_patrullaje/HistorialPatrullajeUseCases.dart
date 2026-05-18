import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/ArchivarHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetContextoZonaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetResumenZonaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/RegisterHistorialUseCase.dart';

class HistorialPatrullajeUseCases {
  ArchivarHistorialUseCase archivarHistorial;
  GetContextoZonaUseCase getContextoZona;
  GetHistorialByPatrullajeUseCase getHistorialByPatrullaje;
  GetResumenZonaUseCase getResumenZona;
  RegisterHistorialUseCase registerResumenHistorial;

  HistorialPatrullajeUseCases({
    required this.archivarHistorial,
    required this.getContextoZona,
    required this.getHistorialByPatrullaje,
    required this.getResumenZona,
    required this.registerResumenHistorial,
  });
}
