import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ActivarAlertaUC {
  final AlertaRepository alertaRepository;
  ActivarAlertaUC(this.alertaRepository);

  Future<Resource<ApiResponse<ActivarAlertaData>>> run({
    required ActivarAlertaRequest request,
  }) => alertaRepository.activarAlerta(request: request);
}
