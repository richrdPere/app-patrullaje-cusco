import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class GeolocatorUseCases {
  CheckLocationPermissionUseCase checkLocationPermission;
  GetCurrentLocationUseCase getCurrentLocation;
  GetLastKnowLocationUseCase getLastKnowLocation;
  GetLocationStreamUseCase getLocationStream;
  IsLocationServiceEnableUseCase isLocationServiceEnable;
  OpenAppSettingsUseCase openAppSettings;
  OpenLocationSettingsUseCase openLocationSettings;
  RequestLocationPermissionUseCase requestLocationPermission;

  GeolocatorUseCases({
    required this.checkLocationPermission,
    required this.getCurrentLocation,
    required this.getLastKnowLocation,
    required this.getLocationStream,
    required this.isLocationServiceEnable,
    required this.openAppSettings,
    required this.openLocationSettings,
    required this.requestLocationPermission,
  });
}
