import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';

class ConnectSocketUseCase {
  SocketRepository socketRepository;
  ConnectSocketUseCase(this.socketRepository);

  run(String token) => socketRepository.connect(token);
}
