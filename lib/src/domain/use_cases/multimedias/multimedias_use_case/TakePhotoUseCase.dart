import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class TakePhotoUseCase {
  final MediaRepository repository;
  TakePhotoUseCase(this.repository);

  Future<Resource<File?>> run() {
    return repository.takePhoto();
  }
}
