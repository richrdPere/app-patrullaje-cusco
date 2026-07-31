import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisAlertasResumenUseCase {
  final AlertaRepository alertaRepository;

  GetMisAlertasResumenUseCase(this.alertaRepository);

  Future<Resource<AlertaResumenModel>> run() =>
      alertaRepository.getMisAlertasResumen();
}
