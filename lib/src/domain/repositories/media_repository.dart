import 'dart:io';

abstract class MediaRepository {
  Future<File?> takePhoto();
  Future<File?> recordVideo();
  Future<File?> pickImage();
}