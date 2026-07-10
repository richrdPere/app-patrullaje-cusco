import 'package:sis_patrullaje_cusco/src/domain/repositories/alert_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final GeolocatorRepository geolocatorRepository;

  AlertRepositoryImpl(this.geolocatorRepository);

  @override
  Future<void> sendAlert() async {
    final position = await geolocatorRepository.findPosition();

    final data = {
      "lat": position.latitude,
      "lng": position.longitude,
      "timestamp": DateTime.now().toIso8601String(),
    };

    // Enviar al backend
    // socket.emit("alerta_sereno", data);

    print("🚨 ALERTA ENVIADA: $data");
  }
}
