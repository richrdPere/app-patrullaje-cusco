import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetClasificadorByCodigoUC {
  final ClasificadoresRepository clasificadoresRepository;
  GetClasificadorByCodigoUC(this.clasificadoresRepository);

  Future<Resource<ApiResponse<ClasificadorCodigoData>>> run({
    required String codigo,
  }) => clasificadoresRepository.getClasificadorByCodigo(codigo: codigo);
}
