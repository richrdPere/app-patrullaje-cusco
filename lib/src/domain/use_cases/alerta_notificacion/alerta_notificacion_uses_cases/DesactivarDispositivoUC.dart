import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class DesactivarDispositivoUC {
  final AlertaRepository alertaRepository;

  DesactivarDispositivoUC(this.alertaRepository);

  Future<Resource<Map<String, dynamic>>> run({
    required String fcmToken,
    String? deviceId,
  }) => alertaRepository.desactivarDispositivo(
    fcmToken: fcmToken,
    deviceId: deviceId,
  );
}
