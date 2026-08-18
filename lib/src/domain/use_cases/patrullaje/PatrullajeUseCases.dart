import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class PatrullajeUseCases {
  GetPatrullajeActivoUseCase getPatrullajeActivo;
  EndPatrullajeUseCase endPatrullaje;
  StartPatrullajeUseCase startPatrullaje;
  SendLocationUseCase sendLocation;

  GetMisPatrullajesPaginadosUC getMisPatrullajesPaginados;
  ListenNewPatrullajeUseCase listenNewPatrullaje;
  ListenPatrullajeActualizadoUseCase listenPatrullajeActualizado;

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
    required this.getMisPatrullajesPaginados,
    required this.listenNewPatrullaje,
    required this.listenPatrullajeActualizado,
    required this.listenPatrullajeEnd,
    required this.startPatrullajeSocket,
    required this.endPatrullajeSocket,
    required this.joinPatrullaje,
    required this.leavePatrullaje,
  });
}
