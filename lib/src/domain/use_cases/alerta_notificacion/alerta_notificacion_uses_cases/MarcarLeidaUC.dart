import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class MarcarLeidaUC {
  final AlertaRepository alertaRepository;
  MarcarLeidaUC(this.alertaRepository);

  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> run({
    required int alertaId,
  }) => alertaRepository.marcarLeida(alertaId: alertaId);
}
