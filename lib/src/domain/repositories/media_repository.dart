import 'dart:io';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class MediaRepository {
  // FOTOGRAFÍAS
  Future<Resource<File?>> takePhoto();
  Future<Resource<File?>> pickImage();

  // VIDEOS
  Future<Resource<File?>> pickVideo();
  Future<Resource<bool>> startVideoRecording();
  Future<Resource<File?>> stopVideoRecording();

  // AUDIOS
  Future<Resource<bool>> startAudioRecording();
  Future<Resource<File?>> stopAudioRecording();

  // LIBERACION DE RECURSOS
  Future<void> dispose();
}
