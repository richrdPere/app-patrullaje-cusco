import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class StopAudioRecordingUseCase {
  final MediaRepository repository;
  StopAudioRecordingUseCase(this.repository);

  Future<Resource<File?>> run() {
    return repository.stopAudioRecording();
  }
}
