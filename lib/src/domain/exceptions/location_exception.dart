abstract class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}

class LocationServiceDisabledFailure extends LocationException {
  const LocationServiceDisabledFailure()
    : super(
        'El servicio de ubicación se encuentra desactivado. '
        'Activa el GPS para continuar.',
      );
}

class LocationPermissionDeniedFailure extends LocationException {
  const LocationPermissionDeniedFailure()
    : super('El permiso de ubicación fue denegado.');
}

class LocationPermissionDeniedForeverFailure extends LocationException {
  const LocationPermissionDeniedForeverFailure()
    : super(
        'El permiso de ubicación fue denegado permanentemente. '
        'Debes habilitarlo desde la configuración de la aplicación.',
      );
}

class LocationPermissionUnableToDetermineFailure extends LocationException {
  const LocationPermissionUnableToDetermineFailure()
    : super('No se pudo determinar el estado del permiso de ubicación.');
}

class LocationUnknownFailure extends LocationException {
  const LocationUnknownFailure(super.message);
}
