import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CreateOcurrenciaUC {
  final OcurrenciasRepository ocurrenciasRepository;
  CreateOcurrenciaUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> run({
    required CreateOcurrenciaRequest request,
  }) => ocurrenciasRepository.createOcurrencia(request: request);
}
