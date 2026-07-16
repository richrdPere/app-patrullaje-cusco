enum LocationPermissionStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

extension LocationPermissionStatusExtension on LocationPermissionStatus {
  bool get isGranted {
    return this == LocationPermissionStatus.whileInUse ||
        this == LocationPermissionStatus.always;
  }

  bool get isDenied {
    return this == LocationPermissionStatus.denied;
  }

  bool get isDeniedForever {
    return this == LocationPermissionStatus.deniedForever;
  }
}
