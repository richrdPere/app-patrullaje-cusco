import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/ConnectSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/DisconnetSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/GetSocketUseCase.dart';

class SocketUseCases {
  ConnectSocketUseCase connectSocket;
  DisconnetSocketUseCase disconnetSocket;
  GetSocketUseCase getSocket;

  SocketUseCases({
    required this.connectSocket,
    required this.disconnetSocket,
    required this.getSocket,
  });
}
