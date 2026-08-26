import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisAlertasUC {
  final AlertaRepository alertaRepository;

  GetMisAlertasUC(this.alertaRepository);

  Future<Resource<ApiResponse<MisAlertasPaginated>>> run({
    required MisAlertasQueryParams params,
  }) => alertaRepository.getMisAlertas(params: params);
}
