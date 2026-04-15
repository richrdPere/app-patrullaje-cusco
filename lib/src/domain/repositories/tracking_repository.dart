import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class TrackingRepository {
  Stream<LocationEntity> getLocationStream();
  Future<void> startTracking();
  Future<void> stopTracking();
}
