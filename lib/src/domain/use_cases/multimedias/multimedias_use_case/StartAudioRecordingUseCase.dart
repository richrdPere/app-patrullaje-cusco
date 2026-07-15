import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class StartAudioRecordingUseCase {
  final MediaRepository repository;
  StartAudioRecordingUseCase(this.repository);

  Future<Resource<bool>> run() {
    return repository.startAudioRecording();
  }
}
