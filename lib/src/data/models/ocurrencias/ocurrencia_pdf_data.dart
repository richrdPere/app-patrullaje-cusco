import 'dart:typed_data';

class OcurrenciaPdfData {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final int size;

  const OcurrenciaPdfData({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.size,
  });

  bool get isEmpty => bytes.isEmpty;

  bool get isNotEmpty => bytes.isNotEmpty;

  double get sizeInKb => size / 1024;

  double get sizeInMb => size / (1024 * 1024);
}
