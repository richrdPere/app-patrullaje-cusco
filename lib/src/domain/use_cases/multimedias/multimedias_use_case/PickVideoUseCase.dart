import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';

class PickVideoUseCase {
  final MediaRepository repository;

  PickVideoUseCase(this.repository);

  Future<File?> run() {
    return repository.pickVideo();
  }
}
