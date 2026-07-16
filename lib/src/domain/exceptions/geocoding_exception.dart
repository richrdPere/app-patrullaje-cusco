abstract class GeocodingException implements Exception {
  final String message;

  const GeocodingException(this.message);

  @override
  String toString() => message;
}

class InvalidCoordinatesFailure extends GeocodingException {
  const InvalidCoordinatesFailure(super.message);
}

class GeocodingFailure extends GeocodingException {
  const GeocodingFailure(super.message);
}
