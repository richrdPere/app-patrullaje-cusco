import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class StartVideoRecordingUseCase {
  final MediaRepository repository;
  StartVideoRecordingUseCase(this.repository);

  Future<Resource<bool>> run() {
    return repository.startVideoRecording();
  }
}
