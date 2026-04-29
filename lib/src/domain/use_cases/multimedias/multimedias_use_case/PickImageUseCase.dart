import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';

class PickImageUseCase {
  final MediaRepository repository;

  PickImageUseCase(this.repository);

  Future<File?> run() {
    return repository.pickImage();
  }
}
