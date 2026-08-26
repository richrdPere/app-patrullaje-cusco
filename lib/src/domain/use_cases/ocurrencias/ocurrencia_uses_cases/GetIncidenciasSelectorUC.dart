import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasSelectorUC {
  final OcurrenciasRepository ocurrenciasRepository;
  GetIncidenciasSelectorUC(this.ocurrenciasRepository);

  Future<Resource<ApiResponse<IncidenciasSelectorPaginated>>> run({
    required IncidenciasSelectorQueryParams params,
  }) => ocurrenciasRepository.getIncidenciasSelector(params: params);
}
