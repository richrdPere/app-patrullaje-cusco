abstract class DirectionsException implements Exception {
  final String message;

  const DirectionsException(this.message);

  @override
  String toString() => message;
}

class InvalidRouteCoordinatesFailure extends DirectionsException {
  const InvalidRouteCoordinatesFailure(super.message);
}

class RouteNotFoundFailure extends DirectionsException {
  const RouteNotFoundFailure()
    : super(
        'No se encontró una ruta disponible entre las ubicaciones indicadas.',
      );
}

class DirectionsApiFailure extends DirectionsException {
  const DirectionsApiFailure(super.message);
}
