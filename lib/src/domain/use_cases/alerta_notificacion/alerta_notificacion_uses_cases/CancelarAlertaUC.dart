import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CancelarAlertaUC {
  final AlertaRepository alertaRepository;
  CancelarAlertaUC(this.alertaRepository);

  Future<Resource<ApiResponse<CancelarAlertaData>>> run({
    required int alertaId,
  }) => alertaRepository.cancelarAlerta(alertaId: alertaId);
}
