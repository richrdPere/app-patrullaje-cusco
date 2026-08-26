import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetOcurrenciaByIdUC {
  final OcurrenciasRepository ocurrenciasRepository;
  GetOcurrenciaByIdUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> run({
    required int ocurrenciaId,
  }) => ocurrenciasRepository.getOcurrenciaById(ocurrenciaId: ocurrenciaId);
}
