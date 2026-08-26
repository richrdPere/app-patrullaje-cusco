import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetOcurrenciasPaginadoUC {
  final OcurrenciasRepository ocurrenciasRepository;
  GetOcurrenciasPaginadoUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<OcurrenciaPaginated>>> run({
    required OcurrenciaQueryParams params,
  }) => ocurrenciasRepository.getOcurrenciasPaginado(params: params);
}
