import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class MarcarRecibidaUC {
  final AlertaRepository alertaRepository;
  MarcarRecibidaUC(this.alertaRepository);

  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> run({
    required int alertaId,
  }) => alertaRepository.marcarRecibida(alertaId: alertaId);
}
