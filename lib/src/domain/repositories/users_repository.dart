import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class UsersRepository {
  Future<Resource<Usuario>> update(int id, Usuario user, File? file);
}
