import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/ArchivarHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByIdUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/RegisterHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/UpdateHistorialUseCase.dart';

class HistorialPatrullajeUseCases {
  ArchivarHistorialUseCase archivedHistorial;
  GetHistorialByIdUseCase getHistorialById;
  GetHistorialByPatrullajeUseCase getHistorialByPatrullaje;
  UpdateHistorialUseCase updateHistorial;
  RegisterHistorialUseCase createHistorial;

  HistorialPatrullajeUseCases({
    required this.archivedHistorial,
    required this.getHistorialById,
    required this.getHistorialByPatrullaje,
    required this.updateHistorial,
    required this.createHistorial,
  });
}
