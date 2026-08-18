import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisPatrullajesPaginadosUC {
  PatrullajeRepository patrullajeRepository;
  GetMisPatrullajesPaginadosUC(this.patrullajeRepository);

  Future<Resource<ApiResponse<PatrullajeSerenoPaginated>>> run({
    required PatrullajeSerenoQueryParams params,
  }) => patrullajeRepository.getMisPatrullajesPaginados(params: params);
}
