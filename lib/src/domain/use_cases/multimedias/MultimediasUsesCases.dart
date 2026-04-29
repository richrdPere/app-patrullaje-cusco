import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickImageUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/RecordVideoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/TakePhotoUseCase.dart';

class MultimediasUseCases {
  TakePhotoUseCase takePhoto;
  RecordVideoUseCase recordVideo;
  PickImageUseCase pickImage;

  MultimediasUseCases({
    required this.takePhoto,
    required this.recordVideo,
    required this.pickImage,
  });
}
