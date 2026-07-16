import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

abstract class TrackingRepository {
  Stream<LocationEntity> getLocationStream({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 5),
  });
  Future<void> sendLocation(LocationEntity location, int patrullajeId);
}
