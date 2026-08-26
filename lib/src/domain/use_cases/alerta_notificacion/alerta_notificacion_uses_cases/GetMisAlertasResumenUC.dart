import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisAlertasResumenUC {
  final AlertaRepository alertaRepository;
  GetMisAlertasResumenUC(this.alertaRepository);

  Future<Resource<ApiResponse<MisAlertasResumenData>>> run() =>
      alertaRepository.getMisAlertasResumen();
}
