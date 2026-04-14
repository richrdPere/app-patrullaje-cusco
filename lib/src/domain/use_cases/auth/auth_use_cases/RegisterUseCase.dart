
import 'package:sis_patrullaje_cusco/src/domain/entities/user_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  run(UserEntity sereno) => authRepository.register(sereno);
}
