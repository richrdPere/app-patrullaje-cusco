import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetContextoZonaUC {
  final HistorialPatrullajeRepository historialRepository;
  GetContextoZonaUC(this.historialRepository);

  Future<Resource<ApiResponse<ContextoZonaData>>> run({
    required int zonaId,
    required ContextoZonaQueryParams params,
  }) => historialRepository.getContextoZona(zonaId: zonaId, params: params);
}
