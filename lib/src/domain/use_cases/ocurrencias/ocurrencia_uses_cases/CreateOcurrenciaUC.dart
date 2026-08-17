import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CreateOcurrenciaUC {
  final OcurrenciasRepository ocurrenciasRepository;
  CreateOcurrenciaUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> run({
    required CreateOcurrenciaRequest request,
  }) => ocurrenciasRepository.createOcurrencia(request: request);
}
