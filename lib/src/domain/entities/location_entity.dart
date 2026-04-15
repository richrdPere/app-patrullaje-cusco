class LocationEntity {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int? patrullajeId;

  LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.patrullajeId,
  });
}
