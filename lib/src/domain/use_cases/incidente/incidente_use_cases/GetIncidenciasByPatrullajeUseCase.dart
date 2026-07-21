import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetIncidenciasByPatrullajeUseCase {
  final IncidenteRepository repository;

  const GetIncidenciasByPatrullajeUseCase(this.repository);

  Future<Resource<List<IncidenteModel>>> run({required int patrullajeId}) {
    return repository.getIncidenciasByPatrullaje(patrullajeId: patrullajeId);
  }
}
