import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';

class TakePhotoUseCase {
  final MediaRepository repository;

  TakePhotoUseCase(this.repository);

  Future<File?> run() {
    return repository.takePhoto();
  }
}
