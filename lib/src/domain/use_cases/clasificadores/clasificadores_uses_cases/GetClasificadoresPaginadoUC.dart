import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetClasificadoresPaginadoUC {
  final ClasificadoresRepository clasificadoresRepository;
  GetClasificadoresPaginadoUC(this.clasificadoresRepository);

  Future<Resource<ApiResponse<ClasificadorPaginated>>> run({
    required ClasificadorQueryParams params,
  }) => clasificadoresRepository.getClasificadoresPaginado(params: params);
}
