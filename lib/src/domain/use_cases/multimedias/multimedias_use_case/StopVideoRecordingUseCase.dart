import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class StopVideoRecordingUseCase {
  final MediaRepository repository;
  StopVideoRecordingUseCase(this.repository);

  Future<Resource<File?>> run() {
    return repository.stopVideoRecording();
  }
}
