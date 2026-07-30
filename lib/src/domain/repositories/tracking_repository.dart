import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/tracking_send_result.dart';

abstract class TrackingRepository {
  Stream<LocationEntity> getLocationStream({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 5),
  });
  Future<TrackingSendResult> sendLocation(
    LocationEntity location,
    int patrullajeId,
  );
}
