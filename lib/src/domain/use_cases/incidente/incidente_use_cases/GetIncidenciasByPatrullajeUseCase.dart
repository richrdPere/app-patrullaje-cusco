import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasByPatrullajeUseCase {
  final IncidenteRepository repository;

  const GetIncidenciasByPatrullajeUseCase(this.repository);

  Future<Resource<ApiResponse<IncidenciasPatrullajePaginated>>> run({
    required int patrullajeId,
    required IncidenciasPatrullajeQueryParams params,
  }) {
    return repository.getIncidenciasByPatrullaje(
      patrullajeId: patrullajeId,
      params: params,
    );
  }
}
