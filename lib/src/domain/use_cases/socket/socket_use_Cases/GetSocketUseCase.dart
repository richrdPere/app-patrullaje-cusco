import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';

class GetSocketUseCase {
  SocketRepository socketRepository;
  GetSocketUseCase(this.socketRepository);

  run() => socketRepository.getSocket();
}
