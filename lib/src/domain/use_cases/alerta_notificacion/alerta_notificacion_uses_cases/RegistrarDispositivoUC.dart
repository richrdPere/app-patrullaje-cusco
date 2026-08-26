import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class RegistrarDispositivoUC {
  final AlertaRepository alertaRepository;

  RegistrarDispositivoUC(this.alertaRepository);

  Future<Resource<Map<String, dynamic>>> run({
    required String fcmToken,
    String? deviceId,
  }) => alertaRepository.registrarDispositivo(
    fcmToken: fcmToken,
    deviceId: deviceId,
  );
}
