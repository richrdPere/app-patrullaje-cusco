import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/GetPatrullajeActivoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/JoinPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/LeavePatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenNewPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenPatrullajeEndUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/SendLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeUseCase.dart';

class PatrullajeUseCases {
  GetPatrullajeActivoUseCase getPatrullajeActivo;
  EndPatrullajeUseCase endPatrullaje;
  StartPatrullajeUseCase startPatrullaje;
  SendLocationUseCase sendLocation;
  ListenNewPatrullajeUseCase listenNewPatrullaje;
  ListenPatrullajeEndUseCase listenPatrullajeEnd;
  StartPatrullajeSocketUseCase startPatrullajeSocket;
  EndPatrullajeSocketUseCase endPatrullajeSocket;
  JoinPatrullajeUseCase joinPatrullaje;
  LeavePatrullajeUseCase leavePatrullaje;

  PatrullajeUseCases({
    required this.getPatrullajeActivo,
    required this.endPatrullaje,
    required this.startPatrullaje,
    required this.sendLocation,
    required this.listenNewPatrullaje,
    required this.listenPatrullajeEnd,
    required this.startPatrullajeSocket,
    required this.endPatrullajeSocket,
    required this.joinPatrullaje,
    required this.leavePatrullaje,
  });
}
