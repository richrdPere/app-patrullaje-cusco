import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickImageUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickVideoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StartAudioRecordingUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StartVideoRecordingUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StopAudioRecordingUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StopVideoRecordingUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/TakePhotoUseCase.dart';

class MultimediasUseCases {
  PickImageUseCase pickImage;
  PickVideoUseCase pickVideo;
  StartAudioRecordingUseCase startAudioRecording;
  StartVideoRecordingUseCase startVideoRecording;
  StopAudioRecordingUseCase stopAudioRecording;
  StopVideoRecordingUseCase stopVideoRecording;
  TakePhotoUseCase takePhoto;

  MultimediasUseCases({
    required this.pickImage,
    required this.pickVideo,
    required this.startAudioRecording,
    required this.startVideoRecording,
    required this.stopAudioRecording,
    required this.stopVideoRecording,
    required this.takePhoto,
  });
}
