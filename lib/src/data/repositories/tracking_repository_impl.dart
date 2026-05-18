import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final GeolocatorRepository geolocatorRepository;
  final SocketRepository socketRepository;

  TrackingRepositoryImpl(this.geolocatorRepository, this.socketRepository);

  @override
  Stream<LocationEntity> getLocationStream() {
    return geolocatorRepository.getLocationStream();
  }

  @override
  void sendLocation(LocationEntity location, int patrullajeId) {
    final s = socketRepository.getSocket();

    s.emit("tracking", {
      "lat": location.latitud,
      "lng": location.longitud,

      "velocidad": location.velocidad,
      "precision": location.precision,

      "patrullaje_id": patrullajeId,

      "timestamp": DateTime.now().toIso8601String(),

      "tipo": "TRACKING",
    });
  }
}
