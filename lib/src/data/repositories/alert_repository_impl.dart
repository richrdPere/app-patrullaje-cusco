import 'package:sis_patrullaje_cusco/src/domain/repositories/alert_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
// import 'package:socket_io_client/socket_io_client.dart';

class AlertRepositoryImpl implements AlertRepository {
  final GeolocatorUseCases geolocatorUseCases;

  AlertRepositoryImpl(this.geolocatorUseCases);

  @override
  Future<void> sendAlert() async {
    final position = await geolocatorUseCases.findPosition.run();

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
