import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class TrackingUseCases {
  final GetLocationUseCase getLocationStream;
  final SendLocationUserUseCase sendLocation;
  final SyncPendingLocationsUC syncPendingLocations;

  TrackingUseCases({
    required this.getLocationStream,
    required this.sendLocation,
    required this.syncPendingLocations,
  });
}
