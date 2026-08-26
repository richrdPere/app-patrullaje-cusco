import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ResponderAlertaUC {
  final AlertaRepository alertaRepository;
  ResponderAlertaUC(this.alertaRepository);

  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> run({
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) => alertaRepository.responderAlerta(
    alertaId: alertaId,
    respuesta: respuesta,
    observacion: observacion,
  );
}
