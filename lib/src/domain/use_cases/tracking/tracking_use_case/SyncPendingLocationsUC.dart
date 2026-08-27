import 'package:sis_patrullaje_cusco/src/data/models/tracking/tracking_sync_result.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class SyncPendingLocationsUC {
  final TrackingRepository trackingRepository;
  SyncPendingLocationsUC(this.trackingRepository);

  Future<TrackingSyncResult> run({int limit = 100}) {
    return trackingRepository.syncPendingLocations(limit: limit);
  }
}
