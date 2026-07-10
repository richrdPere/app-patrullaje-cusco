import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/users_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/users_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class UsersRepositoryImpl extends UsersRepository {
  UsersService usersService;
  final AuthRepository authRepository;

  UsersRepositoryImpl(this.usersService, this.authRepository);

  @override
  Future<Resource<Usuario>> updateUsuario(
    int id,
    Usuario user,
    File? file,
  ) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await usersService.updateUsuario(id: id, user: user, token: token);
  }
}
