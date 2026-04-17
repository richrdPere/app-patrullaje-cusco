import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';

class DisconnetSocketUseCase {
  SocketRepository socketRepository;
  DisconnetSocketUseCase(this.socketRepository);

  run() => socketRepository.disconnect();
}
