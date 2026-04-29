import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';

class RecordVideoUseCase {
  final MediaRepository repository;

  RecordVideoUseCase(this.repository);

  Future<File?> run() {
    return repository.recordVideo();
  }
}
