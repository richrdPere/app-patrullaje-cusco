import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetAlertaDetalleUC {
  final AlertaRepository alertaRepository;
  GetAlertaDetalleUC(this.alertaRepository);

  Future<Resource<ApiResponse<AlertaDetalleData>>> run({
    required int alertaId,
  }) => alertaRepository.getAlertaDetalle(alertaId: alertaId);
}
