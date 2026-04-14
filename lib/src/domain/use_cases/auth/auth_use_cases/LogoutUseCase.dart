import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  run() => authRepository.logout();
}
