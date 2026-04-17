import 'package:sis_patrullaje_cusco/src/domain/repositories/alert_repository.dart';

class SendAlertUseCase {
  AlertRepository alertRepository;
  SendAlertUseCase(this.alertRepository);

  run() => alertRepository.sendAlert();
}
