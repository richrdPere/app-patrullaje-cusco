import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/users_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class UsersRepositoryImpl extends UsersRepository {


  
  @override
  Future<Resource<Usuario>> update(int id, Usuario user, File? file) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
