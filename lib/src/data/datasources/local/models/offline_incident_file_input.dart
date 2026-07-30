class OfflineIncidentFileInput {
  final String clientId;
  final String localPath;
  final String fileName;
  final String mimeType;
  final String categoria;
  final int? sizeBytes;

  const OfflineIncidentFileInput({
    required this.clientId,
    required this.localPath,
    required this.fileName,
    required this.mimeType,
    required this.categoria,
    this.sizeBytes,
  });
}
