import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final ImagePicker picker;

  MediaRepositoryImpl(this.picker);

  @override
  Future<File?> takePhoto() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    return file != null ? File(file.path) : null;
  }

  @override
  Future<File?> recordVideo() async {
    final XFile? file = await picker.pickVideo(source: ImageSource.camera);

    return file != null ? File(file.path) : null;
  }

  @override
  Future<File?> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    return file != null ? File(file.path) : null;
  }
}
