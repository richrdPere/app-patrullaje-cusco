import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class MarcarAtendidaUseCase {
  final AlertaRepository alertaRepository;

  MarcarAtendidaUseCase(this.alertaRepository);

  Future<Resource<AlertaDestinatarioModel>> run({
    required int alertaId,
    String? observacion,
  }) => alertaRepository.marcarAtendida(
    alertaId: alertaId,
    observacion: observacion,
  );
}
