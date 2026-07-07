

import 'package:sis_patrullaje_cusco/src/data/models/login/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';

class SaveUserSessionUseCase {
  AuthRepository authRepository;
  SaveUserSessionUseCase(this.authRepository);

  run(AuthResponse authResponse) =>
      authRepository.saveUserSession(authResponse);
}
