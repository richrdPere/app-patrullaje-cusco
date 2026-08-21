import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetHistorialByPatrullajeUC {
  final HistorialPatrullajeRepository historialRepository;
  GetHistorialByPatrullajeUC(this.historialRepository);

  Future<Resource<ApiResponse<List<HistorialPatrullajeData>>>> run({
    required int patrullajeId,
  }) =>
      historialRepository.getHistorialByPatrullaje(patrullajeId: patrullajeId);
}
