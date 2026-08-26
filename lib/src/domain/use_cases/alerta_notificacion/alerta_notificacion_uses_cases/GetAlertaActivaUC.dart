import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetAlertaActivaUC {
  final AlertaRepository alertaRepository;
  GetAlertaActivaUC(this.alertaRepository);

  Future<Resource<ApiResponse<AlertaActivaData>>> run() =>
      alertaRepository.getAlertaActiva();
}
