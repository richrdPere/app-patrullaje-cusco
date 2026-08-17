import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetOcurrenciaByIdUC {
  final OcurrenciasRepository ocurrenciasRepository;
  GetOcurrenciaByIdUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> run({
    required int ocurrenciaId,
  }) => ocurrenciasRepository.getOcurrenciaById(ocurrenciaId: ocurrenciaId);
}
