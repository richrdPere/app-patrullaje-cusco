class TrackingSendResult {
  final bool success;
  final String message;
  final DateTime confirmedAt;
  final bool omitted;

  const TrackingSendResult({
    required this.success,
    required this.message,
    required this.confirmedAt,
    this.omitted = false,
  });
}
