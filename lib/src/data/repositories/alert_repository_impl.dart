import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final GeolocatorRepository geolocatorRepository;

  AlertRepositoryImpl(this.geolocatorRepository);

  @override
  Future<void> sendAlert() async {
    final position = await geolocatorRepository.getCurrentLocation();

    final data = {
      "lat": position.latitud,
      "lng": position.longitud,
      "timestamp": DateTime.now().toIso8601String(),
    };

    // Enviar al backend
    // socket.emit("alerta_sereno", data);

    print("🚨 ALERTA ENVIADA: $data");
  }
}
