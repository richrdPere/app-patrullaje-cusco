import 'dart:io';

abstract class MediaRepository {

  Future<File?> takePhoto();

  Future<File?> pickImage();

  Future<File?> recordVideo();

  Future<File?> pickVideo();

}