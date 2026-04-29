import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/users_repository.dart';

class UpdateUserUseCase {
  UsersRepository usersRepository;

  UpdateUserUseCase(this.usersRepository);

  run(int id, Usuario user, File? file) =>
      usersRepository.updateUsuario(id, user, file);
}
