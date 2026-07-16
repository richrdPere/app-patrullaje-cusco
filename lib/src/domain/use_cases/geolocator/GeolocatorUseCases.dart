import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/CheckLocationPermissionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetCurrentLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetLastKnowLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetLocationStreamUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/IsLocationServiceEnableUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/OpenAppSettingsUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/OpenLocationSettingsUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/RequestLocationPermissionUseCase.dart';

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
