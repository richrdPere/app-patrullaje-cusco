import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ResponderAlertaUseCase {
  final AlertaRepository alertaRepository;

  ResponderAlertaUseCase(this.alertaRepository);

  Future<Resource<AlertaDestinatarioModel>> run({
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) => alertaRepository.responderAlerta(
    alertaId: alertaId,
    respuesta: respuesta,
    observacion: observacion,
  );
}
