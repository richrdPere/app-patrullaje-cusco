import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/GetPatrullajeActivoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/SendLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeUseCase.dart';

class PatrullajeUseCases {
  GetPatrullajeActivoUseCase getPatrullajeActivo;
  EndPatrullajeUseCase endPatrullaje;
  StartPatrullajeUseCase startPatrullaje;
  SendLocationUseCase sendLocation;

  PatrullajeUseCases({
    required this.getPatrullajeActivo,
    required this.endPatrullaje,
    required this.startPatrullaje,
    required this.sendLocation,
  });
}
